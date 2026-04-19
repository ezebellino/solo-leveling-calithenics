class TrainingStage {
  const TrainingStage({
    required this.tier,
    required this.title,
    required this.goal,
    required this.frequency,
    required this.focus,
    required this.exitRule,
    required this.isCurrent,
  });

  final String tier;
  final String title;
  final String goal;
  final String frequency;
  final String focus;
  final String exitRule;
  final bool isCurrent;
}

class TrainingRule {
  const TrainingRule({
    required this.title,
    required this.detail,
  });

  final String title;
  final String detail;
}

class TrainingPath {
  const TrainingPath({
    required this.currentBlock,
    required this.summary,
    required this.stages,
    required this.rules,
  });

  final String currentBlock;
  final String summary;
  final List<TrainingStage> stages;
  final List<TrainingRule> rules;
}
