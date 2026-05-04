import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'inventory_action_handler.dart';
import 'inventory_state.dart';

final inventoryActionHandlerProvider = Provider<InventoryActionHandler>((ref) {
  throw UnimplementedError('inventoryActionHandlerProvider must be overridden');
});

class InventoryController extends AutoDisposeNotifier<InventoryState> {
  @override
  InventoryState build() => const InventoryState();

  void syncChestRewards(List<String>? rewards) {
    final normalized = (rewards == null || rewards.isEmpty) ? null : rewards;
    if (_sameRewards(state.chestRewards, normalized)) {
      return;
    }
    state = state.copyWith(
      chestRewards: normalized,
      clearChestRewards: normalized == null,
    );
  }

  Future<void> useXpBoost() async {
    await _runAction(
      actionKey: 'inventory:xp_boost',
      operation: () => ref.read(inventoryActionHandlerProvider).useXpBoost(),
    );
  }

  Future<void> useReroll() async {
    await _runAction(
      actionKey: 'inventory:reroll',
      operation: () => ref.read(inventoryActionHandlerProvider).useReroll(),
    );
  }

  void dismissChestRewards() {
    ref.read(inventoryActionHandlerProvider).clearChestRewards();
    state = state.copyWith(clearChestRewards: true);
  }

  Future<void> _runAction({
    required String actionKey,
    required Future<void> Function() operation,
  }) async {
    if (state.isSubmitting) {
      return;
    }
    state = state.copyWith(isSubmitting: true, activeActionKey: actionKey);
    try {
      await operation();
    } finally {
      state = state.copyWith(
        isSubmitting: false,
        clearActiveActionKey: true,
      );
    }
  }

  bool _sameRewards(List<String>? left, List<String>? right) {
    if (identical(left, right)) {
      return true;
    }
    if (left == null || right == null || left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) {
        return false;
      }
    }
    return true;
  }
}

final inventoryControllerProvider =
    NotifierProvider.autoDispose<InventoryController, InventoryState>(
      InventoryController.new,
    );
