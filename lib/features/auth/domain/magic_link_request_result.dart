class MagicLinkRequestResult {
  const MagicLinkRequestResult({
    required this.email,
    required this.expiresAt,
    required this.delivery,
    this.previewToken,
  });

  final String email;
  final DateTime expiresAt;
  final String delivery;
  final String? previewToken;
}
