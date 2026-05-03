import 'dart:async';

import 'package:flutter/foundation.dart';

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
  })  : _storage = storage,
        _system = system,
        _apiClient = apiClient;

  final LocalPlayerStateRepository _storage;
  final PlayerSystemService _system;
  final HomeApiClient? _apiClient;

  PlayerState? _playerState;
  bool _isLoading = true;
  int _selectedIndex = 0;
  int _previousIndex = 0;
  int? _levelUpNotice;
  String? _rewardNotice;
  String? _pendingUnlockedShadowId;
  List<String>? _pendingChestRewards;
  Timer? _levelUpTimer;
  Timer? _rewardNoticeTimer;

  bool get isLoading => _isLoading;
  int get selectedIndex => _selectedIndex;
  int get previousIndex => _previousIndex;
  int? get levelUpNotice => _levelUpNotice;
  String? get rewardNotice => _rewardNotice;
  String? get pendingUnlockedShadowId => _pendingUnlockedShadowId;
  List<String>? get pendingChestRewards => _pendingChestRewards;
  PlayerState? get playerState => _playerState;

  Future<void> load() async {
    final loaded = await _storage.load();
    final hydrated = _system.hydrate(loaded);
    _playerState = await _mergeRemoteSnapshot(hydrated.state);
    _isLoading = false;
    notifyListeners();

    for (final notice in hydrated.notices) {
      _handleNotice(notice);
    }
    await _storage.save(_playerState!);
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
    await _applyUpdate(_system.advanceQuest(state, quest));
    await _syncAdvanceQuest(quest);
  }

  Future<void> advanceSpecialQuest(DailyQuest quest) async {
    final state = _playerState;
    if (state == null) {
      return;
    }
    await _applyUpdate(_system.advanceSpecialQuest(state, quest));
  }

  Future<void> decideSpecialQuest(bool accept) async {
    final state = _playerState;
    if (state == null) {
      return;
    }
    await _applyUpdate(_system.decideSpecialQuest(state, accept));
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
    _levelUpNotice = null;
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
      _showLevelUp(update.levelUp!);
    }
    if (update.classChange != null) {
      _showRewardNotice('Clase del sistema actualizada: ${update.classChange}');
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

  Future<void> _persist(PlayerState state) async {
    _playerState = state;
    notifyListeners();
    await _storage.save(state);
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

  Future<void> _syncAdvanceQuest(DailyQuest quest) async {
    final apiClient = _apiClient;
    if (apiClient == null) {
      return;
    }

    try {
      await apiClient.advanceQuest(quest.id);
      final state = _playerState;
      if (state == null) {
        return;
      }
      final remoteState = await _mergeRemoteSnapshot(state);
      await _persist(remoteState);
    } catch (_) {
      _showRewardNotice('Progreso remoto no disponible');
    }
  }

  void _showLevelUp(int level) {
    _levelUpTimer?.cancel();
    _levelUpNotice = level;
    notifyListeners();

    _levelUpTimer = Timer(const Duration(milliseconds: 1800), () {
      _levelUpNotice = null;
      notifyListeners();
    });
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
    _levelUpTimer?.cancel();
    _rewardNoticeTimer?.cancel();
    _apiClient?.dispose();
    super.dispose();
  }
}
