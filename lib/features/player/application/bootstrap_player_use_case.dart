import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/player_repository_impl.dart';
import '../domain/player_bootstrap_result.dart';
import '../domain/player_repository.dart';

final bootstrapPlayerUseCaseProvider = Provider<BootstrapPlayerUseCase>((ref) {
  return BootstrapPlayerUseCase(
    repository: ref.watch(playerRepositoryProvider),
  );
});

class BootstrapPlayerUseCase {
  const BootstrapPlayerUseCase({
    required PlayerRepository repository,
  }) : _repository = repository;

  final PlayerRepository _repository;

  Future<PlayerBootstrapResult> call() {
    return _repository.bootstrap();
  }

  Future<PlayerBootstrapResult> execute() {
    return call();
  }
}
