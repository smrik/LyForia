import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lyforia/main.dart';
import 'package:lyforia/theme_provider.dart';

void main() {
  testWidgets('App renders and shows bottom tabs', (WidgetTester tester) async {
    // Build the app with the required ThemeProvider.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    );

    // Allow any animations to settle.
    await tester.pumpAndSettle();

    // Verify bottom navigation labels exist.
    expect(find.text('Diary'), findsOneWidget);
    expect(find.text('Eating'), findsOneWidget);
    expect(find.text('Mood'), findsOneWidget);
    expect(find.text('To-Do'), findsOneWidget);
    expect(find.text('Analytics'), findsOneWidget);
    expect(find.text('Habits'), findsOneWidget);

    // Tap on "Mood" and ensure selection updates.
    await tester.tap(find.text('Mood'));
    await tester.pumpAndSettle();
    // The selection color change is hard to assert without theme inspection,
    // but no exceptions should be thrown during navigation.
  });
}
