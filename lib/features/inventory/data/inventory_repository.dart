import 'package:http/http.dart' as http;

import '../../../core/logging/app_logger.dart';
import '../../home/data/local_player_state_repository.dart';
import '../domain/inventory_sync_result.dart';
import 'inventory_api_client.dart';
import 'inventory_local_data_source.dart';

class InventoryRepository {
  InventoryRepository({
    required InventoryApiClient apiClient,
    required InventoryLocalDataSource localDataSource,
    required AppLogger logger,
  })  : _apiClient = apiClient,
        _localDataSource = localDataSource,
        _logger = logger;

  factory InventoryRepository.create({
    required String baseUrl,
    required AppLogger logger,
    required LocalPlayerStateRepository storage,
    http.Client? httpClient,
  }) {
    final apiClient = InventoryApiClient(
      baseUrl: baseUrl,
      httpClient: httpClient,
      disposeHttpClient: false,
    );
    return InventoryRepository(
      apiClient: apiClient,
      localDataSource: InventoryLocalDataSource(storage: storage),
      logger: logger,
    );
  }

  final InventoryApiClient _apiClient;
  final InventoryLocalDataSource _localDataSource;
  final AppLogger _logger;

  Future<InventorySyncResult> refresh() async {
    _logger.info(event: 'refresh_started', source: 'inventory.repository');
    try {
      final remote = await _apiClient.fetchInventory();
      final result = InventorySyncResult(
        items: remote.items,
        source: InventorySyncSource.remote,
        contractVersion: remote.contractVersion,
      );
      await _persistCache(result);
      _logger.info(
        event: 'refresh_remote_success',
        source: 'inventory.repository',
        context: <String, Object?>{
          'contractVersion': result.contractVersion,
          'itemCount': result.items.length,
        },
      );
      _logSourceSelected(result);
      return result;
    } catch (error) {
      _logger.warning(
        event: 'refresh_remote_failed',
        source: 'inventory.repository',
        context: <String, Object?>{'error': error.toString()},
      );
      final fallback = await _localDataSource.loadSnapshot();
      if (fallback != null) {
        _logger.warning(
          event: 'refresh_local_fallback',
          source: 'inventory.repository',
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

  Future<InventorySyncResult> sync(Map<String, int> items) async {
    _logger.info(
      event: 'sync_started',
      source: 'inventory.repository',
      context: <String, Object?>{'itemCount': items.length},
    );
    final remote = await _apiClient.syncInventory(items);
    final result = InventorySyncResult(
      items: remote.items,
      source: InventorySyncSource.remote,
      contractVersion: remote.contractVersion,
    );
    await _persistCache(result);
    _logger.info(
      event: 'sync_succeeded',
      source: 'inventory.repository',
      context: <String, Object?>{
        'contractVersion': result.contractVersion,
        'itemCount': result.items.length,
      },
    );
    _logSourceSelected(result);
    return result;
  }

  Future<void> _persistCache(InventorySyncResult result) async {
    try {
      await _localDataSource.saveSnapshot(
        result.items,
        contractVersion: result.contractVersion,
      );
      _logger.info(
        event: 'cache_updated',
        source: 'inventory.repository',
        context: <String, Object?>{
          'contractVersion': result.contractVersion,
        },
      );
    } catch (error) {
      _logger.warning(
        event: 'cache_update_failed',
        source: 'inventory.repository',
        context: <String, Object?>{
          'contractVersion': result.contractVersion,
          'error': error.toString(),
        },
      );
    }
  }

  void _logSourceSelected(InventorySyncResult result) {
    _logger.info(
      event: 'source_selected',
      source: 'inventory.repository',
      context: <String, Object?>{
        'selectedSource': result.source.name,
        'usedFallback': result.usedFallback,
        'contractVersion': result.contractVersion,
      },
    );
  }
}
