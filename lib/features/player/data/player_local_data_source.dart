import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../home/data/local_player_state_repository.dart';
import '../../home/domain/player_state.dart';
import '../domain/player_bootstrap_result.dart';
import '../domain/player_snapshot.dart';

final playerLocalDataSourceProvider = Provider<PlayerLocalDataSource>((ref) {
  return PlayerLocalDataSource(
    storage: ref.watch(localPlayerStateRepositoryProvider),
  );
});

class PlayerLocalDataSource {
  static const _bootstrapCacheKey = 'solo_leveling_player_bootstrap_cache';

  const PlayerLocalDataSource({
    required LocalPlayerStateRepository storage,
  }) : _storage = storage;

  final LocalPlayerStateRepository _storage;

  Future<PlayerBootstrapResult?> loadSnapshot() async {
    final cached = await _loadDedicatedCache();
    if (cached != null) {
      return cached;
    }

    return _loadLegacySnapshot();
  }

  Future<PlayerState?> loadLegacyPlayerState() {
    return _storage.load();
  }

  Future<void> saveSnapshot(
    PlayerSnapshot snapshot, {
    required String contractVersion,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = <String, Object?>{
      'contractVersion': contractVersion,
      'snapshot': <String, Object?>{
        'alias': snapshot.alias,
        'rank': snapshot.rank,
        'title': snapshot.title,
        'level': snapshot.level,
        'currentXp': snapshot.currentXp,
        'nextLevelXp': snapshot.nextLevelXp,
        'completedDays': snapshot.completedDays,
      },
    };

    await prefs.setString(_bootstrapCacheKey, jsonEncode(payload));
  }

  Future<PlayerBootstrapResult?> _loadDedicatedCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_bootstrapCacheKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final json = jsonDecode(raw);
    if (json is! Map<String, dynamic>) {
      return null;
    }

    final snapshotJson = json['snapshot'];
    final contractVersion = json['contractVersion'];
    if (snapshotJson is! Map<String, dynamic> || contractVersion is! String) {
      return null;
    }

    return PlayerBootstrapResult(
      snapshot: PlayerSnapshot(
        alias: snapshotJson['alias'] as String? ?? '',
        rank: snapshotJson['rank'] as String? ?? '',
        title: snapshotJson['title'] as String? ?? '',
        level: snapshotJson['level'] as int? ?? 0,
        currentXp: snapshotJson['currentXp'] as int? ?? 0,
        nextLevelXp: snapshotJson['nextLevelXp'] as int? ?? 0,
        completedDays: snapshotJson['completedDays'] as int? ?? 0,
      ),
      source: PlayerBootstrapSource.localCache,
      contractVersion: contractVersion,
    );
  }

  Future<PlayerBootstrapResult?> _loadLegacySnapshot() async {
    final state = await _storage.load();
    if (state == null) {
      return null;
    }

    final profile = state.profile;
    return PlayerBootstrapResult(
      snapshot: PlayerSnapshot(
        alias: profile.alias,
        rank: profile.rank,
        title: profile.title,
        level: profile.level,
        currentXp: profile.currentXp,
        nextLevelXp: profile.nextLevelXp,
        completedDays: state.completedDays,
      ),
      source: PlayerBootstrapSource.legacyLocalState,
      contractVersion: 'legacy-home-state-v1',
    );
  }
}
