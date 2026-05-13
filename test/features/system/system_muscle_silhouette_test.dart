import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_leveling_calisthenics/features/home/presentation/widgets/section_palette.dart';
import 'package:solo_leveling_calisthenics/features/system/presentation/widgets/system_muscle_map_models.dart';
import 'package:solo_leveling_calisthenics/features/system/presentation/widgets/system_muscle_silhouette.dart';

void main() {
  testWidgets('renders front and back silhouettes', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SystemMuscleSilhouettePanel(
            palette: SectionPalette(
              primary: Color(0xFF79E7FF),
              secondary: Color(0xFF25F3B4),
              highlight: Color(0xFFF2FFFF),
            ),
            frontZones: [SystemMuscleZone.chest, SystemMuscleZone.core],
            backZones: [SystemMuscleZone.back],
          ),
        ),
      ),
    );

    expect(find.text('Vista frontal'), findsOneWidget);
    expect(find.text('Vista dorsal'), findsOneWidget);
    expect(find.byKey(const Key('system-muscle-front')), findsOneWidget);
    expect(find.byKey(const Key('system-muscle-back')), findsOneWidget);
  });

  testWidgets('keeps the dual silhouettes side-by-side on compact widths', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 320,
            child: SystemMuscleSilhouettePanel(
              palette: SectionPalette(
                primary: Color(0xFF79E7FF),
                secondary: Color(0xFF25F3B4),
                highlight: Color(0xFFF2FFFF),
              ),
              frontZones: [SystemMuscleZone.chest],
              backZones: [SystemMuscleZone.back],
            ),
          ),
        ),
      ),
    );

    final frontTopLeft = tester.getTopLeft(find.byKey(const Key('system-muscle-front')));
    final backTopLeft = tester.getTopLeft(find.byKey(const Key('system-muscle-back')));

    expect((frontTopLeft.dy - backTopLeft.dy).abs(), lessThan(4.0));
    expect(backTopLeft.dx, greaterThan(frontTopLeft.dx));
  });

  testWidgets('plays the restrained initial reveal and pulse animation', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SystemMuscleSilhouettePanel(
            palette: SectionPalette(
              primary: Color(0xFF79E7FF),
              secondary: Color(0xFF25F3B4),
              highlight: Color(0xFFF2FFFF),
            ),
            frontZones: [SystemMuscleZone.chest, SystemMuscleZone.core],
            backZones: [SystemMuscleZone.back],
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('system-muscle-front-reveal-overlay')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('system-muscle-back-reveal-overlay')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('system-muscle-front')), findsOneWidget);
    expect(find.byKey(const Key('system-muscle-back')), findsOneWidget);

    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('system-muscle-front-reveal-overlay')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('system-muscle-back-reveal-overlay')),
      findsNothing,
    );
    expect(find.byKey(const Key('system-muscle-front')), findsOneWidget);
    expect(find.byKey(const Key('system-muscle-back')), findsOneWidget);
  });
}
