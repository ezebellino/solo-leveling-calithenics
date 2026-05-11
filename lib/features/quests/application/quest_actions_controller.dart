import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/providers/core_providers.dart';
import '../../home/domain/daily_quest.dart';
import 'quest_action_handler.dart';
import 'quest_actions_state.dart';

final questActionHandlerProvider = Provider<QuestActionHandler>((ref) {
  throw UnimplementedError('questActionHandlerProvider must be overridden');
});

class QuestActionsController extends AutoDisposeNotifier<QuestActionsState> {
  @override
  QuestActionsState build() => const QuestActionsState();

  Future<bool> advanceQuest(DailyQuest quest) async {
    return _runAction(
      actionKey: 'quest:${quest.id}',
      operation: () => ref.read(questActionHandlerProvider).advanceQuest(quest),
    );
  }

  Future<bool> advanceSpecialQuest(DailyQuest quest) async {
    return _runAction(
      actionKey: 'special:${quest.id}',
      operation: () => ref
          .read(questActionHandlerProvider)
          .advanceSpecialQuest(quest),
    );
  }

  Future<bool> decideSpecialQuest(bool accept) async {
    return _runAction(
      actionKey: accept ? 'special:accept' : 'special:reject',
      operation: () => ref
          .read(questActionHandlerProvider)
          .decideSpecialQuest(accept),
    );
  }

  void clearFeedback() {
    state = state.copyWith(
      clearCompletedActionKey: true,
      clearError: true,
      didRollback: false,
    );
  }

  Future<bool> _runAction({
    required String actionKey,
    required Future<void> Function() operation,
  }) async {
    if (state.isSubmitting) {
      return false;
    }
    final logger = ref.read(appLoggerProvider);
    state = state.copyWith(
      isSubmitting: true,
      activeActionKey: actionKey,
      clearCompletedActionKey: true,
      clearError: true,
      didRollback: false,
    );
    logger.info(
      event: 'quest_action_started',
      source: 'quests.controller',
      context: <String, Object?>{
        'actionKey': actionKey,
      },
    );
    try {
      await operation();
      state = state.copyWith(
        isSubmitting: false,
        clearActiveActionKey: true,
        lastCompletedActionKey: actionKey,
        clearError: true,
        didRollback: false,
      );
      logger.info(
        event: 'quest_action_succeeded',
        source: 'quests.controller',
        context: <String, Object?>{
          'actionKey': actionKey,
        },
      );
      return true;
    } catch (error) {
      final exception = mapToAppException(error);
      state = state.copyWith(
        isSubmitting: false,
        clearActiveActionKey: true,
        clearCompletedActionKey: true,
        lastErrorCode: exception.code,
        lastErrorMessage: exception.message,
        didRollback: true,
      );
      logger.warning(
        event: 'quest_action_failed',
        source: 'quests.controller',
        context: <String, Object?>{
          'actionKey': actionKey,
          'errorCode': exception.code,
          'didRollback': true,
        },
      );
      return false;
    } finally {
      if (state.isSubmitting) {
        state = state.copyWith(
          isSubmitting: false,
          clearActiveActionKey: true,
        );
      }
    }
  }
}

final questActionsControllerProvider =
    NotifierProvider.autoDispose<QuestActionsController, QuestActionsState>(
      QuestActionsController.new,
    );
