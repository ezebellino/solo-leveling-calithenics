import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/providers/core_providers.dart';
import '../data/auth_local_data_source.dart';
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
      final localDataSource = ref.read(authLocalDataSourceProvider);
      final biometricAuth = ref.read(deviceBiometricAuthProvider);
      final providers = await repository.fetchProviders();
      final biometricSupported = await biometricAuth.isSupported();
      final biometricUnlockEnabled = biometricSupported &&
          await localDataSource.loadBiometricUnlockEnabled();
      final hasStoredSession = await localDataSource.hasStoredAccessToken();

      if (biometricUnlockEnabled && hasStoredSession) {
        state = state.copyWith(
          isRestoring: false,
          providers: providers,
          biometricSupported: biometricSupported,
          biometricUnlockEnabled: biometricUnlockEnabled,
          requiresBiometricUnlock: true,
          clearErrorMessage: true,
        );
        logger.sync(
          feature: 'auth',
          action: 'initialize',
          source: 'auth.controller',
          outcome: 'locked',
          context: <String, Object?>{
            'providerCount': providers.length,
            'biometricUnlockEnabled': biometricUnlockEnabled,
          },
        );
        return;
      }

      final session = await repository.restoreSession();
      state = state.copyWith(
        isRestoring: false,
        providers: providers,
        session: session,
        biometricSupported: biometricSupported,
        biometricUnlockEnabled: biometricUnlockEnabled,
        requiresBiometricUnlock: false,
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
          'biometricSupported': biometricSupported,
          'biometricUnlockEnabled': biometricUnlockEnabled,
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

  Future<void> signInWithGoogle({
    required String email,
    required String displayName,
  }) async {
    await _runSessionAction(
      action: 'sign_in_google',
      perform: () => ref.read(authSessionRepositoryProvider).signInWithGoogle(
            email: email,
            displayName: displayName,
          ),
      clearMagicLinkState: true,
    );
  }

  Future<void> requestMagicLink({
    required String email,
    String? displayName,
    String? redirectUrl,
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
            redirectUrl: redirectUrl,
          );
      state = state.copyWith(
        isSubmitting: false,
        magicLinkPreviewToken: result.previewToken,
        magicLinkEmail: result.email,
        magicLinkDelivery: result.delivery,
        magicLinkExpiresAt: result.expiresAt,
        magicLinkVerificationUrl: result.verificationUrl,
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
          'previewMode': result.previewMode,
          'hasVerificationUrl': result.verificationUrl != null,
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
        requiresBiometricUnlock: false,
        clearMagicLinkPreviewToken: true,
        clearMagicLinkEmail: true,
        clearMagicLinkDelivery: true,
        clearMagicLinkExpiresAt: true,
        clearMagicLinkVerificationUrl: true,
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

  Future<void> unlockWithBiometrics() async {
    final logger = ref.read(appLoggerProvider);
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
    );

    try {
      final biometricAuth = ref.read(deviceBiometricAuthProvider);
      final didAuthenticate = await biometricAuth.authenticate(
        localizedReason:
            'Autentica tu dispositivo para restaurar la sesion del Sistema.',
      );
      if (!didAuthenticate) {
        state = state.copyWith(isSubmitting: false);
        logger.sync(
          feature: 'auth',
          action: 'unlock_biometric',
          source: 'auth.controller',
          outcome: 'cancelled',
        );
        return;
      }

      final session = await ref.read(authSessionRepositoryProvider).restoreSession();
      state = state.copyWith(
        isSubmitting: false,
        session: session,
        requiresBiometricUnlock: false,
        clearErrorMessage: true,
      );
      logger.sync(
        feature: 'auth',
        action: 'unlock_biometric',
        source: 'auth.controller',
        outcome: session == null ? 'empty' : 'succeeded',
        entityId: session?.userId,
      );
    } catch (error) {
      final exception = mapToAppException(error);
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: exception.message,
      );
      logger.sync(
        feature: 'auth',
        action: 'unlock_biometric',
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

  Future<void> enableBiometricUnlock() async {
    final logger = ref.read(appLoggerProvider);
    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
    );

    try {
      final biometricAuth = ref.read(deviceBiometricAuthProvider);
      final didAuthenticate = await biometricAuth.authenticate(
        localizedReason:
            'Autentica tu dispositivo para activar el acceso biometrico del Sistema.',
      );
      if (!didAuthenticate) {
        state = state.copyWith(isSubmitting: false);
        logger.sync(
          feature: 'auth',
          action: 'enable_biometric_unlock',
          source: 'auth.controller',
          outcome: 'cancelled',
        );
        return;
      }
      await ref
          .read(authLocalDataSourceProvider)
          .saveBiometricUnlockEnabled(true);
      state = state.copyWith(
        isSubmitting: false,
        biometricUnlockEnabled: true,
        clearErrorMessage: true,
      );
      logger.sync(
        feature: 'auth',
        action: 'enable_biometric_unlock',
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
        action: 'enable_biometric_unlock',
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

  Future<void> disableBiometricUnlock() async {
    await ref.read(authLocalDataSourceProvider).saveBiometricUnlockEnabled(false);
    state = state.copyWith(
      biometricUnlockEnabled: false,
      requiresBiometricUnlock: false,
      clearErrorMessage: true,
    );
    ref.read(appLoggerProvider).sync(
      feature: 'auth',
      action: 'disable_biometric_unlock',
      source: 'auth.controller',
      outcome: 'succeeded',
    );
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
        requiresBiometricUnlock: false,
        clearErrorMessage: true,
        clearMagicLinkPreviewToken: clearMagicLinkState,
        clearMagicLinkEmail: clearMagicLinkState,
        clearMagicLinkDelivery: clearMagicLinkState,
        clearMagicLinkExpiresAt: clearMagicLinkState,
        clearMagicLinkVerificationUrl: clearMagicLinkState,
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
