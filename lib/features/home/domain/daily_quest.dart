class DailyQuest {
  const DailyQuest({
    required this.title,
    required this.detail,
    required this.rewardXp,
    required this.progress,
    required this.target,
  });

  final String title;
  final String detail;
  final int rewardXp;
  final int progress;
  final int target;

  double get completionRate => target == 0 ? 0 : progress / target;
}
