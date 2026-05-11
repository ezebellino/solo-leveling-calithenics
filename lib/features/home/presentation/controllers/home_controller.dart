import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/logging/app_logger.dart';
import '../../../player/domain/player_snapshot.dart';
import '../../data/home_api_client.dart';
import '../../data/local_player_state_repository.dart';
import '../../domain/daily_quest.dart';
import '../../domain/player_state.dart';
import '../../domain/player_system_service.dart';

class HomeController extends ChangeNotifier {
  HomeController({
    required LocalPlayerStateRepository storage,
    required PlayerSystemService system,
    HomeApiClient? apiClient,
    AppLogger? logger,
  })  : _storage = storage,
        _system = system,
        _apiClient = apiClient,
        _logger = logger;

  final LocalPlayerStateRepository _storage;
  final PlayerSystemService _system;
  final HomeApiClient? _apiClient;
  final AppLogger? _logger;

  PlayerState? _playerState;
  bool _isLoading = true;
  int _selectedIndex = 0;
  int _previousIndex = 0;
  int? _pendingLevelUp;
  ClassEvolutionNotice? _pendingClassEvolution;
  String? _rewardNotice;
  String? _pendingUnlockedShadowId;
  List<String>? _pendingChestRewards;
  Timer? _rewardNoticeTimer;

  bool get isLoading => _isLoading;
  int get selectedIndex => _selectedIndex;
  int get previousIndex => _previousIndex;
  int? get levelUpNotice => _pendingLevelUp;
  int? get pendingLevelUp => _pendingLevelUp;
  ClassEvolutionNotice? get pendingClassEvolution => _pendingClassEvolution;
  String? get rewardNotice => _rewardNotice;
  String? get pendingUnlockedShadowId => _pendingUnlockedShadowId;
  List<String>? get pendingChestRewards => _pendingChestRewards;
  PlayerState? get playerState => _playerState;

  Future<void> load({PlayerSnapshot? bootstrapSnapshot}) async {
    _logger?.info(
      event: 'bootstrap_hydration_started',
      source: 'home.controller',
      context: <String, Object?>{
        'hasBootstrapSnapshot': bootstrapSnapshot != null,
      },
    );

    try {
      final loaded = await _storage.load();
      final hydrated = _system.hydrate(loaded);
      final nextState = bootstrapSnapshot == null
          ? hydrated.state
          : hydrated.state.withBootstrapSnapshot(bootstrapSnapshot);

      _playerState = nextState;
      _isLoading = false;
      notifyListeners();

      for (final notice in hydrated.notices) {
        _handleNotice(notice);
      }
      await _storage.save(_playerState!);

      _logger?.info(
        event: 'bootstrap_hydration_succeeded',
        source: 'home.controller',
        context: <String, Object?>{
          'alias': _playerState!.profile.alias,
          'level': _playerState!.profile.level,
          'completedDays': _playerState!.completedDays,
        },
      );
    } catch (error) {
      _logger?.error(
        event: 'bootstrap_hydration_failed',
        source: 'home.controller',
        context: <String, Object?>{
          'error': error.toString(),
        },
      );
      rethrow;
    }
  }

