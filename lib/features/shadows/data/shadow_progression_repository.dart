import 'package:http/http.dart' as http;

import '../../../core/logging/app_logger.dart';
import '../../home/data/local_player_state_repository.dart';
import '../domain/shadow_progression_sync_result.dart';
import 'shadow_progression_api_client.dart';
import 'shadow_progression_local_data_source.dart';

class ShadowProgressionRepository {
  ShadowProgressionRepository({
    required ShadowProgressionApiClient apiClient,
    required ShadowProgressionLocalDataSource localDataSource,
    required AppLogger logger,
  })  : _apiClient = apiClient,
        _localDataSource = localDataSource,
        _logger = logger;

  factory ShadowProgressionRepository.create({
    required String baseUrl,
    required AppLogger logger,
    required LocalPlayerStateRepository storage,
    http.Client? httpClient,
  }) {
    final apiClient = ShadowProgressionApiClient(
      baseUrl: baseUrl,
      httpClient: httpClient,
      disposeHttpClient: false,
    );
    return ShadowProgressionRepository(
      apiClient: apiClient,
      localDataSource: ShadowProgressionLocalDataSource(storage: storage),
      logger: logger,
    );
  }

  final ShadowProgressionApiClient _apiClient;
  final ShadowProgressionLocalDataSource _localDataSource;
  final AppLogger _logger;

  Future<ShadowProgressionSyncResult> refresh() async {
    _logger.info(event: 'refresh_started', source: 'shadows.repository');
    try {
      final remote = await _apiClient.fetchProgression();
      final result = ShadowProgressionSyncResult(
        shadowArmy: remote.shadowArmy,
        unlockedShadowIds: remote.unlockedShadowIds,
        source: ShadowProgressionSyncSource.remote,
        contractVersion: remote.contractVersion,
      );
      await _persistCache(result);
      _logger.info(
        event: 'refresh_remote_success',
        source: 'shadows.repository',
        context: <String, Object?>{
          'contractVersion': result.contractVersion,
          'shadowArmy': result.shadowArmy,
          'unlockedCount': result.unlockedShadowIds.length,
        },
      );
      _logSourceSelected(result);
      return result;
    } catch (error) {
      _logger.warning(
        event: 'refresh_remote_failed',
        source: 'shadows.repository',
        context: <String, Object?>{'error': error.toString()},
      );
      final fallback = await _localDataSource.loadSnapshot();
      if (fallback != null) {
        _logger.warning(
          event: 'refresh_local_fallback',
          source: 'shadows.repository',
          context: <String, Object?>{
            'selectedSource': fallback.source.name,
            'contractVersion': fallback.contractVersion,
          },
        );
        _logSourceSelected(fallback);
        return fallback;
      }
      rethrow;
    }
  }

  Future<ShadowProgressionSyncResult> sync({
    required int shadowArmy,
    required List<String> unlockedShadowIds,
  }) async {
    _logger.info(
      event: 'sync_started',
      source: 'shadows.repository',
      context: <String, Object?>{
        'shadowArmy': shadowArmy,
        'unlockedCount': unlockedShadowIds.length,
      },
    );
    final remote = await _apiClient.syncProgression(
      shadowArmy: shadowArmy,
      unlockedShadowIds: unlockedShadowIds,
    );
    final result = ShadowProgressionSyncResult(
      shadowArmy: remote.shadowArmy,
      unlockedShadowIds: remote.unlockedShadowIds,
      source: ShadowProgressionSyncSource.remote,
      contractVersion: remote.contractVersion,
    );
    await _persistCache(result);
    _logger.info(
      event: 'sync_succeeded',
      source: 'shadows.repository',
      context: <String, Object?>{
        'contractVersion': result.contractVersion,
        'shadowArmy': result.shadowArmy,
        'unlockedCount': result.unlockedShadowIds.length,
      },
    );
    _logSourceSelected(result);
    return result;
  }

  Future<void> _persistCache(ShadowProgressionSyncResult result) async {
    try {
      await _localDataSource.saveSnapshot(
        shadowArmy: result.shadowArmy,
        unlockedShadowIds: result.unlockedShadowIds,
        contractVersion: result.contractVersion,
      );
      _logger.info(
        event: 'cache_updated',
        source: 'shadows.repository',
        context: <String, Object?>{
          'contractVersion': result.contractVersion,
        },
      );
    } catch (error) {
      _logger.warning(
        event: 'cache_update_failed',
        source: 'shadows.repository',
        context: <String, Object?>{
          'contractVersion': result.contractVersion,
          'error': error.toString(),
        },
      );
    }
  }

  void _logSourceSelected(ShadowProgressionSyncResult result) {
    _logger.info(
      event: 'source_selected',
      source: 'shadows.repository',
      context: <String, Object?>{
        'selectedSource': result.source.name,
        'usedFallback': result.usedFallback,
        'contractVersion': result.contractVersion,
      },
    );
  }
}
