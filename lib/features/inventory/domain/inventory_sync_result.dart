enum InventorySyncSource { remote, localCache, legacyLocalState }

class InventorySyncResult {
  const InventorySyncResult({
    required this.items,
    required this.source,
    required this.contractVersion,
  });

  final Map<String, int> items;
  final InventorySyncSource source;
  final String contractVersion;

  bool get usedFallback => source != InventorySyncSource.remote;
}
