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
        title: 'Caballero Sombra',
        description:
            'Un duelista disciplinado que despierta al completar la primera semana de constancia.',
        flavorText:
            'Su espada solo responde a jugadores capaces de volver a presentarse manana.',
        unlockHint: 'Completa 7 dias de mision principal para despertar a Igris.',
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
        title: 'Muro Inquebrantable',
        description:
            'El guardian que aparece cuando la disciplina deja de sentirse opcional.',
        flavorText:
            'Tank avanza cuando el impulso ya no depende de la motivacion, sino del habito.',
        unlockHint:
            'Llega a 14 dias de mision principal, 7 dias de racha y 21 misiones completadas.',
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
        title: 'Titan de Acero',
        description:
            'Un escudo confiable que solo aparece cuando superas encargos del Sistema.',
        flavorText:
            'Iron se planta donde los habitos debiles se rompen y convierte castigo en avance.',
        unlockHint:
            'Completa 21 dias principales, 1 quest especial y alcanza el nivel 10.',
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
        title: 'General Orco',
        description:
            'Un artillero oscuro reservado para jugadores con volumen real de entrenamiento.',
        flavorText:
            'Cada sesion completada alimenta a Tusk con otro hechizo digno de temor.',
        unlockHint:
            'Completa 30 dias principales, 45 misiones totales y alcanza el nivel 18.',
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
        title: 'Rey Hormiga',
        description:
            'Una sombra apex para jugadores capaces de sostener semanas realmente elite.',
        flavorText:
            'Beru emerge cuando tu rutina deja de sobrevivir la semana y empieza a devorarla.',
        unlockHint:
            'Llega a 45 dias principales, 3 especiales, 2 semanas perfectas y nivel 28.',
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
        title: 'Monarca de la Conquista',
        description:
            'El comandante supremo, reservado para una disciplina de largo plazo.',
        flavorText:
            'Bellion solo se inclina ante un jugador cuya constancia ya se volvio identidad.',
        unlockHint:
            'Completa 60 dias principales, 90 misiones, 4 semanas perfectas y nivel 40.',
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
