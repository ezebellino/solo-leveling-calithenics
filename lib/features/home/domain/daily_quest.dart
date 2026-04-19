class DailyQuest {
  const DailyQuest({
    required this.id,
    required this.title,
    required this.detail,
    required this.rewardXp,
    required this.progress,
    required this.target,
  });

  final String id;
  final String title;
  final String detail;
  final int rewardXp;
  final int progress;
  final int target;

  double get completionRate => target == 0 ? 0 : progress / target;
  bool get isCompleted => progress >= target;

  DailyQuest copyWith({
    String? id,
    String? title,
    String? detail,
    int? rewardXp,
    int? progress,
    int? target,
  }) {
    return DailyQuest(
      id: id ?? this.id,
      title: title ?? this.title,
      detail: detail ?? this.detail,
      rewardXp: rewardXp ?? this.rewardXp,
      progress: progress ?? this.progress,
      target: target ?? this.target,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'detail': detail,
      'rewardXp': rewardXp,
      'progress': progress,
      'target': target,
    };
  }

  factory DailyQuest.fromJson(Map<String, Object?> json) {
    return DailyQuest(
      id: json['id'] as String,
      title: json['title'] as String,
      detail: json['detail'] as String,
      rewardXp: json['rewardXp'] as int,
      progress: json['progress'] as int,
      target: json['target'] as int,
    );
  }
}
