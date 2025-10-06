import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyforia/pages/check_in_page.dart';

void main() {
  testWidgets('Check-in page renders key controls', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CheckInPage()));

    expect(find.text('Daily Check-in'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byKey(const Key('notesField')), findsOneWidget);
    expect(find.byKey(const Key('diaryField')), findsOneWidget);
    expect(find.text('Save Check-in'), findsOneWidget);
  });
}

