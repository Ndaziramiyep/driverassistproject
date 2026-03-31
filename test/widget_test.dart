import 'package:flutter_test/flutter_test.dart';

import 'package:driverassist/main.dart';

void main() {
  testWidgets('App root builds', (WidgetTester tester) async {
    await tester.pumpWidget(const DriverAssistApp());
    expect(find.text('DriverAssist'), findsOneWidget);
  });
}
