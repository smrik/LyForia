import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyforia/pages/settings_page.dart';

void main() {
  testWidgets('Settings shows Crisis Support tile', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));

    expect(find.text('Crisis Support'), findsOneWidget);
    expect(find.byIcon(Icons.support_agent), findsOneWidget);

    // Tap to open dialog
    await tester.tap(find.text('Crisis Support'));
    await tester.pumpAndSettle();
    expect(find.text('Crisis Resources'), findsOneWidget);

    // Close dialog
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Crisis Resources'), findsNothing);
  });
}

