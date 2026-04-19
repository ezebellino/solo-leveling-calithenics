class HunterProfile {
  const HunterProfile({
    required this.alias,
    required this.rank,
    required this.title,
    required this.level,
    required this.currentXp,
    required this.nextLevelXp,
    required this.streakDays,
    required this.shadowArmy,
    required this.strength,
    required this.agility,
    required this.endurance,
    required this.discipline,
  });

  final String alias;
  final String rank;
  final String title;
  final int level;
  final int currentXp;
  final int nextLevelXp;
  final int streakDays;
  final int shadowArmy;
  final int strength;
  final int agility;
  final int endurance;
  final int discipline;

  double get xpProgress => nextLevelXp == 0 ? 0 : currentXp / nextLevelXp;
}
