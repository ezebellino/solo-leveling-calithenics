import '../domain/auth_provider_option.dart';
import '../domain/auth_session.dart';

class AuthSessionState {
  const AuthSessionState({
    this.isRestoring = false,
    this.isSubmitting = false,
    this.providers = const <AuthProviderOption>[],
    this.session,
    this.errorMessage,
    this.magicLinkPreviewToken,
    this.magicLinkEmail,
  });

  final bool isRestoring;
  final bool isSubmitting;
  final List<AuthProviderOption> providers;
  final AuthSession? session;
  final String? errorMessage;
  final String? magicLinkPreviewToken;
  final String? magicLinkEmail;

  bool get isAuthenticated => session != null;

  AuthSessionState copyWith({
    bool? isRestoring,
    bool? isSubmitting,
    List<AuthProviderOption>? providers,
    AuthSession? session,
    String? errorMessage,
    String? magicLinkPreviewToken,
    String? magicLinkEmail,
    bool clearSession = false,
    bool clearErrorMessage = false,
    bool clearMagicLinkPreviewToken = false,
    bool clearMagicLinkEmail = false,
  }) {
    return AuthSessionState(
      isRestoring: isRestoring ?? this.isRestoring,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      providers: providers ?? this.providers,
      session: clearSession ? null : (session ?? this.session),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      magicLinkPreviewToken: clearMagicLinkPreviewToken
          ? null
          : (magicLinkPreviewToken ?? this.magicLinkPreviewToken),
      magicLinkEmail: clearMagicLinkEmail ? null : (magicLinkEmail ?? this.magicLinkEmail),
    );
  }
}
