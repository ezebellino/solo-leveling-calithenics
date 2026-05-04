import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/features/home/presentation/widgets/section_palette.dart';
import 'package:solo_leveling_calisthenics/features/inventory/presentation/widgets/chest_reward_overlay.dart';

void main() {
  const palette = SectionPalette(
    primary: Color(0xFF67E8FF),
    secondary: Color(0xFF7A8CFF),
    highlight: Color(0xFFD9F6FF),
  );
  const rewards = <String>[
    '+250 EXP',
    'Daga del Caballero Demonio',
    'Piedra de esencia x3',
  ];

  Widget buildSubject({
    List<String> overlayRewards = rewards,
    VoidCallback? onDismiss,
  }) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFF020611),
        body: Center(
          child: ChestRewardOverlay(
            rewards: overlayRewards,
            palette: palette,
            onDismiss: onDismiss,
          ),
        ),
      ),
    );
  }

  testWidgets('renders chest headline, rewards and dismiss CTA', (tester) async {
    var dismissCount = 0;

    await tester.pumpWidget(buildSubject(onDismiss: () => dismissCount++));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Cofre recibido'), findsOneWidget);
    expect(find.text('RECOMPENSAS'), findsOneWidget);
    expect(find.text('+250 EXP'), findsOneWidget);
    expect(find.text('Daga del Caballero Demonio'), findsOneWidget);
    expect(find.text('Piedra de esencia x3'), findsOneWidget);
    expect(find.text('CONTINUAR'), findsOneWidget);

    await tester.tap(find.text('CONTINUAR'));
    expect(dismissCount, 1);
  });

  testWidgets('omits CTA when onDismiss is null', (tester) async {
    await tester.pumpWidget(buildSubject());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('CONTINUAR'), findsNothing);
    expect(find.text('Cofre recibido'), findsOneWidget);
  });
}
