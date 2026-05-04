import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/features/home/presentation/widgets/section_palette.dart';
import 'package:solo_leveling_calisthenics/features/shadows/domain/shadow_entity.dart';
import 'package:solo_leveling_calisthenics/features/shadows/presentation/widgets/shadow_compact_card.dart';

void main() {
  const palette = SectionPalette(
    primary: Color(0xFF6DDCFF),
    secondary: Color(0xFF7AB8FF),
    highlight: Color(0xFFD7EEFF),
  );

  const shadow = ShadowEntity(
    id: 'igris',
    name: 'Igris',
    title: 'Caballero Sombra',
    description: 'Un duelista disciplinado que despierta al completar la primera semana de constancia.',
    flavorText: 'Su espada solo responde a jugadores capaces de volver a presentarse manana.',
    unlockHint: 'Completa 7 dias de mision principal para despertar a Igris.',
    rarity: ShadowRarity.epic,
    assetPath: 'assets/shadows/Igris-Card.webp',
    borderTheme: ShadowBorderTheme(
      primaryHex: '#6F0D12',
      secondaryHex: '#C7A34B',
      accentHex: '#F4E6C2',
    ),
  );

  testWidgets('locked compact card shows only name and hint, and still forwards taps', (
    tester,
  ) async {
    var tapCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          backgroundColor: const Color(0xFF020611),
          body: Center(
            child: SizedBox(
              width: 280,
              child: ShadowCompactCard(
                shadow: shadow,
                isUnlocked: false,
                palette: palette,
                onTap: () => tapCount++,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Igris'), findsOneWidget);
    expect(find.textContaining('7 dias de mision principal'), findsOneWidget);
    expect(find.text('Caballero Sombra'), findsNothing);
    expect(find.text('Bloqueada'), findsNothing);

    await tester.tap(find.byType(ShadowCompactCard));
    await tester.pumpAndSettle();

    expect(tapCount, 1);
  });
}
