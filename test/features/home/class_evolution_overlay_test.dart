import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/features/home/presentation/widgets/class_evolution_overlay.dart';
import 'package:solo_leveling_calisthenics/features/home/presentation/widgets/section_palette.dart';

void main() {
  testWidgets('renders ceremonial class evolution content', (tester) async {
    const palette = SectionPalette(
      primary: Color(0xFF79E7FF),
      secondary: Color(0xFF25F3B4),
      highlight: Color(0xFFB7F2FF),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: ClassEvolutionOverlay(
              previousClass: 'Humano novato',
              nextClass: 'Despierto',
              palette: palette,
              onDismiss: null,
            ),
          ),
        ),
      ),
    );

    expect(find.text('ASIGNACION DE CLASE'), findsOneWidget);
    expect(find.text('Humano novato'), findsOneWidget);
    expect(find.text('Despierto'), findsOneWidget);
    expect(find.byIcon(Icons.auto_awesome_rounded), findsOneWidget);
  });

  testWidgets('shows continue button when dismiss callback is present', (
    tester,
  ) async {
    const palette = SectionPalette(
      primary: Color(0xFF79E7FF),
      secondary: Color(0xFF25F3B4),
      highlight: Color(0xFFB7F2FF),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ClassEvolutionOverlay(
              previousClass: 'Humano novato',
              nextClass: 'Despierto',
              palette: palette,
              onDismiss: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('CONTINUAR'), findsOneWidget);
  });
}
