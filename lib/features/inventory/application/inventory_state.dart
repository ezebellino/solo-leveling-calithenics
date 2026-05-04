class InventoryState {
  const InventoryState({
    this.isSubmitting = false,
    this.activeActionKey,
    this.chestRewards,
  });

  final bool isSubmitting;
  final String? activeActionKey;
  final List<String>? chestRewards;

  bool get hasChestRewards => chestRewards != null && chestRewards!.isNotEmpty;

  InventoryState copyWith({
    bool? isSubmitting,
    String? activeActionKey,
    bool clearActiveActionKey = false,
    List<String>? chestRewards,
    bool clearChestRewards = false,
  }) {
    return InventoryState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      activeActionKey: clearActiveActionKey
          ? null
          : activeActionKey ?? this.activeActionKey,
      chestRewards: clearChestRewards
          ? null
          : chestRewards ?? this.chestRewards,
    );
  }
}
