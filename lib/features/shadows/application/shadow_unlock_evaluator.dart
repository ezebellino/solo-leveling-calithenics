import '../domain/shadow_catalog.dart';
import '../domain/shadow_entity.dart';
import '../domain/shadow_progress_snapshot.dart';

class ShadowUnlockEvaluator {
  const ShadowUnlockEvaluator();

  List<ShadowEntity> evaluate({
    required ShadowProgressSnapshot progress,
    required List<ShadowCatalogEntry> catalog,
  }) {
    return catalog.where((entry) {
      if (progress.isUnlocked(entry.shadow.id)) {
        return false;
      }

      return entry.unlockRule.isSatisfiedBy(progress);
    }).map((entry) => entry.shadow).toList();
  }
}
