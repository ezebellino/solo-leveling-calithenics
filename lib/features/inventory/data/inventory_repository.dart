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
    String? accessToken,
    http.Client? httpClient,
  }) {
    final apiClient = InventoryApiClient(
      baseUrl: baseUrl,
      accessToken: accessToken,
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
    _logger.sync(
      feature: 'inventory',
      action: 'refresh',
      source: 'inventory.repository',
      outcome: 'started',
    );
    try {
      final remote = await _apiClient.fetchInventory();
      final result = InventorySyncResult(
        items: remote.items,
        source: InventorySyncSource.remote,
        contractVersion: remote.contractVersion,
      );
      await _persistCache(result);
      _logger.sync(
        feature: 'inventory',
        action: 'refresh',
        source: 'inventory.repository',
        outcome: 'succeeded',
        context: <String, Object?>{
          'selectedSource': result.source.name,
          'contractVersion': result.contractVersion,
          'itemCount': result.items.length,
        },
      );
      _logSourceSelected(result);
      return result;
    } catch (error) {
      _logger.sync(
        feature: 'inventory',
        action: 'refresh',
        source: 'inventory.repository',
        outcome: 'failed',
        level: LogLevel.warning,
        context: <String, Object?>{'error': error.toString()},
      );
      final fallback = await _localDataSource.loadSnapshot();
      if (fallback != null) {
        _logger.sync(
          feature: 'inventory',
          action: 'refresh',
          source: 'inventory.repository',
          outcome: 'fallback',
          level: LogLevel.warning,
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
    _logger.sync(
      feature: 'inventory',
      action: 'sync',
      source: 'inventory.repository',
      outcome: 'started',
      context: <String, Object?>{'itemCount': items.length},
    );
    final remote = await _apiClient.syncInventory(items);
    final result = InventorySyncResult(
      items: remote.items,
      source: InventorySyncSource.remote,
      contractVersion: remote.contractVersion,
    );
    await _persistCache(result);
    _logger.sync(
      feature: 'inventory',
      action: 'sync',
      source: 'inventory.repository',
      outcome: 'succeeded',
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
      _logger.sync(
        feature: 'inventory',
        action: 'cache_update',
        source: 'inventory.repository',
        outcome: 'succeeded',
        context: <String, Object?>{
          'contractVersion': result.contractVersion,
        },
      );
    } catch (error) {
      _logger.sync(
        feature: 'inventory',
        action: 'cache_update',
        source: 'inventory.repository',
        outcome: 'failed',
        level: LogLevel.warning,
        context: <String, Object?>{
          'contractVersion': result.contractVersion,
          'error': error.toString(),
        },
      );
    }
  }

  void _logSourceSelected(InventorySyncResult result) {
    _logger.sync(
      feature: 'inventory',
      action: 'source_selection',
      source: 'inventory.repository',
      outcome: result.source.name,
      context: <String, Object?>{
        'selectedSource': result.source.name,
        'usedFallback': result.usedFallback,
        'contractVersion': result.contractVersion,
      },
    );
  }
}
