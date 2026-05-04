import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_mapper.dart';
import 'bootstrap_player_state.dart';
import 'bootstrap_player_use_case.dart';

class BootstrapPlayerController extends Notifier<BootstrapPlayerState> {
  @override
  BootstrapPlayerState build() => const BootstrapPlayerState();

  Future<void> load() async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
    );

    try {
      final snapshot = await ref.read(bootstrapPlayerUseCaseProvider).call();
      state = state.copyWith(
        snapshot: snapshot,
        isLoading: false,
        clearErrorMessage: true,
      );
    } catch (error) {
      final exception = mapToAppException(error);
      state = state.copyWith(
        isLoading: false,
        errorMessage: exception.message,
      );
    }
  }
}

final bootstrapPlayerControllerProvider =
    NotifierProvider<BootstrapPlayerController, BootstrapPlayerState>(
      BootstrapPlayerController.new,
    );
