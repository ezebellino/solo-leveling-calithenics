import 'dart:io';

import 'app_exception.dart';

AppException mapToAppException(Object error) {
  if (error is AppException) {
    return error;
  }
  if (error is SocketException) {
    return const AppException(
      'network_unavailable',
      'No se pudo conectar al servidor.',
      isRetryable: true,
      logContext: <String, Object?>{
        'errorType': 'SocketException',
      },
    );
  }
  return AppException(
    'unknown_error',
    'Ocurrio un error inesperado.',
    isRetryable: false,
    logContext: <String, Object?>{
      'errorType': error.runtimeType.toString(),
      'error': error.toString(),
    },
  );
}
