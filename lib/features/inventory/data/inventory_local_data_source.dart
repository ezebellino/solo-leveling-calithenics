import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../home/data/local_player_state_repository.dart';
import '../domain/inventory_sync_result.dart';

class InventoryLocalDataSource {
  static const _cacheKey = 'solo_leveling_inventory_cache';

  const InventoryLocalDataSource({
    required LocalPlayerStateRepository storage,
  }) : _storage = storage;

  final LocalPlayerStateRepository _storage;

  Future<InventorySyncResult?> loadSnapshot() async {
    final cached = await _loadDedicatedCache();
    if (cached != null) {
      return cached;
    }
    return _loadLegacySnapshot();
  }

  Future<void> saveSnapshot(
    Map<String, int> items, {
    required String contractVersion,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey,
      jsonEncode(<String, Object?>{
        'contractVersion': contractVersion,
        'items': items,
      }),
    );
  }

  Future<InventorySyncResult?> _loadDedicatedCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    final itemsJson = decoded['items'];
    final contractVersion = decoded['contractVersion'];
    if (itemsJson is! Map<String, dynamic> || contractVersion is! String) {
      return null;
    }

    return InventorySyncResult(
      items: itemsJson.map(
        (key, value) => MapEntry(key, value is num ? value.toInt() : 0),
      ),
      source: InventorySyncSource.localCache,
      contractVersion: contractVersion,
    );
  }

  Future<InventorySyncResult?> _loadLegacySnapshot() async {
    final state = await _storage.load();
    if (state == null) {
      return null;
    }
    return InventorySyncResult(
      items: Map<String, int>.from(state.inventory),
      source: InventorySyncSource.legacyLocalState,
      contractVersion: 'legacy-home-state-v1',
    );
  }
}
