import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/network/api_result.dart';
import '../../../core/network/http_client_provider.dart';
import '../../../core/providers/core_providers.dart';
import '../domain/player_repository.dart';
import '../domain/player_snapshot.dart';
import 'player_api_client.dart';
import 'player_local_data_source.dart';

final playerRepositoryProvider = Provider<PlayerRepository>((ref) {
  return PlayerRepositoryImpl(
    apiClient: ref.watch(playerApiClientProvider),
    localDataSource: ref.watch(playerLocalDataSourceProvider),
    logger: ref.watch(appLoggerProvider),
  );
});

final playerApiClientProvider = Provider<PlayerApiClient>((ref) {
  return PlayerApiClient(
    baseUrl: ref.watch(apiBaseUrlProvider),
    httpClient: ref.watch(httpClientProvider),
    disposeHttpClient: false,
  );
});

class PlayerRepositoryImpl implements PlayerRepository {
  PlayerRepositoryImpl({
    required PlayerApiClient apiClient,
    required PlayerLocalDataSource localDataSource,
    required AppLogger logger,
  })  : _apiClient = apiClient,
        _localDataSource = localDataSource,
        _logger = logger;

  final PlayerApiClient _apiClient;
  final PlayerLocalDataSource _localDataSource;
  final AppLogger _logger;

  @override
  Future<PlayerSnapshot> bootstrap() async {
    _logger.info(
      event: 'bootstrap_started',
      source: 'player.repository',
    );

    final remoteResult = await guardApiResult(_loadRemoteSnapshot);
    if (remoteResult is ApiSuccess<PlayerSnapshot>) {
      final snapshot = remoteResult.data;
      _logger.info(
        event: 'bootstrap_remote_success',
        source: 'player.repository',
        context: <String, Object?>{
          'alias': snapshot.alias,
          'completedDays': snapshot.completedDays,
        },
      );
      return snapshot;
    }

    final remoteError = (remoteResult as ApiFailure<PlayerSnapshot>).error;
    _logger.warning(
      event: 'bootstrap_remote_failed',
      source: 'player.repository',
      context: <String, Object?>{
        'code': remoteError.code,
      },
    );

    final localResult = await guardApiResult(_localDataSource.loadSnapshot);
    if (localResult is ApiSuccess<PlayerSnapshot?>) {
      final snapshot = localResult.data;
      if (snapshot != null && snapshot.alias.isNotEmpty) {
        _logger.warning(
          event: 'bootstrap_local_fallback',
          source: 'player.repository',
          context: <String, Object?>{
            'alias': snapshot.alias,
            'remoteCode': remoteError.code,
          },
        );
        return snapshot;
      }
    } else if (localResult is ApiFailure<PlayerSnapshot?>) {
      final localError = localResult.error;
      _logger.error(
        event: 'bootstrap_failed',
        source: 'player.repository',
        context: <String, Object?>{
          'remoteCode': remoteError.code,
          'localCode': localError.code,
        },
      );
      throw localError;
    }

    _logger.error(
      event: 'bootstrap_failed',
      source: 'player.repository',
      context: <String, Object?>{
        'code': remoteError.code,
      },
    );
    throw remoteError;
  }

  Future<PlayerSnapshot> _loadRemoteSnapshot() async {
    final bootstrapJson = await _apiClient.fetchBootstrapJson();
    final playerJson = await _apiClient.fetchPlayerJson();

    final bootstrapPlayerJson = _readObject(bootstrapJson, 'player');
    final completedDays = _readInt(playerJson, 'completedDays');

    return PlayerSnapshot(
      alias: _readString(bootstrapPlayerJson, 'alias'),
      rank: _readString(bootstrapPlayerJson, 'rank'),
      title: _readString(bootstrapPlayerJson, 'title'),
      level: _readInt(bootstrapPlayerJson, 'level'),
      currentXp: _readInt(bootstrapPlayerJson, 'currentXp'),
      nextLevelXp: _readInt(bootstrapPlayerJson, 'nextLevelXp'),
      completedDays: completedDays,
    );
  }

  Map<String, dynamic> _readObject(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map<Object?, Object?>) {
      return Map<String, dynamic>.from(value);
    }
    throw FormatException('Missing object: $key');
  }

  String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) {
      return value;
    }
    throw FormatException('Missing string: $key');
  }

  int _readInt(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    throw FormatException('Missing int: $key');
  }
}
