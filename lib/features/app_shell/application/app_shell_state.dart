enum AppShellStartupPhase { bootstrapping, ready, failed }

class AppShellState {
  const AppShellState({
    required this.selectedTabIndex,
    required this.previousTabIndex,
    required this.startupPhase,
    this.startupErrorMessage,
  });

  const AppShellState.initial()
    : selectedTabIndex = 0,
      previousTabIndex = 0,
      startupPhase = AppShellStartupPhase.bootstrapping,
      startupErrorMessage = null;

  final int selectedTabIndex;
  final int previousTabIndex;
  final AppShellStartupPhase startupPhase;
  final String? startupErrorMessage;

  AppShellState copyWith({
    int? selectedTabIndex,
    int? previousTabIndex,
    AppShellStartupPhase? startupPhase,
    String? startupErrorMessage,
    bool clearStartupErrorMessage = false,
  }) {
    return AppShellState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      previousTabIndex: previousTabIndex ?? this.previousTabIndex,
      startupPhase: startupPhase ?? this.startupPhase,
      startupErrorMessage: clearStartupErrorMessage
          ? null
          : startupErrorMessage ?? this.startupErrorMessage,
    );
  }
}
