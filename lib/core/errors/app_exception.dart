class AppException implements Exception {
  const AppException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}
