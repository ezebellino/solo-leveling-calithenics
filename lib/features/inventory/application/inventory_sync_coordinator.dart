import '../data/inventory_repository.dart';
import '../domain/inventory_sync_result.dart';

class InventorySyncCoordinator {
  const InventorySyncCoordinator({
    required InventoryRepository repository,
  }) : _repository = repository;

  final InventoryRepository _repository;

  Future<InventorySyncResult> refresh() => _repository.refresh();

  Future<InventorySyncResult> sync(Map<String, int> items) {
    return _repository.sync(items);
  }
}
