import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/errors/app_exception.dart';
import '../../../core/logging/app_logger.dart';
import '../../inventory/data/inventory_repository.dart';
import '../../shadows/data/shadow_progression_repository.dart';
import '../../player/data/player_api_client.dart';
import '../domain/daily_quest.dart';
import '../domain/hunter_profile.dart';
import 'local_player_state_repository.dart';

class RemoteHomeSnapshot {
  const RemoteHomeSnapshot({
    required this.profile,
    required this.selectedStageIndex,
    required this.quests,
    required this.inventory,
    required this.unlockedShadowIds,
    required this.completedDays,
  });

  final HunterProfile profile;
  final int selectedStageIndex;
  final List<DailyQuest> quests;
  final Map<String, int> inventory;
  final List<String> unlockedShadowIds;
  final int completedDays;
}

class RemoteCoreSnapshot {
  const RemoteCoreSnapshot({
    required this.profile,
    required this.selectedStageIndex,
    required this.quests,
    required this.completedDays,
  });

  final HunterProfile profile;
  final int selectedStageIndex;
  final List<DailyQuest> quests;
  final int completedDays;
}

class HomeApiClient {
  HomeApiClient({
    required this.baseUrl,
    this.accessToken,
    http.Client? httpClient,
    PlayerApiClient? playerApiClient,
    LocalPlayerStateRepository? storage,
    AppLogger? logger,
    InventoryRepository? inventoryRepository,
    ShadowProgressionRepository? shadowProgressionRepository,
  })  : _httpClient = httpClient ?? http.Client(),
        _injectedPlayerApiClient = playerApiClient,
        _storage = storage,
        _logger = logger,
        _injectedInventoryRepository = inventoryRepository,
        _injectedShadowProgressionRepository = shadowProgressionRepository;

  final String baseUrl;
  final String? accessToken;
  final http.Client _httpClient;
  final PlayerApiClient? _injectedPlayerApiClient;
  final LocalPlayerStateRepository? _storage;
  final AppLogger? _logger;
  final InventoryRepository? _injectedInventoryRepository;
  final ShadowProgressionRepository? _injectedShadowProgressionRepository;
  PlayerApiClient? _ownedPlayerApiClient;
  InventoryRepository? _ownedInventoryRepository;
  ShadowProgressionRepository? _ownedShadowProgressionRepository;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> get _authHeaders {
    final token = accessToken;
    if (token == null || token.isEmpty) {
      return const <String, String>{};
    }
    return <String, String>{'Authorization': 'Bearer $token'};
  }

  PlayerApiClient get _playerApiClient {
    return _injectedPlayerApiClient ??
        (_ownedPlayerApiClient ??= PlayerApiClient(
          baseUrl: baseUrl,
          accessToken: accessToken,
          httpClient: _httpClient,
          disposeHttpClient: false,
        ));
  }

  InventoryRepository get _inventoryRepository {
    if (_injectedInventoryRepository != null) {
      return _injectedInventoryRepository;
    }
    final storage = _storage;
    final logger = _logger;
    if (storage == null || logger == null) {
      throw StateError(
        'InventoryRepository requiere storage y logger cuando no se inyecta manualmente.',
      );
    }
    return _ownedInventoryRepository ??= InventoryRepository.create(
      baseUrl: baseUrl,
      logger: logger,
      storage: storage,
      accessToken: accessToken,
      httpClient: _httpClient,
    );
  }

  ShadowProgressionRepository get _shadowProgressionRepository {
    if (_injectedShadowProgressionRepository != null) {
      return _injectedShadowProgressionRepository;
    }
    final storage = _storage;
    final logger = _logger;
    if (storage == null || logger == null) {
      throw StateError(
        'ShadowProgressionRepository requiere storage y logger cuando no se inyecta manualmente.',
      );
    }
    return _ownedShadowProgressionRepository ??= ShadowProgressionRepository.create(
      baseUrl: baseUrl,
      logger: logger,
      storage: storage,
      accessToken: accessToken,
      httpClient: _httpClient,
    );
  }

  Future<RemoteHomeSnapshot> fetchSnapshot() async {
    final coreSnapshot = await fetchCoreSnapshot();
    final inventoryResult = await _inventoryRepository.refresh();
    final shadowResult = await _shadowProgressionRepository.refresh();

    return RemoteHomeSnapshot(
      profile: coreSnapshot.profile.copyWith(
        shadowArmy: shadowResult.shadowArmy,
      ),
      selectedStageIndex: coreSnapshot.selectedStageIndex,
      quests: coreSnapshot.quests,
      inventory: inventoryResult.items,
      unlockedShadowIds: shadowResult.unlockedShadowIds,
      completedDays: coreSnapshot.completedDays,
    );
  }

  Future<RemoteCoreSnapshot> fetchCoreSnapshot() async {
    final playerJson = await _playerApiClient.fetchPlayerJson();
    final questsResponse = await _httpClient.get(
      _uri('/api/v1/quests/today'),
      headers: _authHeaders,
    );

    if (questsResponse.statusCode != 200) {
      throw Exception('No se pudieron obtener las quests remotas.');
    }

    final questsJson = jsonDecode(questsResponse.body) as Map<String, dynamic>;

    return RemoteCoreSnapshot(
      profile: _profileFromPlayer(playerJson['player'] as Map<String, dynamic>),
      selectedStageIndex:
          ((playerJson['stage'] as Map<String, dynamic>)['index'] as int) - 1,
      quests: ((questsJson['quests'] as List<dynamic>))
          .map((quest) => _questFromApi(quest as Map<String, dynamic>))
          .toList(),
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
      headers: {'Content-Type': 'application/json', ..._authHeaders},
      body: jsonEncode({'amount': amount}),
    );

    _throwIfRequestFailed(
      response,
      fallbackCode: 'quest_sync_failed',
      fallbackMessage: 'No se pudo avanzar la mision remota.',
    );
  }

  Future<void> completeQuest(String questId) async {
    final response = await _httpClient.post(
      _uri('/api/v1/quests/$questId/complete'),
      headers: _authHeaders,
    );
    _throwIfRequestFailed(
      response,
      fallbackCode: 'quest_complete_failed',
      fallbackMessage: 'No se pudo completar la mision remota.',
    );
  }

  Future<void> syncInventory(Map<String, int> inventory) async {
    await _inventoryRepository.sync(inventory);
  }

  Future<void> syncShadowProgression({
    required int shadowArmy,
    required List<String> unlockedShadowIds,
  }) async {
    await _shadowProgressionRepository.sync(
      shadowArmy: shadowArmy,
      unlockedShadowIds: unlockedShadowIds,
    );
  }

  HunterProfile _profileFromPlayer(
    Map<String, dynamic> json, {
    int? shadowArmy,
  }) {
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
      shadowArmy: shadowArmy ?? json['shadowArmy'] as int,
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
  void _throwIfRequestFailed(
    http.Response response, {
      required String fallbackCode,
    required String fallbackMessage,
  }) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final errorJson = decoded['error'];
        if (errorJson is Map<String, dynamic>) {
          final code = errorJson['code'];
          final message = errorJson['message'];
          if (code is String && message is String) {
            throw AppException(code, message);
          }
        }
      }
    } catch (error) {
      if (error is AppException) {
        rethrow;
      }
    }

    throw AppException(fallbackCode, fallbackMessage);
  }

  void dispose() {
    _ownedPlayerApiClient?.dispose();
    _ownedInventoryRepository = null;
    _ownedShadowProgressionRepository = null;
    _httpClient.close();
  }
}
