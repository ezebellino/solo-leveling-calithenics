import 'auth_provider_option.dart';
import 'auth_session.dart';
import 'magic_link_request_result.dart';

abstract class AuthSessionRepository {
  Future<List<AuthProviderOption>> fetchProviders();

  Future<AuthSession?> restoreSession();

  Future<AuthSession> signInWithGoogle({
    required String email,
    required String displayName,
  });

  Future<MagicLinkRequestResult> requestMagicLink({
    required String email,
    String? displayName,
    String? redirectUrl,
  });

  Future<AuthSession> verifyMagicLink({
    required String token,
  });

  Future<void> signOut();
}
