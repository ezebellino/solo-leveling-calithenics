import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/features/app_shell/application/app_shell_controller.dart';
import 'package:solo_leveling_calisthenics/features/app_shell/application/app_shell_state.dart';

void main() {
  group('AppShellController', () {
    test('changes selected tab and tracks previous tab', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(appShellControllerProvider.notifier);

      controller.selectTab(2);

      final state = container.read(appShellControllerProvider);
      expect(state.selectedTabIndex, 2);
      expect(state.previousTabIndex, 0);
    });

    test('marks failed startup with message', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(appShellControllerProvider.notifier);

      controller.markFailed('boom');

      final state = container.read(appShellControllerProvider);
      expect(state.startupPhase, AppShellStartupPhase.failed);
      expect(state.startupErrorMessage, 'boom');
    });

    test('prioritizes overlay visibility correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(appShellControllerProvider.notifier);

      controller.syncVisibleOverlay(
        playerAccepted: true,
        jobChanged: true,
        hasPendingClassEvolution: false,
        hasPendingUnlockedShadow: true,
        hasPendingChestRewards: true,
        hasPendingLevelUp: true,
        hasRewardNotice: true,
      );

      expect(
        container.read(appShellControllerProvider).visibleOverlay,
        AppShellOverlayKind.shadowUnlock,
      );
    });
  });
}
