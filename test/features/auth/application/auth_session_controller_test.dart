import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/core/errors/app_exception.dart';
import 'package:solo_leveling_calisthenics/features/auth/application/auth_session_controller.dart';
import 'package:solo_leveling_calisthenics/features/auth/application/auth_session_state.dart';
import 'package:solo_leveling_calisthenics/features/auth/data/auth_local_data_source.dart';
import 'package:solo_leveling_calisthenics/features/auth/data/auth_repository_impl.dart';
import 'package:solo_leveling_calisthenics/features/auth/domain/auth_provider_option.dart';
import 'package:solo_leveling_calisthenics/features/auth/domain/auth_session.dart';
import 'package:solo_leveling_calisthenics/features/auth/domain/auth_session_repository.dart';
import 'package:solo_leveling_calisthenics/features/auth/domain/device_biometric_auth.dart';
import 'package:solo_leveling_calisthenics/features/auth/domain/magic_link_request_result.dart';

void main() {
  group('AuthSessionController', () {
    test('initialize leaves unauthenticated state when no session is stored', () async {
      final repository = _FakeAuthSessionRepository(
        providers: const [
          AuthProviderOption(
            code: 'google',
            displayName: 'Google',
            transport: 'oauth',
            availability: 'development_preview',
          ),
        ],
      );
      final container = ProviderContainer(
        overrides: [
          authSessionRepositoryProvider.overrideWithValue(repository),
          authLocalDataSourceProvider.overrideWithValue(_FakeAuthLocalDataSource()),
          deviceBiometricAuthProvider.overrideWithValue(_FakeDeviceBiometricAuth()),
        ],
      );
      addTearDown(container.dispose);

      final states = <AuthSessionState>[];
      container.listen(
        authSessionControllerProvider,
        (_, next) => states.add(next),
        fireImmediately: true,
      );

      await container.read(authSessionControllerProvider.notifier).initialize();

      final state = container.read(authSessionControllerProvider);
      expect(state.isRestoring, isFalse);
      expect(state.isAuthenticated, isFalse);
      expect(state.providers, hasLength(1));
      expect(states.any((entry) => entry.isRestoring), isTrue);
    });

    test('initialize restores authenticated session when a token is already cached', () async {
      final repository = _FakeAuthSessionRepository(
        providers: const [
          AuthProviderOption(
            code: 'magic_link',
            displayName: 'Magic Link',
            transport: 'email',
            availability: 'development_preview',
          ),
        ],
        restoredSession: _session,
      );
      final container = ProviderContainer(
        overrides: [
          authSessionRepositoryProvider.overrideWithValue(repository),
          authLocalDataSourceProvider.overrideWithValue(_FakeAuthLocalDataSource()),
          deviceBiometricAuthProvider.overrideWithValue(_FakeDeviceBiometricAuth()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authSessionControllerProvider.notifier).initialize();

      final state = container.read(authSessionControllerProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.session?.userId, _session.userId);
      expect(state.providers.single.code, 'magic_link');
    });

    test('initialize keeps stored session locked when biometric unlock is enabled', () async {
      final repository = _FakeAuthSessionRepository(
        providers: const [
          AuthProviderOption(
            code: 'google',
            displayName: 'Google',
            transport: 'oauth',
            availability: 'available',
          ),
        ],
        restoredSession: _session,
      );
      final localDataSource = _FakeAuthLocalDataSource(
        storedAccessToken: 'access-token-123',
        biometricUnlockEnabled: true,
      );
      final biometricAuth = _FakeDeviceBiometricAuth(isSupportedResult: true);
      final container = ProviderContainer(
        overrides: [
          authSessionRepositoryProvider.overrideWithValue(repository),
          authLocalDataSourceProvider.overrideWithValue(localDataSource),
          deviceBiometricAuthProvider.overrideWithValue(biometricAuth),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authSessionControllerProvider.notifier).initialize();

      final state = container.read(authSessionControllerProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.requiresBiometricUnlock, isTrue);
      expect(state.biometricUnlockEnabled, isTrue);
      expect(repository.restoreSessionCalls, 0);
    });

    test('signInWithGoogle stores authenticated session', () async {
      final repository = _FakeAuthSessionRepository(
        providers: const [],
        googleSession: _session,
      );
      final container = ProviderContainer(
        overrides: [
          authSessionRepositoryProvider.overrideWithValue(repository),
          authLocalDataSourceProvider.overrideWithValue(_FakeAuthLocalDataSource()),
          deviceBiometricAuthProvider.overrideWithValue(_FakeDeviceBiometricAuth()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authSessionControllerProvider.notifier).signInWithGoogle(
            email: 'hunter@example.com',
            displayName: 'Hunter',
          );

      final state = container.read(authSessionControllerProvider);
      expect(state.session?.userId, _session.userId);
      expect(state.session?.provider, 'google');
      expect(state.errorMessage, isNull);
    });

    test('requestMagicLink stores preview token for local verification flow', () async {
      final repository = _FakeAuthSessionRepository(
        providers: const [],
        magicLinkResult: MagicLinkRequestResult(
          email: 'magic@example.com',
          expiresAt: DateTime.utc(2026, 5, 12, 12),
          delivery: 'preview',
          previewMode: true,
          previewToken: 'preview-token-123',
          verificationUrl: 'http://localhost:7358/auth?token=preview-token-123',
        ),
      );
      final container = ProviderContainer(
        overrides: [
          authSessionRepositoryProvider.overrideWithValue(repository),
          authLocalDataSourceProvider.overrideWithValue(_FakeAuthLocalDataSource()),
          deviceBiometricAuthProvider.overrideWithValue(_FakeDeviceBiometricAuth()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authSessionControllerProvider.notifier).requestMagicLink(
            email: 'magic@example.com',
            displayName: 'Magic User',
            redirectUrl: 'http://localhost:7358/auth',
          );

      final state = container.read(authSessionControllerProvider);
      expect(state.magicLinkPreviewToken, 'preview-token-123');
      expect(state.magicLinkEmail, 'magic@example.com');
      expect(state.magicLinkDelivery, 'preview');
      expect(state.magicLinkVerificationUrl, 'http://localhost:7358/auth?token=preview-token-123');
    });

    test('requestMagicLink stores email delivery state without preview token', () async {
      final repository = _FakeAuthSessionRepository(
        providers: const [],
        magicLinkResult: MagicLinkRequestResult(
          email: 'magic@example.com',
          expiresAt: DateTime.utc(2026, 5, 12, 12),
          delivery: 'email',
          previewMode: false,
          previewToken: null,
          verificationUrl: null,
        ),
      );
      final container = ProviderContainer(
        overrides: [
          authSessionRepositoryProvider.overrideWithValue(repository),
          authLocalDataSourceProvider.overrideWithValue(_FakeAuthLocalDataSource()),
          deviceBiometricAuthProvider.overrideWithValue(_FakeDeviceBiometricAuth()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authSessionControllerProvider.notifier).requestMagicLink(
            email: 'magic@example.com',
            displayName: 'Magic User',
            redirectUrl: 'https://system.example.com/auth',
          );

      final state = container.read(authSessionControllerProvider);
      expect(state.magicLinkPreviewToken, isNull);
      expect(state.magicLinkEmail, 'magic@example.com');
      expect(state.magicLinkDelivery, 'email');
      expect(state.magicLinkVerificationUrl, isNull);
    });

    test('signOut clears the active session', () async {
      final repository = _FakeAuthSessionRepository(
        providers: const [],
        googleSession: _session,
      );
      final container = ProviderContainer(
        overrides: [
          authSessionRepositoryProvider.overrideWithValue(repository),
          authLocalDataSourceProvider.overrideWithValue(_FakeAuthLocalDataSource()),
          deviceBiometricAuthProvider.overrideWithValue(_FakeDeviceBiometricAuth()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authSessionControllerProvider.notifier).signInWithGoogle(
            email: 'hunter@example.com',
            displayName: 'Hunter',
          );
      await container.read(authSessionControllerProvider.notifier).signOut();

      final state = container.read(authSessionControllerProvider);
      expect(state.session, isNull);
      expect(repository.didSignOut, isTrue);
    });

    test('unlockWithBiometrics restores the stored authenticated session', () async {
      final repository = _FakeAuthSessionRepository(
        providers: const [],
        restoredSession: _session,
      );
      final localDataSource = _FakeAuthLocalDataSource(
        storedAccessToken: 'access-token-123',
        biometricUnlockEnabled: true,
      );
      final biometricAuth = _FakeDeviceBiometricAuth(
        isSupportedResult: true,
        authenticateResult: true,
      );
      final container = ProviderContainer(
        overrides: [
          authSessionRepositoryProvider.overrideWithValue(repository),
          authLocalDataSourceProvider.overrideWithValue(localDataSource),
          deviceBiometricAuthProvider.overrideWithValue(biometricAuth),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authSessionControllerProvider.notifier).initialize();
      await container.read(authSessionControllerProvider.notifier).unlockWithBiometrics();

      final state = container.read(authSessionControllerProvider);
      expect(state.session?.userId, _session.userId);
      expect(state.requiresBiometricUnlock, isFalse);
    });

    test('enableBiometricUnlock persists local preference after local auth succeeds', () async {
      final repository = _FakeAuthSessionRepository(
        providers: const [],
        googleSession: _session,
      );
      final localDataSource = _FakeAuthLocalDataSource();
      final biometricAuth = _FakeDeviceBiometricAuth(
        isSupportedResult: true,
        authenticateResult: true,
      );
      final container = ProviderContainer(
        overrides: [
          authSessionRepositoryProvider.overrideWithValue(repository),
          authLocalDataSourceProvider.overrideWithValue(localDataSource),
          deviceBiometricAuthProvider.overrideWithValue(biometricAuth),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authSessionControllerProvider.notifier).signInWithGoogle(
            email: 'hunter@example.com',
            displayName: 'Hunter',
          );
      container.read(authSessionControllerProvider.notifier).state = container
          .read(authSessionControllerProvider)
          .copyWith(biometricSupported: true);
      await container.read(authSessionControllerProvider.notifier).enableBiometricUnlock();

      final state = container.read(authSessionControllerProvider);
      expect(state.biometricUnlockEnabled, isTrue);
      expect(localDataSource.biometricUnlockEnabled, isTrue);
    });

    test('initialize stores mapped message when repository fails', () async {
      final container = ProviderContainer(
        overrides: [
          authSessionRepositoryProvider.overrideWithValue(
            _FakeAuthSessionRepository(
              providers: const [],
              providersError: const AppException(
                'auth_providers_failed',
                'No se pudo preparar el acceso.',
              ),
            ),
          ),
          authLocalDataSourceProvider.overrideWithValue(_FakeAuthLocalDataSource()),
          deviceBiometricAuthProvider.overrideWithValue(_FakeDeviceBiometricAuth()),
        ],
      );
      addTearDown(container.dispose);

      await container.read(authSessionControllerProvider.notifier).initialize();

      final state = container.read(authSessionControllerProvider);
      expect(state.errorMessage, 'No se pudo preparar el acceso.');
      expect(state.isRestoring, isFalse);
    });
  });
}

final _session = AuthSession(
  accessToken: 'access-token-123',
  provider: 'google',
  expiresAt: DateTime.utc(2026, 5, 12, 18),
  userId: 'user-1',
  displayName: 'Hunter',
  avatarUrl: '',
  email: 'hunter@example.com',
);

class _FakeAuthSessionRepository implements AuthSessionRepository {
  _FakeAuthSessionRepository({
    required this.providers,
    this.restoredSession,
    this.googleSession,
    this.magicLinkResult,
    this.providersError,
  });

  final List<AuthProviderOption> providers;
  final AuthSession? restoredSession;
  final AuthSession? googleSession;
  final MagicLinkRequestResult? magicLinkResult;
  final Object? providersError;

  bool didSignOut = false;
  int restoreSessionCalls = 0;

  @override
  Future<List<AuthProviderOption>> fetchProviders() async {
    if (providersError != null) {
      throw providersError!;
    }
    return providers;
  }

  @override
  Future<MagicLinkRequestResult> requestMagicLink({
    required String email,
    String? displayName,
    String? redirectUrl,
  }) async {
    return magicLinkResult!;
  }

  @override
  Future<AuthSession?> restoreSession() async {
    restoreSessionCalls += 1;
    return restoredSession;
  }

  @override
  Future<AuthSession> signInWithGoogle({
    required String email,
    required String displayName,
  }) async {
    return googleSession!;
  }

  @override
  Future<void> signOut() async {
    didSignOut = true;
  }

  @override
  Future<AuthSession> verifyMagicLink({required String token}) async {
    return googleSession ?? _session;
  }
}

class _FakeAuthLocalDataSource extends AuthLocalDataSource {
  _FakeAuthLocalDataSource({
    this.storedAccessToken,
    this.biometricUnlockEnabled = false,
  });

  String? storedAccessToken;
  bool biometricUnlockEnabled;

  @override
  Future<String?> loadAccessToken() async => storedAccessToken;

  @override
  Future<bool> hasStoredAccessToken() async =>
      storedAccessToken != null && storedAccessToken!.isNotEmpty;

  @override
  Future<void> saveAccessToken(String accessToken) async {
    storedAccessToken = accessToken;
  }

  @override
  Future<void> clearAccessToken() async {
    storedAccessToken = null;
  }

  @override
  Future<bool> loadBiometricUnlockEnabled() async => biometricUnlockEnabled;

  @override
  Future<void> saveBiometricUnlockEnabled(bool enabled) async {
    biometricUnlockEnabled = enabled;
  }
}

class _FakeDeviceBiometricAuth implements DeviceBiometricAuth {
  _FakeDeviceBiometricAuth({
    this.isSupportedResult = false,
    this.authenticateResult = false,
  });

  final bool isSupportedResult;
  final bool authenticateResult;

  @override
  Future<bool> authenticate({required String localizedReason}) async {
    return authenticateResult;
  }

  @override
  Future<bool> isSupported() async => isSupportedResult;
}
