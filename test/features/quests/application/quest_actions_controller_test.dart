import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/features/home/domain/daily_quest.dart';
import 'package:solo_leveling_calisthenics/features/quests/application/quest_action_handler.dart';
import 'package:solo_leveling_calisthenics/features/quests/application/quest_actions_controller.dart';

void main() {
  group('QuestActionsController', () {
    test('advance quest delegates to handler and clears busy state', () async {
      var advanceCalls = 0;
      final quest = const DailyQuest(
        id: 'quest-1',
        title: 'Quest',
        detail: 'Detail',
        progress: 0,
        target: 5,
        rewardXp: 10,
      );
      final container = ProviderContainer(
        overrides: [
          questActionHandlerProvider.overrideWithValue(
            QuestActionHandler(
              advanceQuest: (value) async {
                expect(value.id, quest.id);
                advanceCalls += 1;
              },
              advanceSpecialQuest: (_) async {},
              decideSpecialQuest: (_) async {},
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(questActionsControllerProvider.notifier)
          .advanceQuest(quest);

      expect(advanceCalls, 1);
      final state = container.read(questActionsControllerProvider);
      expect(state.isSubmitting, isFalse);
      expect(state.activeActionKey, isNull);
    });
  });
}
