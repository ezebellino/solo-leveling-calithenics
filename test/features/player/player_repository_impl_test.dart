import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/core/errors/app_exception.dart';
import 'package:solo_leveling_calisthenics/core/logging/app_logger.dart';
import 'package:solo_leveling_calisthenics/features/home/data/local_player_state_repository.dart';
import 'package:solo_leveling_calisthenics/features/player/data/player_api_client.dart';
import 'package:solo_leveling_calisthenics/features/player/data/player_local_data_source.dart';
import 'package:solo_leveling_calisthenics/features/player/data/player_repository_impl.dart';
import 'package:solo_leveling_calisthenics/features/player/domain/player_snapshot.dart';

void main() {
  group('PlayerRepositoryImpl.bootstrap', () {
    test('returns remote snapshot when bootstrap endpoints succeed', () async {
      final repository = PlayerRepositoryImpl(
        apiClient: _FakePlayerApiClient(
          bootstrapJson: _bootstrapJson,
          playerJson: _playerJson(completedDays: 12),
        ),
        localDataSource: _FakePlayerLocalDataSource(snapshot: _localSnapshot),
        logger: const AppLogger(),
      );

      final snapshot = await repository.bootstrap();

      expect(snapshot.alias, 'Sung Jinwoo');
      expect(snapshot.rank, 'S-Rank');
      expect(snapshot.title, 'Monarca de las Sombras');
      expect(snapshot.level, 48);
      expect(snapshot.currentXp, 720);
      expect(snapshot.nextLevelXp, 900);
      expect(snapshot.completedDays, 12);
    });

    test('falls back to local snapshot when remote bootstrap fails', () async {
      final repository = PlayerRepositoryImpl(
        apiClient: _FakePlayerApiClient(error: const SocketException('offline')),
        localDataSource: _FakePlayerLocalDataSource(snapshot: _localSnapshot),
        logger: const AppLogger(),
      );

      final snapshot = await repository.bootstrap();

      expect(snapshot.alias, _localSnapshot.alias);
      expect(snapshot.completedDays, _localSnapshot.completedDays);
    });

    test('throws mapped app exception when remote fails and local is empty', () async {
      final repository = PlayerRepositoryImpl(
        apiClient: _FakePlayerApiClient(error: const SocketException('offline')),
        localDataSource: _FakePlayerLocalDataSource(),
        logger: const AppLogger(),
      );

      await expectLater(
        repository.bootstrap(),
        throwsA(
          isA<AppException>()
              .having((exception) => exception.code, 'code', 'network_unavailable'),
        ),
      );
    });
  });
}

final _localSnapshot = PlayerSnapshot(
  alias: 'Local Hunter',
  rank: 'E-Rank',
  title: 'Humano novato',
  level: 3,
  currentXp: 40,
  nextLevelXp: 120,
  completedDays: 4,
);

const _bootstrapJson = <String, dynamic>{
  'player': <String, dynamic>{
    'alias': 'Sung Jinwoo',
    'rank': 'S-Rank',
    'title': 'Monarca de las Sombras',
    'level': 48,
    'currentXp': 720,
    'nextLevelXp': 900,
  },
  'stage': <String, dynamic>{
    'index': 4,
    'title': 'Advanced',
  },
  'featureFlags': <String, bool>{
    'local_sync_ready': true,
  },
};

Map<String, dynamic> _playerJson({required int completedDays}) {
  return <String, dynamic>{
    'player': _bootstrapJson['player'],
    'stage': _bootstrapJson['stage'],
    'inventory': const <Map<String, dynamic>>[],
    'completedDays': completedDays,
  };
}

class _FakePlayerApiClient extends PlayerApiClient {
  _FakePlayerApiClient({
    this.bootstrapJson,
    this.playerJson,
    this.error,
  }) : super(baseUrl: 'https://example.com');

  final Map<String, dynamic>? bootstrapJson;
  final Map<String, dynamic>? playerJson;
  final Object? error;

  @override
  Future<Map<String, dynamic>> fetchBootstrapJson() async {
    if (error != null) {
      throw error!;
    }
    return bootstrapJson!;
  }

  @override
  Future<Map<String, dynamic>> fetchPlayerJson() async {
    if (error != null) {
      throw error!;
    }
    return playerJson!;
  }

  @override
  Future<void> updatePlayerProgress(Map<String, dynamic> payload) async {}

  @override
  void dispose() {}
}

class _FakePlayerLocalDataSource extends PlayerLocalDataSource {
  _FakePlayerLocalDataSource({
    this.snapshot,
  }) : super(storage: _NoopLocalPlayerStateRepository());

  final PlayerSnapshot? snapshot;

  @override
  Future<PlayerSnapshot?> loadSnapshot() async => snapshot;
}

class _NoopLocalPlayerStateRepository extends LocalPlayerStateRepository {}
