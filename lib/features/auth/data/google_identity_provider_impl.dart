import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/errors/app_exception.dart';
import '../domain/google_account_identity.dart';
import '../domain/google_identity_provider.dart';

class GoogleIdentityProviderImpl implements GoogleIdentityProvider {
  GoogleIdentityProviderImpl({
    String? clientId,
    String? serverClientId,
  }) : _googleSignIn = GoogleSignIn(
         scopes: const <String>['email', 'profile'],
         clientId: _normalize(clientId),
         serverClientId: _normalize(serverClientId),
       );

  final GoogleSignIn _googleSignIn;

  @override
  Future<GoogleAccountIdentity> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw const AppException(
          'auth_google_cancelled',
          'Google Sign-In was cancelled before completing the access flow.',
        );
      }

      final authentication = await account.authentication;
      final idToken = authentication.idToken?.trim() ?? '';
      if (idToken.isEmpty) {
        throw const AppException(
          'auth_google_missing_id_token',
          'Google Sign-In did not return a valid ID token for backend verification.',
        );
      }

      final email = account.email.trim().toLowerCase();
      if (email.isEmpty) {
        throw const AppException(
          'auth_google_missing_email',
          'Google Sign-In did not return an email for this account.',
        );
      }

      return GoogleAccountIdentity(
        idToken: idToken,
        email: email,
        displayName:
            (account.displayName ?? '').trim().isNotEmpty
                ? account.displayName!.trim()
                : email.split('@').first,
        providerSubject: account.id,
        avatarUrl: account.photoUrl?.trim() ?? '',
      );
    } on AppException {
      rethrow;
    } catch (error) {
      throw AppException(
        'auth_google_interactive_failed',
        'No se pudo completar Google Sign-In en este dispositivo.',
        logContext: <String, Object?>{
          'runtimeType': error.runtimeType.toString(),
        },
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  static String? _normalize(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }
}
