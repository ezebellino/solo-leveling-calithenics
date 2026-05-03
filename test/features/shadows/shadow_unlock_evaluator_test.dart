import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/features/shadows/application/shadow_unlock_evaluator.dart';
import 'package:solo_leveling_calisthenics/features/shadows/domain/shadow_catalog.dart';
import 'package:solo_leveling_calisthenics/features/shadows/domain/shadow_progress_snapshot.dart';

void main() {
  group('ShadowUnlockEvaluator', () {
    test('returns Igris when the player reaches 7 completed main days', () {
      const evaluator = ShadowUnlockEvaluator();

      final unlocked = evaluator.evaluate(
        progress: ShadowProgressSnapshot(
          completedMainDays: 7,
          streakDays: 3,
          totalCompletedQuests: 12,
          completedSpecialQuests: 0,
          perfectWeeks: 0,
          level: 5,
          unlockedShadowIds: const <String>[],
        ),
        catalog: ShadowCatalog.initialRoster,
      );

      expect(unlocked.map((shadow) => shadow.id), ['igris']);
      expect(unlocked.single.flavorText, isNotEmpty);
      expect(unlocked.single.unlockHint, contains('7 main quest days'));
    });

    test('skips shadows that are already unlocked', () {
      const evaluator = ShadowUnlockEvaluator();

      final unlocked = evaluator.evaluate(
        progress: ShadowProgressSnapshot(
          completedMainDays: 7,
          streakDays: 3,
          totalCompletedQuests: 12,
          completedSpecialQuests: 0,
          perfectWeeks: 0,
          level: 5,
          unlockedShadowIds: const <String>['igris'],
        ),
        catalog: ShadowCatalog.initialRoster,
      );

      expect(unlocked, isEmpty);
    });

    test('does not unlock Tank until all of its thresholds are met', () {
      const evaluator = ShadowUnlockEvaluator();

      final missingThreshold = evaluator.evaluate(
        progress: ShadowProgressSnapshot(
          completedMainDays: 14,
          streakDays: 6,
          totalCompletedQuests: 21,
          completedSpecialQuests: 0,
          perfectWeeks: 0,
          level: 8,
          unlockedShadowIds: const <String>[],
        ),
        catalog: ShadowCatalog.initialRoster,
      );

      expect(missingThreshold.map((shadow) => shadow.id), isNot(contains('tank')));

      final unlocked = evaluator.evaluate(
        progress: ShadowProgressSnapshot(
          completedMainDays: 14,
          streakDays: 7,
          totalCompletedQuests: 21,
          completedSpecialQuests: 0,
          perfectWeeks: 0,
          level: 8,
          unlockedShadowIds: const <String>[],
        ),
        catalog: ShadowCatalog.initialRoster,
      );

      expect(unlocked.map((shadow) => shadow.id), contains('tank'));
    });

    test('copies unlocked shadow ids instead of reflecting later mutations', () {
      final sourceUnlockedShadowIds = <String>['igris'];
      final snapshot = ShadowProgressSnapshot(
        completedMainDays: 7,
        streakDays: 3,
        totalCompletedQuests: 12,
        completedSpecialQuests: 0,
        perfectWeeks: 0,
        level: 5,
        unlockedShadowIds: sourceUnlockedShadowIds,
      );

      sourceUnlockedShadowIds.add('tank');

      expect(snapshot.unlockedShadowIds, contains('igris'));
      expect(snapshot.unlockedShadowIds, isNot(contains('tank')));
    });
  });
}
