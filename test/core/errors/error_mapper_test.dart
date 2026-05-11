import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/core/errors/app_exception.dart';
import 'package:solo_leveling_calisthenics/core/errors/error_mapper.dart';

void main() {
  group('mapToAppException', () {
    test('returns app exceptions unchanged', () {
      const exception = AppException('player_bootstrap_failed', 'No se pudo cargar.');

      final mapped = mapToAppException(exception);

      expect(identical(mapped, exception), isTrue);
    });

    test('maps socket exception to network unavailable', () {
      final mapped = mapToAppException(const SocketException('offline'));

      expect(mapped.code, 'network_unavailable');
      expect(mapped.message, 'No se pudo conectar al servidor.');
      expect(mapped.isRetryable, isTrue);
      expect(mapped.logContext['errorType'], 'SocketException');
    });

    test('maps unknown errors to generic app exception', () {
      final mapped = mapToAppException(StateError('boom'));

      expect(mapped.code, 'unknown_error');
      expect(mapped.message, 'Ocurrio un error inesperado.');
      expect(mapped.isRetryable, isFalse);
      expect(mapped.logContext['errorType'], 'StateError');
      expect(mapped.logContext['error'], contains('Bad state: boom'));
    });
  });
}
