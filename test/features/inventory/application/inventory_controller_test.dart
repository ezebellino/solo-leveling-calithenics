import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/features/inventory/application/inventory_action_handler.dart';
import 'package:solo_leveling_calisthenics/features/inventory/application/inventory_controller.dart';

void main() {
  group('InventoryController', () {
    test('syncs chest rewards into feature state', () {
      final container = ProviderContainer(
        overrides: [
          inventoryActionHandlerProvider.overrideWithValue(
            InventoryActionHandler(
              useXpBoost: () async {},
              useReroll: () async {},
              clearChestRewards: () {},
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      container
          .read(inventoryControllerProvider.notifier)
          .syncChestRewards(const ['Freeze', 'XP Boost']);

      final state = container.read(inventoryControllerProvider);
      expect(state.hasChestRewards, isTrue);
      expect(state.chestRewards, const ['Freeze', 'XP Boost']);
    });

    test('use xp boost delegates to handler and clears busy state', () async {
      var calls = 0;
      final container = ProviderContainer(
        overrides: [
          inventoryActionHandlerProvider.overrideWithValue(
            InventoryActionHandler(
              useXpBoost: () async {
                calls += 1;
              },
              useReroll: () async {},
              clearChestRewards: () {},
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(inventoryControllerProvider.notifier).useXpBoost();

      expect(calls, 1);
      final state = container.read(inventoryControllerProvider);
      expect(state.isSubmitting, isFalse);
      expect(state.activeActionKey, isNull);
    });
  });
}
