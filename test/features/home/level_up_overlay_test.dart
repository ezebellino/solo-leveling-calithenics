import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/features/home/presentation/widgets/level_up_overlay.dart';

void main() {
  testWidgets('renders ceremonial level up content and continue action', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: LevelUpOverlay(
              level: 8,
              primary: const Color(0xFF79E7FF),
              secondary: const Color(0xFF25F3B4),
              onDismiss: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('Subiste de nivel'), findsOneWidget);
    expect(find.text('Lv. 8'), findsOneWidget);
    expect(find.text('El Sistema reconoce tu crecimiento.'), findsOneWidget);
    expect(find.text('CONTINUAR'), findsOneWidget);
  });
}
