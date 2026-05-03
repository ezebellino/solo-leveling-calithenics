class ShadowProgressSnapshot {
  ShadowProgressSnapshot({
    required this.completedMainDays,
    required this.streakDays,
    required this.totalCompletedQuests,
    required this.completedSpecialQuests,
    required this.perfectWeeks,
    required this.level,
    required Iterable<String> unlockedShadowIds,
  }) : unlockedShadowIds = Set<String>.unmodifiable(unlockedShadowIds);

  final int completedMainDays;
  final int streakDays;
  final int totalCompletedQuests;
  final int completedSpecialQuests;
  final int perfectWeeks;
  final int level;
  final Set<String> unlockedShadowIds;

  bool isUnlocked(String shadowId) => unlockedShadowIds.contains(shadowId);
}
