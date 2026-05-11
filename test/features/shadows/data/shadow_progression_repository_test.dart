import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solo_leveling_calisthenics/core/logging/app_logger.dart';
import 'package:solo_leveling_calisthenics/features/home/data/local_player_state_repository.dart';
import 'package:solo_leveling_calisthenics/features/shadows/data/shadow_progression_api_client.dart';
import 'package:solo_leveling_calisthenics/features/shadows/data/shadow_progression_local_data_source.dart';
import 'package:solo_leveling_calisthenics/features/shadows/data/shadow_progression_repository.dart';
import 'package:solo_leveling_calisthenics/features/shadows/domain/shadow_progression_sync_result.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ShadowProgressionRepository', () {
    test('refresh returns remote shadow progression and updates cache', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final repository = ShadowProgressionRepository(
        apiClient: ShadowProgressionApiClient(
          baseUrl: 'https://example.com',
          httpClient: MockClient((request) async {
            expect(request.url.path, '/api/v1/shadows/progression');
            return http.Response(
              '''
              {
                "shadowArmy": 2,
                "unlockedShadows": [
                  {"code":"igris","obtainedAt":"2026-05-11T10:00:00Z"},
                  {"code":"tank","obtainedAt":"2026-05-11T10:01:00Z"}
                ],
                "sync": {
                  "contractVersion":"2026-05-11.shadows.v1",
                  "authoritativeSource":"remote",
                  "fallbackPolicy":"local_cache_on_remote_failure",
                  "durableFields":["shadowArmy","unlockedShadows[].code","unlockedShadows[].obtainedAt"]
                }
              }
              ''',
              200,
            );
          }),
          disposeHttpClient: false,
        ),
        localDataSource: ShadowProgressionLocalDataSource(
          storage: _FakeLocalPlayerStateRepository(),
        ),
        logger: const AppLogger(),
      );

      final result = await repository.refresh();

      expect(result.source, ShadowProgressionSyncSource.remote);
      expect(result.shadowArmy, 2);
      expect(result.unlockedShadowIds, ['igris', 'tank']);

      final cached = await ShadowProgressionLocalDataSource(
        storage: _FakeLocalPlayerStateRepository(),
      ).loadSnapshot();
      expect(cached?.shadowArmy, 2);
      expect(cached?.source, ShadowProgressionSyncSource.localCache);
    });

    test('refresh falls back to cached shadow progression when remote fails', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'solo_leveling_shadow_progression_cache':
            '{"contractVersion":"2026-05-11.shadows.v1","shadowArmy":3,"unlockedShadowIds":["igris","tank","iron"]}',
      });
      final repository = ShadowProgressionRepository(
        apiClient: ShadowProgressionApiClient(
          baseUrl: 'https://example.com',
          httpClient: MockClient((request) async {
            return http.Response('{"error":{"code":"offline","message":"offline"}}', 503);
          }),
          disposeHttpClient: false,
        ),
        localDataSource: ShadowProgressionLocalDataSource(
          storage: _FakeLocalPlayerStateRepository(),
        ),
        logger: const AppLogger(),
      );

      final result = await repository.refresh();

      expect(result.source, ShadowProgressionSyncSource.localCache);
      expect(result.shadowArmy, 3);
      expect(result.unlockedShadowIds, ['igris', 'tank', 'iron']);
    });
  });
}

class _FakeLocalPlayerStateRepository extends LocalPlayerStateRepository {}
