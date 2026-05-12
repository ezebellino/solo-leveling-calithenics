class MagicLinkRequestResult {
  const MagicLinkRequestResult({
    required this.email,
    required this.expiresAt,
    required this.delivery,
    required this.previewMode,
    this.previewToken,
    this.verificationUrl,
  });

  final String email;
  final DateTime expiresAt;
  final String delivery;
  final bool previewMode;
  final String? previewToken;
  final String? verificationUrl;
}
