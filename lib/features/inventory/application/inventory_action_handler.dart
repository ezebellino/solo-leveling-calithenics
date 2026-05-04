class InventoryActionHandler {
  const InventoryActionHandler({
    required this.useXpBoost,
    required this.useReroll,
    required this.clearChestRewards,
  });

  final Future<void> Function() useXpBoost;
  final Future<void> Function() useReroll;
  final void Function() clearChestRewards;
}
