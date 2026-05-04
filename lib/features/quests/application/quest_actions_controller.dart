import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/domain/daily_quest.dart';
import 'quest_action_handler.dart';
import 'quest_actions_state.dart';

final questActionHandlerProvider = Provider<QuestActionHandler>((ref) {
  throw UnimplementedError('questActionHandlerProvider must be overridden');
});

class QuestActionsController extends AutoDisposeNotifier<QuestActionsState> {
  @override
  QuestActionsState build() => const QuestActionsState();

  Future<void> advanceQuest(DailyQuest quest) async {
    await _runAction(
      actionKey: 'quest:${quest.id}',
      operation: () => ref.read(questActionHandlerProvider).advanceQuest(quest),
    );
  }

  Future<void> advanceSpecialQuest(DailyQuest quest) async {
    await _runAction(
      actionKey: 'special:${quest.id}',
      operation: () => ref
          .read(questActionHandlerProvider)
          .advanceSpecialQuest(quest),
    );
  }

  Future<void> decideSpecialQuest(bool accept) async {
    await _runAction(
      actionKey: accept ? 'special:accept' : 'special:reject',
      operation: () => ref
          .read(questActionHandlerProvider)
          .decideSpecialQuest(accept),
    );
  }

  Future<void> _runAction({
    required String actionKey,
    required Future<void> Function() operation,
  }) async {
    if (state.isSubmitting) {
      return;
    }
    state = state.copyWith(isSubmitting: true, activeActionKey: actionKey);
    try {
      await operation();
    } finally {
      state = state.copyWith(
        isSubmitting: false,
        clearActiveActionKey: true,
      );
    }
  }
}

final questActionsControllerProvider =
    NotifierProvider.autoDispose<QuestActionsController, QuestActionsState>(
      QuestActionsController.new,
    );