  void selectTab(int index) {
    _previousIndex = _selectedIndex;
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> acceptPlayer() async {
    final state = _playerState;
    if (state == null) {
      return;
    }
    await _persist(state.copyWith(playerAccepted: true));
  }

  Future<void> confirmJobChanged() async {
    final state = _playerState;
    if (state == null) {
      return;
    }
    await _persist(state.copyWith(jobChanged: true));
  }

  Future<void> changeStage(int index) async {
    final state = _playerState;
    if (state == null) {
      return;
    }
    await _applyUpdate(_system.changeStage(state, index));
  }

  Future<void> advanceQuest(DailyQuest quest) async {
    final state = _playerState;
    if (state == null) {
      return;
    }
    final previousState = state;
    await _applyUpdate(_system.advanceQuest(state, quest));
    await _syncAdvanceQuest(quest, previousState: previousState);
  }

  Future<void> advanceSpecialQuest(DailyQuest quest) async {
    final state = _playerState;
    if (state == null) {
      return;
    }
    await _applyUpdate(_system.advanceSpecialQuest(state, quest));
    _logger?.info(
      event: 'special_quest_advanced_locally',
      source: 'home.controller',
      context: <String, Object?>{
        'questId': quest.id,
      },
    );
  }

  Future<void> decideSpecialQuest(bool accept) async {
    final state = _playerState;
    if (state == null) {
      return;
    }
    try {
      await _applyUpdate(_system.decideSpecialQuest(state, accept));
      _logger?.info(
        event: 'special_quest_decision_succeeded',
        source: 'home.controller',
        context: <String, Object?>{
          'accept': accept,
          'status': _playerState?.weeklySpecialStatus,
          'syncMode': 'local_only',
        },
      );
    } catch (error, stackTrace) {
      _logger?.error(
        event: 'special_quest_decision_failed',
        source: 'home.controller',
        context: <String, Object?>{
          'accept': accept,
          'error': error.toString(),
          'stackTrace': stackTrace.toString(),
        },
      );
      rethrow;
    }
  }

  Future<void> useXpBoost() async {
    final state = _playerState;
    if (state == null) {
      return;
    }
    await _applyUpdate(_system.useXpBoost(state));
  }

  Future<void> updateAvatarUrl(String avatarUrl) async {
    final state = _playerState;
    if (state == null) {
      return;
    }
    final sanitized = avatarUrl.trim();
    await _persist(
      state.copyWith(
        profile: state.profile.copyWith(
          avatarUrl: sanitized,
          avatarImageBase64: sanitized.isEmpty ? '' : state.profile.avatarImageBase64,
        ),
      ),
    );
    _showRewardNotice(
      sanitized.isEmpty
          ? 'Avatar removido del perfil'
          : 'Avatar actualizado en el perfil',
    );
    await _syncAvatar(sanitized);
  }

  Future<void> updateAvatarImageBase64(String avatarImageBase64) async {
    final state = _playerState;
    if (state == null) {
      return;
    }
    await _persist(
      state.copyWith(
        profile: state.profile.copyWith(
          avatarImageBase64: avatarImageBase64,
          avatarUrl: '',
        ),
      ),
    );
    _showRewardNotice(
      avatarImageBase64.isEmpty
          ? 'Avatar local removido'
          : 'Avatar local actualizado',
    );
  }

  Future<void> useReroll() async {
    final state = _playerState;
    if (state == null) {
      return;
    }
    await _applyUpdate(_system.useReroll(state));
  }

  Future<void> resetProgress() async {
    await _applyUpdate(_system.resetProgress());
    _selectedIndex = 0;
    _previousIndex = 0;
    _pendingLevelUp = null;
    _pendingClassEvolution = null;
    _pendingUnlockedShadowId = null;
    notifyListeners();
  }

  Future<void> _applyUpdate(PlayerSystemUpdate update) async {
    await _persist(update.state);
    if (update.state.lastUnlockedShadowId.isNotEmpty &&
        update.state.lastUnlockedShadowId != _pendingUnlockedShadowId) {
      _pendingUnlockedShadowId = update.state.lastUnlockedShadowId;
      notifyListeners();
    }
    if (update.levelUp != null) {
      _pendingLevelUp = update.levelUp;
    }
    if (update.classEvolution != null) {
      _pendingClassEvolution = update.classEvolution;
    }
    if (update.levelUp != null || update.classEvolution != null) {
      notifyListeners();
    }
    for (final notice in update.notices) {
      _handleNotice(notice);
    }
  }

  Future<void> clearUnlockedShadowNotice() async {
    final state = _playerState;
    if (_pendingUnlockedShadowId == null || state == null) {
      return;
    }
    _pendingUnlockedShadowId = null;
    _playerState = state.copyWith(lastUnlockedShadowId: '');
    await _storage.save(_playerState!);
    notifyListeners();
  }

  void clearChestRewardNotice() {
    if (_pendingChestRewards == null) {
      return;
    }
    _pendingChestRewards = null;
    notifyListeners();
  }

  void clearLevelUpNotice() {
    if (_pendingLevelUp == null) {
      return;
    }
    _pendingLevelUp = null;
    notifyListeners();
  }

  void clearClassEvolutionNotice() {
    if (_pendingClassEvolution == null) {
      return;
    }
    _pendingClassEvolution = null;
    notifyListeners();
  }

  Future<void> _persist(PlayerState state) async {
    _playerState = state;
    notifyListeners();
    try {
      await _storage.save(state);
    } catch (error, stackTrace) {
      _logger?.error(
        event: 'player_state_persist_failed',
        source: 'home.controller',
        context: <String, Object?>{
          'error': error.toString(),
          'stackTrace': stackTrace.toString(),
          'weeklySpecialStatus': state.weeklySpecialStatus,
        },
      );
      rethrow;
    }
  }

  Future<PlayerState> _mergeRemoteSnapshot(PlayerState fallback) async {
    final apiClient = _apiClient;
    if (apiClient == null) {
      return fallback;
    }

    try {
      final snapshot = await apiClient.fetchSnapshot();
      final remoteProfile = snapshot.profile;
      final localProfile = fallback.profile;
      final mergedProfile = localProfile.copyWith(
        alias: remoteProfile.alias,
        avatarUrl: remoteProfile.avatarUrl.isNotEmpty
            ? remoteProfile.avatarUrl
            : localProfile.avatarUrl,
        avatarImageBase64: localProfile.avatarImageBase64,
      );

      return fallback.copyWith(
        profile: mergedProfile,
      );
    } catch (_) {
      return fallback;
    }
  }

  Future<void> _syncAvatar(String avatarUrl) async {
    final apiClient = _apiClient;
    if (apiClient == null) {
      return;
    }

    try {
      await apiClient.updateAvatarUrl(avatarUrl);
    } catch (_) {
      _showRewardNotice('Avatar guardado solo en local');
    }
  }

  Future<void> _syncAdvanceQuest(
    DailyQuest quest, {
    required PlayerState previousState,
  }) async {
    final apiClient = _apiClient;
    if (apiClient == null) {
      return;
    }

    try {
      _logger?.info(
        event: 'quest_sync_started',
        source: 'home.controller',
        context: <String, Object?>{
          'questId': quest.id,
        },
      );
      await apiClient.advanceQuest(quest.id);
      final state = _playerState;
      if (state == null) {
        return;
      }
      final remoteState = await _mergeRemoteSnapshot(state);
      await _persist(remoteState);
      _logger?.info(
        event: 'quest_sync_succeeded',
        source: 'home.controller',
        context: <String, Object?>{
          'questId': quest.id,
        },
      );
    } catch (error) {
      _logger?.warning(
        event: 'quest_sync_failed',
        source: 'home.controller',
        context: <String, Object?>{
          'questId': quest.id,
          'error': error.toString(),
          'rollbackApplied': true,
        },
      );
      _clearTransientSyncState();
      await _persist(previousState);
      _showRewardNotice('El Sistema revirtio el avance por una falla de sincronizacion.');
    }
  }

  void _clearTransientSyncState() {
    _pendingLevelUp = null;
    _pendingClassEvolution = null;
    _pendingUnlockedShadowId = null;
    _pendingChestRewards = null;
    _rewardNoticeTimer?.cancel();
    _rewardNotice = null;
    notifyListeners();
  }

  void _showRewardNotice(String message) {
    _rewardNoticeTimer?.cancel();
    _rewardNotice = message;
    notifyListeners();

    _rewardNoticeTimer = Timer(const Duration(milliseconds: 2200), () {
      if (_rewardNotice == message) {
        _rewardNotice = null;
        notifyListeners();
      }
    });
  }

  void _handleNotice(String message) {
    final rewards = _parseChestRewards(message);
    if (rewards != null) {
      _pendingChestRewards = rewards;
      notifyListeners();
      return;
    }
    _showRewardNotice(message);
  }

  List<String>? _parseChestRewards(String message) {
    if (!message.startsWith('Cofre ')) {
      return null;
    }

    final separatorIndex = message.indexOf(':');
    if (separatorIndex == -1 || separatorIndex >= message.length - 1) {
      return const <String>['Recompensa del Sistema'];
    }

    final payload = message.substring(separatorIndex + 1).trim();
    if (payload.isEmpty) {
      return const <String>['Recompensa del Sistema'];
    }

    return payload
        .split(' + ')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  @override
  void dispose() {
    _rewardNoticeTimer?.cancel();
    _apiClient?.dispose();
    super.dispose();
  }
}
