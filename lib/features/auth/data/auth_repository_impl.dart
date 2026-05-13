import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/network/http_client_provider.dart';
import '../../../core/providers/core_providers.dart';
import '../domain/auth_provider_option.dart';
import '../domain/auth_session.dart';
import '../domain/auth_session_repository.dart';
import '../domain/google_identity_provider.dart';
import '../domain/magic_link_request_result.dart';
import 'auth_api_client.dart';
import 'auth_local_data_source.dart';
import 'google_identity_provider_impl.dart';

final authSessionRepositoryProvider = Provider<AuthSessionRepository>((ref) {
  return AuthRepositoryImpl(
    apiClient: ref.watch(authApiClientProvider),
    googleIdentityProvider: ref.watch(googleIdentityProviderProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

final authApiClientProvider = Provider<AuthApiClient>((ref) {
  return AuthApiClient(
    baseUrl: ref.watch(apiBaseUrlProvider),
    httpClient: ref.watch(httpClientProvider),
    disposeHttpClient: false,
  );
});

final googleIdentityProviderProvider = Provider<GoogleIdentityProvider>((ref) {
  return GoogleIdentityProviderImpl(
    clientId: ref.watch(googleClientIdProvider),
    serverClientId: ref.watch(googleServerClientIdProvider),
  );
});

class AuthRepositoryImpl implements AuthSessionRepository {
  AuthRepositoryImpl({
    required AuthApiClient apiClient,
    required GoogleIdentityProvider googleIdentityProvider,
    required AuthLocalDataSource localDataSource,
    required AppLogger logger,
  })  : _apiClient = apiClient,
        _googleIdentityProvider = googleIdentityProvider,
        _localDataSource = localDataSource,
        _logger = logger;

  final AuthApiClient _apiClient;
  final GoogleIdentityProvider _googleIdentityProvider;
  final AuthLocalDataSource _localDataSource;
  final AppLogger _logger;

  @override
  Future<List<AuthProviderOption>> fetchProviders() async {
    _logger.sync(
      feature: 'auth',
      action: 'fetch_providers',
      source: 'auth.repository',
      outcome: 'started',
    );
    final providers = await _apiClient.fetchProviders();
    _logger.sync(
      feature: 'auth',
      action: 'fetch_providers',
      source: 'auth.repository',
      outcome: 'succeeded',
      context: <String, Object?>{
        'providerCount': providers.length,
      },
    );
    return providers;
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final accessToken = await _localDataSource.loadAccessToken();
    if (accessToken == null) {
      _logger.sync(
        feature: 'auth',
        action: 'restore_session',
        source: 'auth.repository',
        outcome: 'empty',
      );
      return null;
    }

    try {
      final session = await _apiClient.fetchCurrentSession(accessToken: accessToken);
      _logger.sync(
        feature: 'auth',
        action: 'restore_session',
        source: 'auth.repository',
        outcome: 'succeeded',
        entityId: session.userId,
      );
      return session;
    } on AppException catch (error) {
      if (_isRecoverableMissingSession(error.code)) {
        await _localDataSource.clearAccessToken();
        _logger.sync(
          feature: 'auth',
          action: 'restore_session',
          source: 'auth.repository',
          outcome: 'cleared',
          context: <String, Object?>{
            'errorCode': error.code,
          },
        );
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<AuthSession> signInWithGoogle({
    required String email,
    required String displayName,
  }) async {
    final identity = await _googleIdentityProvider.signIn();
    final resolvedEmail = identity.email.isNotEmpty
        ? identity.email
        : email.trim().toLowerCase();
    final resolvedDisplayName = identity.displayName.isNotEmpty
        ? identity.displayName
        : displayName.trim();
    final session = await _apiClient.exchangeGoogle(
      idToken: identity.idToken,
      email: resolvedEmail,
      displayName: resolvedDisplayName,
      providerSubject: identity.providerSubject,
      avatarUrl: identity.avatarUrl,
    );
    await _localDataSource.saveAccessToken(session.accessToken);
    _logger.sync(
      feature: 'auth',
      action: 'sign_in_google',
      source: 'auth.repository',
      outcome: 'succeeded',
      entityId: session.userId,
    );
    return session;
  }

  @override
  Future<MagicLinkRequestResult> requestMagicLink({
    required String email,
    String? displayName,
    String? redirectUrl,
  }) {
    return _apiClient.requestMagicLink(
      email: email,
      displayName: displayName,
      redirectUrl: redirectUrl,
    );
  }

  @override
  Future<AuthSession> verifyMagicLink({
    required String token,
  }) async {
    final session = await _apiClient.verifyMagicLink(token: token);
    await _localDataSource.saveAccessToken(session.accessToken);
    _logger.sync(
      feature: 'auth',
      action: 'verify_magic_link',
      source: 'auth.repository',
      outcome: 'succeeded',
      entityId: session.userId,
    );
    return session;
  }

  @override
  Future<void> signOut() async {
    final accessToken = await _localDataSource.loadAccessToken();
    if (accessToken != null) {
      try {
        await _apiClient.logout(accessToken: accessToken);
      } on AppException catch (error) {
        if (!_isRecoverableMissingSession(error.code)) {
          rethrow;
        }
      }
    }
    try {
      await _googleIdentityProvider.signOut();
    } catch (_) {
      // Backend session revocation and local token cleanup remain authoritative.
    }
    await _localDataSource.clearAccessToken();
    _logger.sync(
      feature: 'auth',
      action: 'sign_out',
      source: 'auth.repository',
      outcome: 'succeeded',
    );
  }

  bool _isRecoverableMissingSession(String code) {
    return code == 'auth_unauthorized' ||
        code == 'auth_invalid_credentials' ||
        code == 'auth_session_expired';
  }
}
