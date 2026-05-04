import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/player_repository_impl.dart';
import '../domain/player_repository.dart';
import '../domain/player_snapshot.dart';

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

  Future<PlayerSnapshot> call() {
    return _repository.bootstrap();
  }

  Future<PlayerSnapshot> execute() {
    return call();
  }
}
