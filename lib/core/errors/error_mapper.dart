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
    );
  }
  return const AppException(
    'unknown_error',
    'Ocurrio un error inesperado.',
  );
}
