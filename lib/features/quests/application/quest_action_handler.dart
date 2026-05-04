import '../../home/domain/daily_quest.dart';

class QuestActionHandler {
  const QuestActionHandler({
    required this.advanceQuest,
    required this.advanceSpecialQuest,
    required this.decideSpecialQuest,
    required this.useXpBoost,
    required this.useReroll,
  });

  final Future<void> Function(DailyQuest quest) advanceQuest;
  final Future<void> Function(DailyQuest quest) advanceSpecialQuest;
  final Future<void> Function(bool accept) decideSpecialQuest;
  final Future<void> Function() useXpBoost;
  final Future<void> Function() useReroll;
}
