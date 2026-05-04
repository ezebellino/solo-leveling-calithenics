import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../player/data/player_api_client.dart';
import '../domain/daily_quest.dart';
import '../domain/hunter_profile.dart';

class RemoteHomeSnapshot {
  const RemoteHomeSnapshot({
    required this.profile,
    required this.selectedStageIndex,
    required this.quests,
    required this.inventory,
    required this.completedDays,
  });

  final HunterProfile profile;
  final int selectedStageIndex;
  final List<DailyQuest> quests;
  final Map<String, int> inventory;
  final int completedDays;
}

class HomeApiClient {
  HomeApiClient({
    required this.baseUrl,
    http.Client? httpClient,
    PlayerApiClient? playerApiClient,
  })  : _httpClient = httpClient ?? http.Client(),
        _injectedPlayerApiClient = playerApiClient;

  final String baseUrl;
  final http.Client _httpClient;
  final PlayerApiClient? _injectedPlayerApiClient;
  PlayerApiClient? _ownedPlayerApiClient;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  PlayerApiClient get _playerApiClient {
    return _injectedPlayerApiClient ??
        (_ownedPlayerApiClient ??= PlayerApiClient(
          baseUrl: baseUrl,
          httpClient: _httpClient,
          disposeHttpClient: false,
        ));
  }

  Future<RemoteHomeSnapshot> fetchSnapshot() async {
    final playerJson = await _playerApiClient.fetchPlayerJson();
    final questsResponse = await _httpClient.get(_uri('/api/v1/quests/today'));

    if (questsResponse.statusCode != 200) {
      throw Exception('No se pudieron obtener las quests remotas.');
    }

    final questsJson = jsonDecode(questsResponse.body) as Map<String, dynamic>;

    return RemoteHomeSnapshot(
      profile: _profileFromPlayer(playerJson['player'] as Map<String, dynamic>),
      selectedStageIndex: ((playerJson['stage'] as Map<String, dynamic>)['index'] as int) - 1,
      quests: ((questsJson['quests'] as List<dynamic>))
          .map((quest) => _questFromApi(quest as Map<String, dynamic>))
          .toList(),
      inventory: ((playerJson['inventory'] as List<dynamic>))
          .cast<Map<String, dynamic>>()
          .fold<Map<String, int>>({}, (inventory, item) {
            inventory[_inventoryCodeToLocal(item['code'] as String)] = item['quantity'] as int;
            return inventory;
          }),
      completedDays: playerJson['completedDays'] as int? ?? 0,
    );
  }

  Future<void> updateAvatarUrl(String avatarUrl) async {
    await _playerApiClient.updatePlayerProgress(<String, dynamic>{
      'avatarUrl': avatarUrl,
    });
  }

  Future<void> advanceQuest(String questId, {int amount = 1}) async {
    final response = await _httpClient.post(
      _uri('/api/v1/quests/$questId/advance'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'amount': amount}),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('No se pudo avanzar la quest remota.');
    }
  }

  Future<void> completeQuest(String questId) async {
    final response = await _httpClient.post(_uri('/api/v1/quests/$questId/complete'));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('No se pudo completar la quest remota.');
    }
  }

  HunterProfile _profileFromPlayer(Map<String, dynamic> json) {
    return HunterProfile(
      alias: json['alias'] as String,
      avatarUrl: json['avatarUrl'] as String? ?? '',
      avatarImageBase64: '',
      rank: json['rank'] as String,
      title: json['title'] as String,
      level: json['level'] as int,
      currentXp: json['currentXp'] as int,
      nextLevelXp: json['nextLevelXp'] as int,
      streakDays: json['streakDays'] as int,
      shadowArmy: json['shadowArmy'] as int,
      strength: json['strength'] as int,
      agility: json['agility'] as int,
      endurance: json['endurance'] as int,
      discipline: json['discipline'] as int,
    );
  }

  DailyQuest _questFromApi(Map<String, dynamic> json) {
    return DailyQuest(
      id: json['id'] as String,
      title: json['title'] as String,
      detail: json['detail'] as String,
      rewardXp: json['rewardXp'] as int,
      progress: json['progress'] as int,
      target: json['target'] as int,
    );
  }

  String _inventoryCodeToLocal(String code) {
    switch (code) {
      case 'streak_freeze':
        return 'freeze';
      case 'quest_reroll':
        return 'reroll';
      default:
        return code;
    }
  }

  void dispose() {
    _ownedPlayerApiClient?.dispose();
    _httpClient.close();
  }
}
