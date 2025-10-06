import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lyforia/models/habit.dart';
import 'package:lyforia/pages/habit_tracker_page.dart';

class FakeStore implements HabitStore {
  List<Habit> _items = [];
  @override
  Future<List<Habit>> load() async => _items;
  @override
  Future<void> save(List<Habit> items) async {
    _items = List.from(items);
  }
}

void main() {
  testWidgets('Empty state, add habit, check-in and undo, persists', (tester) async {
    final store = FakeStore();
    await tester.pumpWidget(MaterialApp(home: HabitTrackerPage(store: store, userId: 'u1')));

    // Empty state present
    expect(find.text('No habits yet'), findsOneWidget);
    expect(find.text('Add habit'), findsOneWidget);

    // Add a habit via FAB
    await tester.tap(find.byTooltip('Add habit')); // FAB
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('habitTitleField')), 'Drink water');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    // Card appears
    expect(find.text('Drink water'), findsOneWidget);
    expect(find.textContaining('Streak'), findsOneWidget);

    // Check in
    await tester.tap(find.widgetWithText(ElevatedButton, 'Check in'));
    await tester.pump();
    // Snackbar appears with Undo
    expect(find.text('Checked in. Undo'), findsOneWidget);
    // Streak updated to 1
    expect(find.textContaining('Streak: 1'), findsOneWidget);

    // Undo
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Streak: 0'), findsOneWidget);

    // Rebuild with same store (persistence)
    await tester.pumpWidget(MaterialApp(home: HabitTrackerPage(store: store, userId: 'u1')));
    await tester.pumpAndSettle();
    expect(find.text('Drink water'), findsOneWidget);
  });
}

