import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/local_player_state_repository.dart';
import '../../domain/daily_quest.dart';
import '../../domain/player_state.dart';
import '../../domain/player_system_service.dart';

class HomeController extends ChangeNotifier {
  HomeController({
    required LocalPlayerStateRepository storage,
    required PlayerSystemService system,
  })  : _storage = storage,
        _system = system;

  final LocalPlayerStateRepository _storage;
  final PlayerSystemService _system;

  PlayerState? _playerState;
  bool _isLoading = true;
  int _selectedIndex = 0;
  int _previousIndex = 0;
  int? _levelUpNotice;
  String? _rewardNotice;
  Timer? _levelUpTimer;
  Timer? _rewardNoticeTimer;

  bool get isLoading => _isLoading;
  int get selectedIndex => _selectedIndex;
  int get previousIndex => _previousIndex;
  int? get levelUpNotice => _levelUpNotice;
  String? get rewardNotice => _rewardNotice;
  PlayerState? get playerState => _playerState;

  Future<void> load() async {
    final loaded = await _storage.load();
    final hydrated = _system.hydrate(loaded);
    _playerState = hydrated.state;
    _isLoading = false;
    notifyListeners();

    for (final notice in hydrated.notices) {
      _showRewardNotice(notice);
    }
    await _storage.save(hydrated.state);
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
    notifyListeners();
  }

  Future<void> _applyUpdate(PlayerSystemUpdate update) async {
    await _persist(update.state);
    if (update.levelUp != null) {
      _showLevelUp(update.levelUp!);
    }
    for (final notice in update.notices) {
      _showRewardNotice(notice);
    }
  }

  Future<void> _persist(PlayerState state) async {
    _playerState = state;
    notifyListeners();
    await _storage.save(state);
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

  @override
  void dispose() {
    _levelUpTimer?.cancel();
    _rewardNoticeTimer?.cancel();
    super.dispose();
  }
}
