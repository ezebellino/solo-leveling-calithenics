import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/core/logging/app_logger.dart';

void main() {
  group('AppLogger', () {
    test('buildRecord normalizes sync-critical observability fields', () {
      const logger = AppLogger();

      final record = logger.buildRecord(
        level: LogLevel.info,
        action: 'refresh',
        feature: 'inventory',
        source: 'inventory.repository',
        entityId: 'default-player',
        outcome: 'success',
        context: const <String, Object?>{'itemCount': 3},
      );

      expect(record['feature'], 'inventory');
      expect(record['action'], 'refresh');
      expect(record['source'], 'inventory.repository');
      expect(record['entityId'], 'default-player');
      expect(record['outcome'], 'success');
      expect(record['itemCount'], 3);
      expect(record['level'], 'info');
    });
  });
}
