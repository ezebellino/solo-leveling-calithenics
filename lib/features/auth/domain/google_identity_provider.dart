import 'google_account_identity.dart';

abstract class GoogleIdentityProvider {
  Future<GoogleAccountIdentity> signIn();

  Future<void> signOut();
}
