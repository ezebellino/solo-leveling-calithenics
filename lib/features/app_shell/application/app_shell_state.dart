enum AppShellStartupPhase { bootstrapping, ready, failed }

enum AppShellOverlayKind {
  none,
  onboarding,
  classEvolution,
  rewardNotice,
  chestReward,
  shadowUnlock,
  levelUp,
}

class AppShellState {
  const AppShellState({
    required this.selectedTabIndex,
    required this.previousTabIndex,
    required this.startupPhase,
    required this.visibleOverlay,
    this.startupErrorMessage,
  });

  const AppShellState.initial()
    : selectedTabIndex = 0,
      previousTabIndex = 0,
      startupPhase = AppShellStartupPhase.bootstrapping,
      visibleOverlay = AppShellOverlayKind.none,
      startupErrorMessage = null;

  final int selectedTabIndex;
  final int previousTabIndex;
  final AppShellStartupPhase startupPhase;
  final AppShellOverlayKind visibleOverlay;
  final String? startupErrorMessage;

  AppShellState copyWith({
    int? selectedTabIndex,
    int? previousTabIndex,
    AppShellStartupPhase? startupPhase,
    AppShellOverlayKind? visibleOverlay,
    String? startupErrorMessage,
    bool clearStartupErrorMessage = false,
  }) {
    return AppShellState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      previousTabIndex: previousTabIndex ?? this.previousTabIndex,
      startupPhase: startupPhase ?? this.startupPhase,
      visibleOverlay: visibleOverlay ?? this.visibleOverlay,
      startupErrorMessage: clearStartupErrorMessage
          ? null
          : startupErrorMessage ?? this.startupErrorMessage,
    );
  }
}
