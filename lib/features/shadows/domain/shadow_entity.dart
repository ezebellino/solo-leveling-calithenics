enum ShadowRarity { rare, epic, legendary, mythic }

class ShadowBorderTheme {
  const ShadowBorderTheme({
    required this.primaryHex,
    required this.secondaryHex,
    required this.accentHex,
  });

  final String primaryHex;
  final String secondaryHex;
  final String accentHex;
}

class ShadowEntity {
  const ShadowEntity({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.flavorText,
    required this.unlockHint,
    required this.rarity,
    required this.assetPath,
    required this.borderTheme,
  });

  final String id;
  final String name;
  final String title;
  final String description;
  final String flavorText;
  final String unlockHint;
  final ShadowRarity rarity;
  final String assetPath;
  final ShadowBorderTheme borderTheme;
}
