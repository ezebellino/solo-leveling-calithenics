import '../data/shadow_progression_repository.dart';
import '../domain/shadow_progression_sync_result.dart';

class ShadowProgressionSyncCoordinator {
  const ShadowProgressionSyncCoordinator({
    required ShadowProgressionRepository repository,
  }) : _repository = repository;

  final ShadowProgressionRepository _repository;

  Future<ShadowProgressionSyncResult> refresh() => _repository.refresh();

  Future<ShadowProgressionSyncResult> sync({
    required int shadowArmy,
    required List<String> unlockedShadowIds,
  }) {
    return _repository.sync(
      shadowArmy: shadowArmy,
      unlockedShadowIds: unlockedShadowIds,
    );
  }
}
