import 'shadow_progress_snapshot.dart';

class ShadowUnlockRule {
  const ShadowUnlockRule({
    this.minCompletedMainDays = 0,
    this.minStreakDays = 0,
    this.minTotalCompletedQuests = 0,
    this.minCompletedSpecialQuests = 0,
    this.minPerfectWeeks = 0,
    this.minLevel = 0,
  }) : assert(
         minCompletedMainDays > 0 ||
             minStreakDays > 0 ||
             minTotalCompletedQuests > 0 ||
             minCompletedSpecialQuests > 0 ||
             minPerfectWeeks > 0 ||
             minLevel > 0,
         'ShadowUnlockRule requires at least one threshold.',
       );

  final int minCompletedMainDays;
  final int minStreakDays;
  final int minTotalCompletedQuests;
  final int minCompletedSpecialQuests;
  final int minPerfectWeeks;
  final int minLevel;

  bool isSatisfiedBy(ShadowProgressSnapshot progress) {
    return progress.completedMainDays >= minCompletedMainDays &&
        progress.streakDays >= minStreakDays &&
        progress.totalCompletedQuests >= minTotalCompletedQuests &&
        progress.completedSpecialQuests >= minCompletedSpecialQuests &&
        progress.perfectWeeks >= minPerfectWeeks &&
        progress.level >= minLevel;
  }
}
