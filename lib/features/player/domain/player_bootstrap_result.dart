import 'player_snapshot.dart';

enum PlayerBootstrapSource {
  remote('remote'),
  localCache('local_cache'),
  legacyLocalState('legacy_local_state');

  const PlayerBootstrapSource(this.code);

  final String code;
}

class PlayerBootstrapResult {
  const PlayerBootstrapResult({
    required this.snapshot,
    required this.source,
    required this.contractVersion,
  });

  final PlayerSnapshot snapshot;
  final PlayerBootstrapSource source;
  final String contractVersion;

  bool get usedFallback => source != PlayerBootstrapSource.remote;
}
