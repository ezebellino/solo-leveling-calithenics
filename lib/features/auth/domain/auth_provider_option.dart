class AuthProviderOption {
  const AuthProviderOption({
    required this.code,
    required this.displayName,
    required this.transport,
  });

  final String code;
  final String displayName;
  final String transport;
}
