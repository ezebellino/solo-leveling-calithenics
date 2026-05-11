import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/features/home/presentation/widgets/section_palette.dart';
import 'package:solo_leveling_calisthenics/features/shadows/domain/shadow_entity.dart';
import 'package:solo_leveling_calisthenics/features/shadows/presentation/widgets/shadow_compact_card.dart';
import 'package:solo_leveling_calisthenics/features/shadows/presentation/widgets/shadow_fullscreen_card.dart';
import 'package:solo_leveling_calisthenics/features/shadows/presentation/widgets/shadows_gallery_panel.dart';

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

  testWidgets('unlocked compact card exposes premium metadata and forwards taps', (
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
                isUnlocked: true,
                palette: palette,
                onTap: () => tapCount++,
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Igris'), findsOneWidget);
    expect(find.text('Caballero Sombra'), findsOneWidget);
    expect(find.textContaining('7 dias de mision principal'), findsNothing);

    await tester.tap(find.byType(ShadowCompactCard));
    await tester.pump();

    expect(tapCount, 1);
  });

  testWidgets('locked fullscreen card keeps the content gated', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ShadowFullscreenCard(
          shadow: shadow,
          isUnlocked: false,
          palette: palette,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Igris'), findsWidgets);
    expect(find.textContaining('7 dias de mision principal'), findsOneWidget);
    expect(find.text('Caballero Sombra'), findsNothing);
    expect(find.textContaining('Un duelista disciplinado'), findsNothing);
  });

  testWidgets('unlocked fullscreen card reveals the enriched card content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ShadowFullscreenCard(
          shadow: shadow,
          isUnlocked: true,
          palette: palette,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Igris'), findsWidgets);
    expect(find.text('Caballero Sombra'), findsOneWidget);
    expect(find.textContaining('Su espada solo responde a jugadores'), findsOneWidget);
    expect(find.textContaining('Un duelista disciplinado'), findsOneWidget);
  });

  testWidgets('locked shadows show a readable unlock message when tapped', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          backgroundColor: Color(0xFF020611),
          body: ShadowsGalleryPanel(
            unlockedShadowIds: <String>[],
            lastUnlockedShadowId: '',
            palette: palette,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ShadowCompactCard).first);
    await tester.pump(const Duration(milliseconds: 250));

    expect(
      find.text('Podras visualizar esta sombra cuando la desbloquees.'),
      findsOneWidget,
    );
  });
}
