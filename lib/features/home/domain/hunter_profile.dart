class HunterProfile {
  const HunterProfile({
    required this.alias,
    required this.avatarUrl,
    required this.avatarImageBase64,
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
  final String avatarUrl;
  final String avatarImageBase64;
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

  HunterProfile copyWith({
    String? alias,
    String? avatarUrl,
    String? avatarImageBase64,
    String? rank,
    String? title,
    int? level,
    int? currentXp,
    int? nextLevelXp,
    int? streakDays,
    int? shadowArmy,
    int? strength,
    int? agility,
    int? endurance,
    int? discipline,
  }) {
    return HunterProfile(
      alias: alias ?? this.alias,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarImageBase64: avatarImageBase64 ?? this.avatarImageBase64,
      rank: rank ?? this.rank,
      title: title ?? this.title,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      nextLevelXp: nextLevelXp ?? this.nextLevelXp,
      streakDays: streakDays ?? this.streakDays,
      shadowArmy: shadowArmy ?? this.shadowArmy,
      strength: strength ?? this.strength,
      agility: agility ?? this.agility,
      endurance: endurance ?? this.endurance,
      discipline: discipline ?? this.discipline,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'alias': alias,
      'avatarUrl': avatarUrl,
      'avatarImageBase64': avatarImageBase64,
      'rank': rank,
      'title': title,
      'level': level,
      'currentXp': currentXp,
      'nextLevelXp': nextLevelXp,
      'streakDays': streakDays,
      'shadowArmy': shadowArmy,
      'strength': strength,
      'agility': agility,
      'endurance': endurance,
      'discipline': discipline,
    };
  }

  factory HunterProfile.fromJson(Map<String, Object?> json) {
    return HunterProfile(
      alias: json['alias'] as String,
      avatarUrl: json['avatarUrl'] as String? ?? '',
      avatarImageBase64: json['avatarImageBase64'] as String? ?? '',
      rank: json['rank'] as String,
      title: json['title'] as String,
      level: json['level'] as int,
      currentXp: json['currentXp'] as int,
      nextLevelXp: json['nextLevelXp'] as int,
      streakDays: json['streakDays'] as int,
      shadowArmy: json['shadowArmy'] as int,
      strength: json['strength'] as int,
      agility: json['agility'] as int,
      endurance: json['endurance'] as int,
      discipline: json['discipline'] as int,
    );
  }
}
