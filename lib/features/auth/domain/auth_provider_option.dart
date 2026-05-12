class AuthProviderOption {
  const AuthProviderOption({
    required this.code,
    required this.displayName,
    required this.transport,
    required this.availability,
    this.statusMessage,
    this.requiresManualCompletion = false,
  });

  final String code;
  final String displayName;
  final String transport;
  final String availability;
  final String? statusMessage;
  final bool requiresManualCompletion;
}
