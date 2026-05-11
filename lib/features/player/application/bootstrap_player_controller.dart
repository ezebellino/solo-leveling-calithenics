import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_mapper.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/providers/core_providers.dart';
import 'bootstrap_player_state.dart';
import 'bootstrap_player_use_case.dart';

class BootstrapPlayerController extends Notifier<BootstrapPlayerState> {
  @override
  BootstrapPlayerState build() => const BootstrapPlayerState();

  Future<void> load() async {
    final logger = ref.read(appLoggerProvider);
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
    );
    logger.sync(
      feature: 'player_bootstrap',
      action: 'load',
      source: 'player.controller',
      outcome: 'started',
    );

    try {
      final result = await ref.read(bootstrapPlayerUseCaseProvider).call();
      state = state.copyWith(
        result: result,
        isLoading: false,
        clearErrorMessage: true,
      );
      logger.sync(
        feature: 'player_bootstrap',
        action: 'load',
        source: 'player.controller',
        outcome: 'succeeded',
        context: <String, Object?>{
          'selectedSource': result.source.code,
          'contractVersion': result.contractVersion,
        },
      );
    } catch (error) {
      final exception = mapToAppException(error);
      state = state.copyWith(
        isLoading: false,
        errorMessage: exception.message,
      );
      logger.sync(
        feature: 'player_bootstrap',
        action: 'load',
        source: 'player.controller',
        outcome: 'failed',
        level: LogLevel.warning,
        context: <String, Object?>{
          'errorCode': exception.code,
          'retryable': exception.isRetryable,
          ...exception.logContext,
        },
      );
    }
  }
}

final bootstrapPlayerControllerProvider =
    NotifierProvider<BootstrapPlayerController, BootstrapPlayerState>(
      BootstrapPlayerController.new,
    );
