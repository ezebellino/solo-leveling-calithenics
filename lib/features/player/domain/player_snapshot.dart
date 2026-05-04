class PlayerSnapshot {
  const PlayerSnapshot({
    required this.alias,
    required this.rank,
    required this.title,
    required this.level,
    required this.currentXp,
    required this.nextLevelXp,
    required this.completedDays,
  });

  final String alias;
  final String rank;
  final String title;
  final int level;
  final int currentXp;
  final int nextLevelXp;
  final int completedDays;
}
