import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../home/data/local_player_state_repository.dart';
import '../domain/shadow_progression_sync_result.dart';

class ShadowProgressionLocalDataSource {
  static const _cacheKey = 'solo_leveling_shadow_progression_cache';

  const ShadowProgressionLocalDataSource({
    required LocalPlayerStateRepository storage,
  }) : _storage = storage;

  final LocalPlayerStateRepository _storage;

  Future<ShadowProgressionSyncResult?> loadSnapshot() async {
    final cached = await _loadDedicatedCache();
    if (cached != null) {
      return cached;
    }
    return _loadLegacySnapshot();
  }

  Future<void> saveSnapshot({
    required int shadowArmy,
    required List<String> unlockedShadowIds,
    required String contractVersion,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _cacheKey,
      jsonEncode(<String, Object?>{
        'contractVersion': contractVersion,
        'shadowArmy': shadowArmy,
        'unlockedShadowIds': unlockedShadowIds,
      }),
    );
  }

  Future<ShadowProgressionSyncResult?> _loadDedicatedCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    final unlockedJson = decoded['unlockedShadowIds'];
    final contractVersion = decoded['contractVersion'];
    if (unlockedJson is! List<dynamic> || contractVersion is! String) {
      return null;
    }

    return ShadowProgressionSyncResult(
      shadowArmy: decoded['shadowArmy'] as int? ?? 0,
      unlockedShadowIds: unlockedJson.cast<String>().toList(growable: false),
      source: ShadowProgressionSyncSource.localCache,
      contractVersion: contractVersion,
    );
  }

  Future<ShadowProgressionSyncResult?> _loadLegacySnapshot() async {
    final state = await _storage.load();
    if (state == null) {
      return null;
    }
    return ShadowProgressionSyncResult(
      shadowArmy: state.profile.shadowArmy,
      unlockedShadowIds: List<String>.from(state.unlockedShadowIds),
      source: ShadowProgressionSyncSource.legacyLocalState,
      contractVersion: 'legacy-home-state-v1',
    );
  }
}
