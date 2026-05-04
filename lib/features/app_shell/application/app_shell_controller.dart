import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_shell_state.dart';

class AppShellController extends Notifier<AppShellState> {
  @override
  AppShellState build() => const AppShellState.initial();

  void selectTab(int index) {
    if (index == state.selectedTabIndex) {
      return;
    }
    state = state.copyWith(
      previousTabIndex: state.selectedTabIndex,
      selectedTabIndex: index,
    );
  }

  void markBootstrapping() {
    state = state.copyWith(
      startupPhase: AppShellStartupPhase.bootstrapping,
      visibleOverlay: AppShellOverlayKind.none,
      clearStartupErrorMessage: true,
    );
  }

  void markReady() {
    state = state.copyWith(
      startupPhase: AppShellStartupPhase.ready,
      clearStartupErrorMessage: true,
    );
  }

  void markFailed(String message) {
    state = state.copyWith(
      startupPhase: AppShellStartupPhase.failed,
      startupErrorMessage: message,
      visibleOverlay: AppShellOverlayKind.none,
    );
  }

  void syncVisibleOverlay({
    required bool playerAccepted,
    required bool jobChanged,
    required bool hasPendingClassEvolution,
    required bool hasPendingUnlockedShadow,
    required bool hasPendingChestRewards,
    required bool hasPendingLevelUp,
    required bool hasRewardNotice,
  }) {
    final nextOverlay = _resolveOverlay(
      playerAccepted: playerAccepted,
      jobChanged: jobChanged,
      hasPendingClassEvolution: hasPendingClassEvolution,
      hasPendingUnlockedShadow: hasPendingUnlockedShadow,
      hasPendingChestRewards: hasPendingChestRewards,
      hasPendingLevelUp: hasPendingLevelUp,
      hasRewardNotice: hasRewardNotice,
    );

    if (nextOverlay == state.visibleOverlay) {
      return;
    }

    state = state.copyWith(visibleOverlay: nextOverlay);
  }

  AppShellOverlayKind _resolveOverlay({
    required bool playerAccepted,
    required bool jobChanged,
    required bool hasPendingClassEvolution,
    required bool hasPendingUnlockedShadow,
    required bool hasPendingChestRewards,
    required bool hasPendingLevelUp,
    required bool hasRewardNotice,
  }) {
    if (!playerAccepted || !jobChanged) {
      return AppShellOverlayKind.onboarding;
    }
    if (hasPendingClassEvolution) {
      return AppShellOverlayKind.classEvolution;
    }
    if (hasPendingUnlockedShadow) {
      return AppShellOverlayKind.shadowUnlock;
    }
    if (hasPendingChestRewards) {
      return AppShellOverlayKind.chestReward;
    }
    if (hasPendingLevelUp) {
      return AppShellOverlayKind.levelUp;
    }
    if (hasRewardNotice) {
      return AppShellOverlayKind.rewardNotice;
    }
    return AppShellOverlayKind.none;
  }
}

final appShellControllerProvider =
    NotifierProvider<AppShellController, AppShellState>(
      AppShellController.new,
    );
