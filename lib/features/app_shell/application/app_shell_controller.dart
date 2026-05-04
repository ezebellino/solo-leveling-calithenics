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
    );
  }
}

final appShellControllerProvider =
    NotifierProvider<AppShellController, AppShellState>(
      AppShellController.new,
    );
