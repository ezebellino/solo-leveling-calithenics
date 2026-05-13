class GoogleAccountIdentity {
  const GoogleAccountIdentity({
    required this.idToken,
    required this.email,
    required this.displayName,
    required this.providerSubject,
    required this.avatarUrl,
  });

  final String idToken;
  final String email;
  final String displayName;
  final String providerSubject;
  final String avatarUrl;
}
