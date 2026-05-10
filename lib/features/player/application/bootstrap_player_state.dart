import '../domain/player_bootstrap_result.dart';
import '../domain/player_snapshot.dart';

class BootstrapPlayerState {
  const BootstrapPlayerState({
    this.result,
    this.isLoading = false,
    this.errorMessage,
  });

  final PlayerBootstrapResult? result;
  final bool isLoading;
  final String? errorMessage;

  PlayerSnapshot? get snapshot => result?.snapshot;
  PlayerBootstrapSource? get selectedSource => result?.source;
  String? get contractVersion => result?.contractVersion;

  BootstrapPlayerState copyWith({
    PlayerBootstrapResult? result,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return BootstrapPlayerState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}
