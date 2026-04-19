import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:solo_leveling_calisthenics/app.dart';

void main() {
  testWidgets('renders Solo Leveling dashboard', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const SoloLevelingApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('Jugador'), findsWidgets);
    expect(find.text('[ Aceptar ]'), findsOneWidget);
  });
}
