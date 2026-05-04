import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/core/errors/app_exception.dart';
import 'package:solo_leveling_calisthenics/features/player/application/bootstrap_player_controller.dart';
import 'package:solo_leveling_calisthenics/features/player/application/bootstrap_player_state.dart';
import 'package:solo_leveling_calisthenics/features/player/application/bootstrap_player_use_case.dart';
import 'package:solo_leveling_calisthenics/features/player/domain/player_repository.dart';
import 'package:solo_leveling_calisthenics/features/player/domain/player_snapshot.dart';

void main() {
  group('BootstrapPlayerController', () {
    test('load transitions through loading and exposes snapshot', () async {
      final container = ProviderContainer(
        overrides: [
          bootstrapPlayerUseCaseProvider.overrideWithValue(
            BootstrapPlayerUseCase(
              repository: _FakePlayerRepository(snapshot: _snapshot),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final states = <BootstrapPlayerState>[];
      container.listen(
        bootstrapPlayerControllerProvider,
        (_, next) => states.add(next),
        fireImmediately: true,
      );

      final future =
          container.read(bootstrapPlayerControllerProvider.notifier).load();

      expect(container.read(bootstrapPlayerControllerProvider).isLoading, isTrue);

      await future;

      final state = container.read(bootstrapPlayerControllerProvider);
      expect(state.snapshot?.alias, _snapshot.alias);
      expect(state.snapshot?.completedDays, _snapshot.completedDays);
      expect(state.errorMessage, isNull);
      expect(states.any((entry) => entry.isLoading), isTrue);
    });

    test('stores the mapped message when bootstrap fails', () async {
      final container = ProviderContainer(
        overrides: [
          bootstrapPlayerUseCaseProvider.overrideWithValue(
            BootstrapPlayerUseCase(
              repository: _FakePlayerRepository(
                error: const AppException(
                  'player_bootstrap_failed',
                  'No se pudo cargar el jugador.',
                ),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container.read(bootstrapPlayerControllerProvider.notifier).load();

      final state = container.read(bootstrapPlayerControllerProvider);
      expect(state.snapshot, isNull);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, 'No se pudo cargar el jugador.');
    });
  });
}

const _snapshot = PlayerSnapshot(
  alias: 'Sung Jinwoo',
  rank: 'S-Rank',
  title: 'Monarca de las Sombras',
  level: 48,
  currentXp: 720,
  nextLevelXp: 900,
  completedDays: 12,
);

class _FakePlayerRepository implements PlayerRepository {
  _FakePlayerRepository({
    this.snapshot,
    this.error,
  });

  final PlayerSnapshot? snapshot;
  final Object? error;

  @override
  Future<PlayerSnapshot> bootstrap() async {
    if (error != null) {
      throw error!;
    }
    return snapshot!;
  }
}
