import '../../../core/logging/app_logger.dart';
import '../../home/data/local_player_state_repository.dart';
import '../../home/domain/player_state.dart';
import '../../inventory/data/inventory_repository.dart';
import '../../player/data/player_api_client.dart';
import '../../player/domain/player_bootstrap_result.dart';
import '../../player/domain/player_snapshot.dart';
import '../../shadows/data/shadow_progression_repository.dart';

class AttachLocalProgressUseCase {
  const AttachLocalProgressUseCase({
    required LocalPlayerStateRepository storage,
    required PlayerApiClient playerApiClient,
    required InventoryRepository inventoryRepository,
    required ShadowProgressionRepository shadowProgressionRepository,
    required AppLogger logger,
  })  : _storage = storage,
        _playerApiClient = playerApiClient,
        _inventoryRepository = inventoryRepository,
        _shadowProgressionRepository = shadowProgressionRepository,
        _logger = logger;

  final LocalPlayerStateRepository _storage;
  final PlayerApiClient _playerApiClient;
  final InventoryRepository _inventoryRepository;
  final ShadowProgressionRepository _shadowProgressionRepository;
  final AppLogger _logger;

  Future<PlayerSnapshot?> attachIfNeeded(PlayerBootstrapResult remoteBootstrap) async {
    final localState = await _storage.load();
    if (localState == null) {
      return null;
    }
    if (!_remoteLooksFresh(remoteBootstrap.snapshot)) {
      return null;
    }
    if (!_localLooksStronger(localState, remoteBootstrap.snapshot)) {
      return null;
    }

    _logger.sync(
      feature: 'auth',
      action: 'attach_local_progress',
      source: 'auth.attach_local_progress',
      outcome: 'started',
      context: <String, Object?>{
        'remoteLevel': remoteBootstrap.snapshot.level,
        'localLevel': localState.profile.level,
        'localCompletedDays': localState.completedDays,
      },
    );

    try {
      await _playerApiClient.updatePlayerProgress(_buildPlayerPayload(localState));
      await _inventoryRepository.sync(localState.inventory);
      await _shadowProgressionRepository.sync(
        shadowArmy: localState.profile.shadowArmy,
        unlockedShadowIds: localState.unlockedShadowIds,
      );
      final attachedSnapshot = _snapshotFromLocal(localState);
      _logger.sync(
        feature: 'auth',
        action: 'attach_local_progress',
        source: 'auth.attach_local_progress',
        outcome: 'attached',
        context: <String, Object?>{
          'level': attachedSnapshot.level,
          'completedDays': attachedSnapshot.completedDays,
          'shadowArmy': localState.profile.shadowArmy,
          'unlockedShadowCount': localState.unlockedShadowIds.length,
        },
      );
      return attachedSnapshot;
    } catch (error) {
      _logger.sync(
        feature: 'auth',
        action: 'attach_local_progress',
        source: 'auth.attach_local_progress',
        outcome: 'failed',
        level: LogLevel.warning,
        context: <String, Object?>{
          'error': error.toString(),
        },
      );
      return null;
    }
  }

  bool _remoteLooksFresh(PlayerSnapshot snapshot) {
    return snapshot.level <= 1 &&
        snapshot.currentXp == 0 &&
        snapshot.nextLevelXp == 120 &&
        snapshot.completedDays == 0;
  }

  bool _localLooksStronger(PlayerState localState, PlayerSnapshot remoteSnapshot) {
    return localState.profile.level > remoteSnapshot.level ||
        localState.completedDays > remoteSnapshot.completedDays ||
        localState.profile.currentXp > remoteSnapshot.currentXp ||
        localState.profile.shadowArmy > 0 ||
        localState.unlockedShadowIds.isNotEmpty ||
        localState.inventory.values.any((quantity) => quantity > 0);
  }

  Map<String, Object?> _buildPlayerPayload(PlayerState localState) {
    final profile = localState.profile;
    return <String, Object?>{
      'alias': profile.alias,
      'avatarUrl': profile.avatarUrl,
      'rank': profile.rank,
      'level': profile.level,
      'currentXp': profile.currentXp,
      'nextLevelXp': profile.nextLevelXp,
      'streakDays': profile.streakDays,
      'completedDays': localState.completedDays,
      'shadowArmy': profile.shadowArmy,
      'strength': profile.strength,
      'agility': profile.agility,
      'endurance': profile.endurance,
      'discipline': profile.discipline,
    };
  }

  PlayerSnapshot _snapshotFromLocal(PlayerState localState) {
    final profile = localState.profile;
    return PlayerSnapshot(
      alias: profile.alias,
      rank: profile.rank,
      title: profile.title,
      level: profile.level,
      currentXp: profile.currentXp,
      nextLevelXp: profile.nextLevelXp,
      completedDays: localState.completedDays,
    );
  }
}
