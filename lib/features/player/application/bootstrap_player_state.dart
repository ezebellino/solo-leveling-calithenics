import '../domain/player_snapshot.dart';

class BootstrapPlayerState {
  const BootstrapPlayerState({
    this.snapshot,
    this.isLoading = false,
    this.errorMessage,
  });

  final PlayerSnapshot? snapshot;
  final bool isLoading;
  final String? errorMessage;

  BootstrapPlayerState copyWith({
    PlayerSnapshot? snapshot,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return BootstrapPlayerState(
      snapshot: snapshot ?? this.snapshot,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}
