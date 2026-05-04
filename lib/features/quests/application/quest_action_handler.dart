import '../../home/domain/daily_quest.dart';

class QuestActionHandler {
  const QuestActionHandler({
    required this.advanceQuest,
    required this.advanceSpecialQuest,
    required this.decideSpecialQuest,
  });

  final Future<void> Function(DailyQuest quest) advanceQuest;
  final Future<void> Function(DailyQuest quest) advanceSpecialQuest;
  final Future<void> Function(bool accept) decideSpecialQuest;
}
