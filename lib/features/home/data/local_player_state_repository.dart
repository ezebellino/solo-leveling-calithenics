import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/player_state.dart';

class LocalPlayerStateRepository {
  static const _storageKey = 'solo_leveling_player_state';

  Future<PlayerState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final json = jsonDecode(raw) as Map<String, Object?>;
    return PlayerState.fromJson(json);
  }

  Future<void> save(PlayerState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }
}
