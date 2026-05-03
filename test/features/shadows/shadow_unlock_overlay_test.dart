import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/features/home/presentation/widgets/section_palette.dart';
import 'package:solo_leveling_calisthenics/features/shadows/domain/shadow_entity.dart';
import 'package:solo_leveling_calisthenics/features/shadows/presentation/widgets/shadow_unlock_overlay.dart';

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

  Widget buildSubject({
    VoidCallback? onDismiss,
  }) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF020611),
        body: Center(
          child: ShadowUnlockOverlay(
            shadow: shadow,
            palette: palette,
            onDismiss: onDismiss,
          ),
        ),
      ),
    );
  }

  testWidgets('renders holographic unlock content and dismiss CTA', (
    tester,
  ) async {
    var dismissCount = 0;

    await tester.pumpWidget(
      buildSubject(onDismiss: () => dismissCount++),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('Nueva sombra obtenida'), findsOneWidget);
    expect(find.text('Igris'), findsWidgets);
    expect(find.text('Caballero Sombra'), findsOneWidget);
    expect(find.textContaining('Su espada solo responde a jugadores'), findsOneWidget);
    expect(find.text('CONTINUAR'), findsOneWidget);

    await tester.tap(find.text('CONTINUAR'));
    expect(dismissCount, 1);
  });

  testWidgets('omits dismiss CTA when onDismiss is null', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('CONTINUAR'), findsNothing);
    expect(find.byType(Image), findsOneWidget);
  });
}
