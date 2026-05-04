import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/data/local_player_state_repository.dart';
import '../domain/player_snapshot.dart';

final playerLocalDataSourceProvider = Provider<PlayerLocalDataSource>((ref) {
  return PlayerLocalDataSource(
    storage: ref.watch(localPlayerStateRepositoryProvider),
  );
});

class PlayerLocalDataSource {
  const PlayerLocalDataSource({
    required LocalPlayerStateRepository storage,
  }) : _storage = storage;

  final LocalPlayerStateRepository _storage;

  Future<PlayerSnapshot?> loadSnapshot() async {
    final state = await _storage.load();
    if (state == null) {
      return null;
    }

    final profile = state.profile;
    return PlayerSnapshot(
      alias: profile.alias,
      rank: profile.rank,
      title: profile.title,
      level: profile.level,
      currentXp: profile.currentXp,
      nextLevelXp: profile.nextLevelXp,
      completedDays: state.completedDays,
    );
  }
}
