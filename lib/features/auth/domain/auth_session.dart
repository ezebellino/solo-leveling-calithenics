class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.provider,
    required this.expiresAt,
    required this.userId,
    required this.displayName,
    required this.avatarUrl,
    this.email,
    this.sessionId,
  });

  final String accessToken;
  final String provider;
  final DateTime expiresAt;
  final String userId;
  final String displayName;
  final String avatarUrl;
  final String? email;
  final String? sessionId;
}
