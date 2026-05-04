import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'system_overlay_state.dart';

class SystemOverlayController extends Notifier<SystemOverlayState> {
  @override
  SystemOverlayState build() => const SystemOverlayState.initial();

  void syncFromGame({
    required bool playerAccepted,
    required bool jobChanged,
    required bool hasPendingClassEvolution,
    required bool hasPendingLevelUp,
    required bool hasRewardNotice,
  }) {
    final onboardingStep = _resolveOnboardingStep(
      playerAccepted: playerAccepted,
      jobChanged: jobChanged,
    );
    final visibleOverlay = _resolveVisibleOverlay(
      onboardingStep: onboardingStep,
      hasPendingClassEvolution: hasPendingClassEvolution,
      hasPendingLevelUp: hasPendingLevelUp,
      hasRewardNotice: hasRewardNotice,
    );

    final nextState = state.copyWith(
      onboardingStep: onboardingStep,
      visibleOverlay: visibleOverlay,
    );

    if (nextState.visibleOverlay == state.visibleOverlay &&
        nextState.onboardingStep == state.onboardingStep) {
      return;
    }

    state = nextState;
  }

  SystemOnboardingStep _resolveOnboardingStep({
    required bool playerAccepted,
    required bool jobChanged,
  }) {
    if (!playerAccepted) {
      return SystemOnboardingStep.acceptPlayer;
    }
    if (!jobChanged) {
      return SystemOnboardingStep.confirmInitialClass;
    }
    return SystemOnboardingStep.none;
  }

  SystemOverlayKind _resolveVisibleOverlay({
    required SystemOnboardingStep onboardingStep,
    required bool hasPendingClassEvolution,
    required bool hasPendingLevelUp,
    required bool hasRewardNotice,
  }) {
    if (onboardingStep != SystemOnboardingStep.none) {
      return SystemOverlayKind.onboarding;
    }
    if (hasPendingClassEvolution) {
      return SystemOverlayKind.classEvolution;
    }
    if (hasPendingLevelUp) {
      return SystemOverlayKind.levelUp;
    }
    if (hasRewardNotice) {
      return SystemOverlayKind.rewardNotice;
    }
    return SystemOverlayKind.none;
  }
}

final systemOverlayControllerProvider =
    NotifierProvider<SystemOverlayController, SystemOverlayState>(
      SystemOverlayController.new,
    );
