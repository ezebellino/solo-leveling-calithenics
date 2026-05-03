import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/features/home/presentation/widgets/section_palette.dart';
import 'package:solo_leveling_calisthenics/features/shadows/presentation/widgets/shadows_gallery_panel.dart';

void main() {
  const palette = SectionPalette(
    primary: Color(0xFF6DDCFF),
    secondary: Color(0xFF7AB8FF),
    highlight: Color(0xFFD7EEFF),
  );

  testWidgets('shows unlocked count and opens the expanded card', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShadowsGalleryPanel(
            unlockedShadowIds: <String>['igris'],
            lastUnlockedShadowId: 'igris',
            palette: palette,
          ),
        ),
      ),
    );

    expect(find.text('1 / 6 Sombras obtenidas'), findsOneWidget);
    expect(find.text('Igris'), findsWidgets);

    await tester.tap(find.text('Igris').first);
    await tester.pumpAndSettle();

    expect(find.text('Caballero Sombra'), findsOneWidget);
  });

  testWidgets('shows locked card guidance', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ShadowsGalleryPanel(
            unlockedShadowIds: <String>[],
            lastUnlockedShadowId: '',
            palette: palette,
          ),
        ),
      ),
    );

    expect(find.text('Bloqueada'), findsWidgets);
    expect(find.textContaining('7 dias de mision principal'), findsOneWidget);
  });
}
