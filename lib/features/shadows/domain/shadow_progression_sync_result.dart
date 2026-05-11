enum ShadowProgressionSyncSource { remote, localCache, legacyLocalState }

class ShadowProgressionSyncResult {
  const ShadowProgressionSyncResult({
    required this.shadowArmy,
    required this.unlockedShadowIds,
    required this.source,
    required this.contractVersion,
  });

  final int shadowArmy;
  final List<String> unlockedShadowIds;
  final ShadowProgressionSyncSource source;
  final String contractVersion;

  bool get usedFallback => source != ShadowProgressionSyncSource.remote;
}
