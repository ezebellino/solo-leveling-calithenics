import 'shadow_entity.dart';
import 'shadow_unlock_rule.dart';

class ShadowCatalogEntry {
  const ShadowCatalogEntry({
    required this.shadow,
    required this.unlockRule,
  });

  final ShadowEntity shadow;
  final ShadowUnlockRule unlockRule;
}

class ShadowCatalog {
  static const List<ShadowCatalogEntry> initialRoster = [
    ShadowCatalogEntry(
      shadow: ShadowEntity(
        id: 'igris',
        name: 'Igris',
        title: 'Blood-Red Commander',
        description: 'A disciplined duelist earned through the first week of consistency.',
        flavorText: 'His blade only answers hunters who prove they can show up again tomorrow.',
        unlockHint: 'Complete 7 main quest days to awaken Igris.',
        rarity: ShadowRarity.epic,
        assetPath: 'assets/shadows/Igris-Card.webp',
        borderTheme: ShadowBorderTheme(
          primaryHex: '#6F0D12',
          secondaryHex: '#C7A34B',
          accentHex: '#F4E6C2',
        ),
      ),
      unlockRule: ShadowUnlockRule(
        minCompletedMainDays: 7,
      ),
    ),
    ShadowCatalogEntry(
      shadow: ShadowEntity(
        id: 'tank',
        name: 'Tank',
        title: 'Feral Vanguard',
        description: 'A brutal frontliner awarded for holding momentum beyond the first unlock.',
        flavorText: 'Tank crashes forward when discipline stops feeling optional and starts feeling natural.',
        unlockHint: 'Reach 14 main quest days, a 7-day streak, and 21 total completed quests.',
        rarity: ShadowRarity.epic,
        assetPath: 'assets/shadows/Tank-Card.webp',
        borderTheme: ShadowBorderTheme(
          primaryHex: '#1E3A2F',
          secondaryHex: '#7AA95C',
          accentHex: '#D7F2AE',
        ),
      ),
      unlockRule: ShadowUnlockRule(
        minCompletedMainDays: 14,
        minStreakDays: 7,
        minTotalCompletedQuests: 21,
      ),
    ),
    ShadowCatalogEntry(
      shadow: ShadowEntity(
        id: 'iron',
        name: 'Iron',
        title: 'Steel Bulwark',
        description: 'A dependable shield unlocked after clearing special assignments.',
        flavorText: 'Iron stands where weaker habits break, turning punishment into momentum.',
        unlockHint: 'Clear 21 main quest days, 1 special quest, and reach level 10.',
        rarity: ShadowRarity.legendary,
        assetPath: 'assets/shadows/Iron-Card.webp',
        borderTheme: ShadowBorderTheme(
          primaryHex: '#4A5568',
          secondaryHex: '#A0AEC0',
          accentHex: '#E2E8F0',
        ),
      ),
      unlockRule: ShadowUnlockRule(
        minCompletedMainDays: 21,
        minCompletedSpecialQuests: 1,
        minLevel: 10,
      ),
    ),
    ShadowCatalogEntry(
      shadow: ShadowEntity(
        id: 'tusk',
        name: 'Tusk',
        title: 'Arcane Artillery',
        description: 'A high-output caster reserved for players with deeper quest volume.',
        flavorText: 'Every completed session feeds Tusk another spell worth fearing.',
        unlockHint: 'Complete 30 main quest days, 45 total quests, and reach level 18.',
        rarity: ShadowRarity.legendary,
        assetPath: 'assets/shadows/Tusk-Card.webp',
        borderTheme: ShadowBorderTheme(
          primaryHex: '#3B1F5E',
          secondaryHex: '#8B5CF6',
          accentHex: '#DDD6FE',
        ),
      ),
      unlockRule: ShadowUnlockRule(
        minCompletedMainDays: 30,
        minTotalCompletedQuests: 45,
        minLevel: 18,
      ),
    ),
    ShadowCatalogEntry(
      shadow: ShadowEntity(
        id: 'beru',
        name: 'Beru',
        title: 'Predator King',
        description: 'A ruthless apex shadow for players who sustain elite weekly execution.',
        flavorText: 'Beru emerges when your routine stops surviving the week and starts devouring it.',
        unlockHint: 'Reach 45 main quest days, 3 special clears, 2 perfect weeks, and level 28.',
        rarity: ShadowRarity.mythic,
        assetPath: 'assets/shadows/Beru-Card.webp',
        borderTheme: ShadowBorderTheme(
          primaryHex: '#0F172A',
          secondaryHex: '#14B8A6',
          accentHex: '#99F6E4',
        ),
      ),
      unlockRule: ShadowUnlockRule(
        minCompletedMainDays: 45,
        minCompletedSpecialQuests: 3,
        minPerfectWeeks: 2,
        minLevel: 28,
      ),
    ),
    ShadowCatalogEntry(
      shadow: ShadowEntity(
        id: 'bellion',
        name: 'Bellion',
        title: 'Grand Marshal',
        description: 'The top commander, reserved for late-game discipline and total progression.',
        flavorText: 'Bellion kneels only to a ruler whose consistency has become identity.',
        unlockHint: 'Complete 60 main quest days, 90 total quests, 4 perfect weeks, and reach level 40.',
        rarity: ShadowRarity.mythic,
        assetPath: 'assets/shadows/Bellion-Card.webp',
        borderTheme: ShadowBorderTheme(
          primaryHex: '#3F2A14',
          secondaryHex: '#D4AF37',
          accentHex: '#FFF4BF',
        ),
      ),
      unlockRule: ShadowUnlockRule(
        minCompletedMainDays: 60,
        minTotalCompletedQuests: 90,
        minPerfectWeeks: 4,
        minLevel: 40,
      ),
    ),
  ];

  const ShadowCatalog._();
}
