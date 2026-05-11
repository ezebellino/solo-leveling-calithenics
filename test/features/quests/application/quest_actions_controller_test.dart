import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/core/errors/app_exception.dart';
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

      final success = await container
          .read(questActionsControllerProvider.notifier)
          .advanceQuest(quest);

      expect(success, isTrue);
      expect(advanceCalls, 1);
      final state = container.read(questActionsControllerProvider);
      expect(state.isSubmitting, isFalse);
      expect(state.activeActionKey, isNull);
      expect(state.lastCompletedActionKey, 'quest:${quest.id}');
      expect(state.lastErrorMessage, isNull);
    });

    test('failed quest action stores mapped error and rollback state', () async {
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
              advanceQuest: (_) async {
                throw const AppException(
                  'quest_sync_failed',
                  'No se pudo sincronizar la mision.',
                );
              },
              advanceSpecialQuest: (_) async {},
              decideSpecialQuest: (_) async {},
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final success = await container
          .read(questActionsControllerProvider.notifier)
          .advanceQuest(quest);

      expect(success, isFalse);
      final state = container.read(questActionsControllerProvider);
      expect(state.isSubmitting, isFalse);
      expect(state.lastCompletedActionKey, isNull);
      expect(state.lastErrorCode, 'quest_sync_failed');
      expect(state.lastErrorMessage, 'No se pudo sincronizar la mision.');
      expect(state.didRollback, isTrue);
    });
  });
}
