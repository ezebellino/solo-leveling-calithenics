import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_calisthenics/core/logging/app_logger.dart';
import 'package:solo_leveling_calisthenics/features/home/data/local_player_state_repository.dart';
import 'package:solo_leveling_calisthenics/features/inventory/data/inventory_api_client.dart';
import 'package:solo_leveling_calisthenics/features/inventory/data/inventory_local_data_source.dart';
import 'package:solo_leveling_calisthenics/features/inventory/data/inventory_repository.dart';
import 'package:solo_leveling_calisthenics/features/inventory/domain/inventory_sync_result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InventoryRepository', () {
    test('refresh returns remote inventory and updates cache', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final repository = InventoryRepository(
        apiClient: InventoryApiClient(
          baseUrl: 'https://example.com',
          httpClient: MockClient((request) async {
            expect(request.url.path, '/api/v1/inventory');
            return http.Response(
              '''
              {
                "items": [
                  {"code":"streak_freeze","name":"Freeze de racha","quantity":2},
                  {"code":"xp_boost","name":"Boost de XP","quantity":1},
                  {"code":"quest_reroll","name":"Re-roll de mision","quantity":0}
                ],
                "sync": {
                  "contractVersion":"2026-05-11.inventory.v1",
                  "authoritativeSource":"remote",
                  "fallbackPolicy":"local_cache_on_remote_failure",
                  "durableFields":["items[].code","items[].quantity"]
                }
              }
              ''',
              200,
            );
          }),
          disposeHttpClient: false,
        ),
        localDataSource: InventoryLocalDataSource(storage: _FakeLocalPlayerStateRepository()),
        logger: const AppLogger(),
      );

      final result = await repository.refresh();

      expect(result.source, InventorySyncSource.remote);
      expect(result.items, <String, int>{
        'freeze': 2,
        'xp_boost': 1,
        'reroll': 0,
      });

      final cached = await InventoryLocalDataSource(
        storage: _FakeLocalPlayerStateRepository(),
      ).loadSnapshot();
      expect(cached?.items['freeze'], 2);
      expect(cached?.source, InventorySyncSource.localCache);
    });

    test('refresh falls back to cached inventory when remote fails', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'solo_leveling_inventory_cache':
            '{"contractVersion":"2026-05-11.inventory.v1","items":{"freeze":5,"xp_boost":3,"reroll":1}}',
      });
      final repository = InventoryRepository(
        apiClient: InventoryApiClient(
          baseUrl: 'https://example.com',
          httpClient: MockClient((request) async {
            return http.Response('{"error":{"code":"offline","message":"offline"}}', 503);
          }),
          disposeHttpClient: false,
        ),
        localDataSource: InventoryLocalDataSource(storage: _FakeLocalPlayerStateRepository()),
        logger: const AppLogger(),
      );

      final result = await repository.refresh();

      expect(result.source, InventorySyncSource.localCache);
      expect(result.items, <String, int>{
        'freeze': 5,
        'xp_boost': 3,
        'reroll': 1,
      });
    });
  });
}

class _FakeLocalPlayerStateRepository extends LocalPlayerStateRepository {}
