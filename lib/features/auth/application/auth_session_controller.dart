import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/providers/core_providers.dart';
import '../data/auth_repository_impl.dart';
import '../domain/auth_session.dart';
import 'auth_session_state.dart';

class AuthSessionController extends Notifier<AuthSessionState> {
  @override
  AuthSessionState build() => const AuthSessionState();

  Future<void> initialize() async {
    final logger = ref.read(appLoggerProvider);
    state = state.copyWith(
      isRestoring: true,
      clearErrorMessage: true,
    );
    logger.sync(
      feature: 'auth',
      action: 'initialize',
      source: 'auth.controller',
      outcome: 'started',
    );

    try {
      final repository = ref.read(authSessionRepositoryProvider);
      final providers = await repository.fetchProviders();
      final session = await repository.restoreSession();
      state = state.copyWith(
        isRestoring: false,
        providers: providers,
        session: session,
        clearErrorMessage: true,
      );
      logger.sync(
        feature: 'auth',
        action: 'initialize',
        source: 'auth.controller',
        outcome: session == null ? 'unauthenticated' : 'authenticated',
        entityId: session?.userId,
        context: <String, Object?>{
          'providerCount': providers.length,
        },
      );
    } catch (error) {
      final exception = mapToAppException(error);
      state = state.copyWith(
        isRestoring: false,
        errorMessage: exception.message,
      );
      logger.sync(
        feature: 'auth',
        action: 'initialize',
        source: 'auth.controller',
        outcome: 'failed',
        level: LogLevel.warning,
        context: <String, Object?>{
          'errorCode': exception.code,
          ...exception.logContext,
        },
      );
    }
  }

  Future<void> signInWithGooglePreview({
    required String email,
    required String displayName,
  }) async {
    await _runSessionAction(
      action: 'sign_in_google_preview',
      perform: () => ref.read(authSessionRepositoryProvider).signInWithGooglePreview(
            email: email,
            displayName: displayName,
          ),
      clearMagicLinkState: true,
    );
  }

  Future<void> requestMagicLink({
    required String email,
    String? displayName,
  }) async {
    final logger = ref.read(appLoggerProvider);
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
    );

    try {
      final result = await ref.read(authSessionRepositoryProvider).requestMagicLink(
            email: email,
            displayName: displayName,
          );
      state = state.copyWith(
        isSubmitting: false,
        magicLinkPreviewToken: result.previewToken,
        magicLinkEmail: result.email,
        clearErrorMessage: true,
      );
      logger.sync(
        feature: 'auth',
        action: 'request_magic_link',
        source: 'auth.controller',
        outcome: 'succeeded',
        context: <String, Object?>{
          'delivery': result.delivery,
          'hasPreviewToken': result.previewToken != null,
        },
      );
    } catch (error) {
      final exception = mapToAppException(error);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: exception.message,
      );
      logger.sync(
        feature: 'auth',
        action: 'request_magic_link',
        source: 'auth.controller',
        outcome: 'failed',
        level: LogLevel.warning,
        context: <String, Object?>{
          'errorCode': exception.code,
          ...exception.logContext,
        },
      );
    }
  }

  Future<void> verifyMagicLink({
    required String token,
  }) async {
    await _runSessionAction(
      action: 'verify_magic_link',
      perform: () => ref.read(authSessionRepositoryProvider).verifyMagicLink(token: token),
      clearMagicLinkState: false,
    );
  }

  Future<void> signOut() async {
    final logger = ref.read(appLoggerProvider);
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
    );

    try {
      await ref.read(authSessionRepositoryProvider).signOut();
      state = state.copyWith(
        isSubmitting: false,
        clearSession: true,
        clearMagicLinkPreviewToken: true,
        clearMagicLinkEmail: true,
        clearErrorMessage: true,
      );
      logger.sync(
        feature: 'auth',
        action: 'sign_out',
        source: 'auth.controller',
        outcome: 'succeeded',
      );
    } catch (error) {
      final exception = mapToAppException(error);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: exception.message,
      );
      logger.sync(
        feature: 'auth',
        action: 'sign_out',
        source: 'auth.controller',
        outcome: 'failed',
        level: LogLevel.warning,
        context: <String, Object?>{
          'errorCode': exception.code,
          ...exception.logContext,
        },
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearErrorMessage: true);
  }

  Future<void> _runSessionAction({
    required String action,
    required Future<AuthSession> Function() perform,
    required bool clearMagicLinkState,
  }) async {
    final logger = ref.read(appLoggerProvider);
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
    );

    try {
      final session = await perform();
      state = state.copyWith(
        isSubmitting: false,
        session: session,
        clearErrorMessage: true,
        clearMagicLinkPreviewToken: clearMagicLinkState,
        clearMagicLinkEmail: clearMagicLinkState,
      );
      logger.sync(
        feature: 'auth',
        action: action,
        source: 'auth.controller',
        outcome: 'succeeded',
        entityId: session.userId,
        context: <String, Object?>{
          'provider': session.provider,
        },
      );
    } catch (error) {
      final exception = mapToAppException(error);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: exception.message,
      );
      logger.sync(
        feature: 'auth',
        action: action,
        source: 'auth.controller',
        outcome: 'failed',
        level: LogLevel.warning,
        context: <String, Object?>{
          'errorCode': exception.code,
          ...exception.logContext,
        },
      );
    }
  }
}

final authSessionControllerProvider =
    NotifierProvider<AuthSessionController, AuthSessionState>(
      AuthSessionController.new,
    );

final currentAuthAccessTokenProvider = Provider<String?>((ref) {
  return ref.watch(authSessionControllerProvider).session?.accessToken;
});
