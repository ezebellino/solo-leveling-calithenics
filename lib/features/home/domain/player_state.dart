import 'daily_quest.dart';
import 'hunter_profile.dart';

class PlayerState {
  const PlayerState({
    required this.profile,
    required this.selectedStageIndex,
    required this.quests,
    required this.weeklySpecialQuest,
    required this.weeklySpecialWeekKey,
    required this.weeklySpecialStatus,
    required this.playerAccepted,
    required this.jobChanged,
    required this.lastQuestRefresh,
    required this.inventory,
    required this.completedDays,
    required this.xpBoostArmed,
    required this.lastStreakCreditDate,
  });

  final HunterProfile profile;
  final int selectedStageIndex;
  final List<DailyQuest> quests;
  final DailyQuest? weeklySpecialQuest;
  final String weeklySpecialWeekKey;
  final String weeklySpecialStatus;
  final bool playerAccepted;
  final bool jobChanged;
  final String lastQuestRefresh;
  final Map<String, int> inventory;
  final int completedDays;
  final bool xpBoostArmed;
  final String lastStreakCreditDate;

  PlayerState copyWith({
    HunterProfile? profile,
    int? selectedStageIndex,
    List<DailyQuest>? quests,
    DailyQuest? weeklySpecialQuest,
    String? weeklySpecialWeekKey,
    String? weeklySpecialStatus,
    bool? playerAccepted,
    bool? jobChanged,
    String? lastQuestRefresh,
    Map<String, int>? inventory,
    int? completedDays,
    bool? xpBoostArmed,
    String? lastStreakCreditDate,
  }) {
    return PlayerState(
      profile: profile ?? this.profile,
      selectedStageIndex: selectedStageIndex ?? this.selectedStageIndex,
      quests: quests ?? this.quests,
      weeklySpecialQuest: weeklySpecialQuest ?? this.weeklySpecialQuest,
      weeklySpecialWeekKey: weeklySpecialWeekKey ?? this.weeklySpecialWeekKey,
      weeklySpecialStatus: weeklySpecialStatus ?? this.weeklySpecialStatus,
      playerAccepted: playerAccepted ?? this.playerAccepted,
      jobChanged: jobChanged ?? this.jobChanged,
      lastQuestRefresh: lastQuestRefresh ?? this.lastQuestRefresh,
      inventory: inventory ?? this.inventory,
      completedDays: completedDays ?? this.completedDays,
      xpBoostArmed: xpBoostArmed ?? this.xpBoostArmed,
      lastStreakCreditDate: lastStreakCreditDate ?? this.lastStreakCreditDate,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'profile': profile.toJson(),
      'selectedStageIndex': selectedStageIndex,
      'quests': quests.map((quest) => quest.toJson()).toList(),
      'weeklySpecialQuest': weeklySpecialQuest?.toJson(),
      'weeklySpecialWeekKey': weeklySpecialWeekKey,
      'weeklySpecialStatus': weeklySpecialStatus,
      'playerAccepted': playerAccepted,
      'jobChanged': jobChanged,
      'lastQuestRefresh': lastQuestRefresh,
      'inventory': inventory,
      'completedDays': completedDays,
      'xpBoostArmed': xpBoostArmed,
      'lastStreakCreditDate': lastStreakCreditDate,
    };
  }

  factory PlayerState.fromJson(Map<String, Object?> json) {
    return PlayerState(
      profile:
          HunterProfile.fromJson(json['profile'] as Map<String, Object?>),
      selectedStageIndex: json['selectedStageIndex'] as int,
      quests: (json['quests'] as List<Object?>)
          .map((quest) => DailyQuest.fromJson(quest as Map<String, Object?>))
          .toList(),
      weeklySpecialQuest: json['weeklySpecialQuest'] == null
          ? null
          : DailyQuest.fromJson(
              json['weeklySpecialQuest'] as Map<String, Object?>,
            ),
      weeklySpecialWeekKey: json['weeklySpecialWeekKey'] as String? ?? '',
      weeklySpecialStatus: json['weeklySpecialStatus'] as String? ?? 'pending',
      playerAccepted: json['playerAccepted'] as bool? ?? false,
      jobChanged: json['jobChanged'] as bool? ?? false,
      lastQuestRefresh: json['lastQuestRefresh'] as String? ?? '',
      inventory: (json['inventory'] as Map<Object?, Object?>? ?? const {})
          .map((key, value) => MapEntry(key as String, value as int)),
      completedDays: json['completedDays'] as int? ?? 0,
      xpBoostArmed: json['xpBoostArmed'] as bool? ?? false,
      lastStreakCreditDate: json['lastStreakCreditDate'] as String? ?? '',
    );
  }
}
