import '../domain/auth_provider_option.dart';
import '../domain/auth_session.dart';

class AuthSessionState {
  const AuthSessionState({
    this.isRestoring = false,
    this.isSubmitting = false,
    this.providers = const <AuthProviderOption>[],
    this.session,
    this.biometricSupported = false,
    this.biometricUnlockEnabled = false,
    this.requiresBiometricUnlock = false,
    this.errorMessage,
    this.magicLinkPreviewToken,
    this.magicLinkEmail,
    this.magicLinkDelivery,
    this.magicLinkExpiresAt,
    this.magicLinkVerificationUrl,
  });

  final bool isRestoring;
  final bool isSubmitting;
  final List<AuthProviderOption> providers;
  final AuthSession? session;
  final bool biometricSupported;
  final bool biometricUnlockEnabled;
  final bool requiresBiometricUnlock;
  final String? errorMessage;
  final String? magicLinkPreviewToken;
  final String? magicLinkEmail;
  final String? magicLinkDelivery;
  final DateTime? magicLinkExpiresAt;
  final String? magicLinkVerificationUrl;

  bool get isAuthenticated => session != null;

  AuthSessionState copyWith({
    bool? isRestoring,
    bool? isSubmitting,
    List<AuthProviderOption>? providers,
    AuthSession? session,
    bool? biometricSupported,
    bool? biometricUnlockEnabled,
    bool? requiresBiometricUnlock,
    String? errorMessage,
    String? magicLinkPreviewToken,
    String? magicLinkEmail,
    String? magicLinkDelivery,
    DateTime? magicLinkExpiresAt,
    String? magicLinkVerificationUrl,
    bool clearSession = false,
    bool clearErrorMessage = false,
    bool clearMagicLinkPreviewToken = false,
    bool clearMagicLinkEmail = false,
    bool clearMagicLinkDelivery = false,
    bool clearMagicLinkExpiresAt = false,
    bool clearMagicLinkVerificationUrl = false,
  }) {
    return AuthSessionState(
      isRestoring: isRestoring ?? this.isRestoring,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      providers: providers ?? this.providers,
      session: clearSession ? null : (session ?? this.session),
      biometricSupported: biometricSupported ?? this.biometricSupported,
      biometricUnlockEnabled:
          biometricUnlockEnabled ?? this.biometricUnlockEnabled,
      requiresBiometricUnlock:
          requiresBiometricUnlock ?? this.requiresBiometricUnlock,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      magicLinkPreviewToken: clearMagicLinkPreviewToken
          ? null
          : (magicLinkPreviewToken ?? this.magicLinkPreviewToken),
      magicLinkEmail: clearMagicLinkEmail ? null : (magicLinkEmail ?? this.magicLinkEmail),
      magicLinkDelivery: clearMagicLinkDelivery
          ? null
          : (magicLinkDelivery ?? this.magicLinkDelivery),
      magicLinkExpiresAt: clearMagicLinkExpiresAt
          ? null
          : (magicLinkExpiresAt ?? this.magicLinkExpiresAt),
      magicLinkVerificationUrl: clearMagicLinkVerificationUrl
          ? null
          : (magicLinkVerificationUrl ?? this.magicLinkVerificationUrl),
    );
  }
}
