import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/features/system/application/system_overlay_controller.dart';
import 'package:solo_leveling_calisthenics/features/system/application/system_overlay_state.dart';

void main() {
  group('SystemOverlayController', () {
    test('shows onboarding accept player first', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(systemOverlayControllerProvider.notifier).syncFromGame(
        playerAccepted: false,
        jobChanged: false,
        hasPendingClassEvolution: true,
        hasPendingLevelUp: true,
        hasRewardNotice: true,
      );

      final state = container.read(systemOverlayControllerProvider);
      expect(state.visibleOverlay, SystemOverlayKind.onboarding);
      expect(state.onboardingStep, SystemOnboardingStep.acceptPlayer);
    });

    test('shows class confirmation onboarding step after player acceptance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(systemOverlayControllerProvider.notifier).syncFromGame(
        playerAccepted: true,
        jobChanged: false,
        hasPendingClassEvolution: false,
        hasPendingLevelUp: false,
        hasRewardNotice: false,
      );

      final state = container.read(systemOverlayControllerProvider);
      expect(state.visibleOverlay, SystemOverlayKind.onboarding);
      expect(state.onboardingStep, SystemOnboardingStep.confirmInitialClass);
    });

    test('prioritizes class evolution over level up and reward notice', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(systemOverlayControllerProvider.notifier).syncFromGame(
        playerAccepted: true,
        jobChanged: true,
        hasPendingClassEvolution: true,
        hasPendingLevelUp: true,
        hasRewardNotice: true,
      );

      final state = container.read(systemOverlayControllerProvider);
      expect(state.visibleOverlay, SystemOverlayKind.classEvolution);
      expect(state.onboardingStep, SystemOnboardingStep.none);
    });
  });
}
