import 'package:flutter_test/flutter_test.dart';

import 'package:solo_leveling_calisthenics/app.dart';

void main() {
  testWidgets('renders Solo Leveling dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const SoloLevelingApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('NOTIFICACION'), findsOneWidget);
    expect(find.text('[ Aceptar ]'), findsOneWidget);
  });
}
