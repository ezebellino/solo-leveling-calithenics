class AppException implements Exception {
  const AppException(
    this.code,
    this.message, {
    this.isRetryable = false,
    this.logContext = const <String, Object?>{},
  });

  final String code;
  final String message;
  final bool isRetryable;
  final Map<String, Object?> logContext;

  @override
  String toString() =>
      'AppException(code: $code, message: $message, isRetryable: $isRetryable, logContext: $logContext)';
}
