enum SystemOverlayKind {
  none,
  onboarding,
  classEvolution,
  rewardNotice,
  levelUp,
}

enum SystemOnboardingStep {
  none,
  acceptPlayer,
  confirmInitialClass,
}

class SystemOverlayState {
  const SystemOverlayState({
    required this.visibleOverlay,
    required this.onboardingStep,
  });

  const SystemOverlayState.initial()
    : visibleOverlay = SystemOverlayKind.none,
      onboardingStep = SystemOnboardingStep.none;

  final SystemOverlayKind visibleOverlay;
  final SystemOnboardingStep onboardingStep;

  SystemOverlayState copyWith({
    SystemOverlayKind? visibleOverlay,
    SystemOnboardingStep? onboardingStep,
  }) {
    return SystemOverlayState(
      visibleOverlay: visibleOverlay ?? this.visibleOverlay,
      onboardingStep: onboardingStep ?? this.onboardingStep,
    );
  }
}
