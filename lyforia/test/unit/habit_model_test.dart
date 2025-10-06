import 'package:flutter_test/flutter_test.dart';
import 'package:lyforia/models/habit.dart';

void main() {
  test('Habit toJson/fromJson roundtrip', () {
    final h = Habit(
      id: '1',
      userId: 'u',
      title: 'Drink water',
      description: '8 glasses',
      emoji: '💧',
      color: 0xFF00BFA6,
      weeklyDays: const [1, 2, 3, 4, 5, 6, 7],
      archived: false,
      createdAt: DateTime.utc(2023, 1, 1),
      updatedAt: DateTime.utc(2023, 1, 2),
      lastCheckedAt: DateTime.utc(2023, 1, 3),
      streakCount: 5,
      bestStreak: 10,
    );
    final json = h.toJson();
    final copy = Habit.fromJson(json);
    expect(copy.id, h.id);
    expect(copy.userId, h.userId);
    expect(copy.title, h.title);
    expect(copy.description, h.description);
    expect(copy.emoji, h.emoji);
    expect(copy.color, h.color);
    expect(copy.weeklyDays, h.weeklyDays);
    expect(copy.archived, h.archived);
    expect(copy.createdAt, h.createdAt);
    expect(copy.updatedAt, h.updatedAt);
    expect(copy.lastCheckedAt, h.lastCheckedAt);
    expect(copy.streakCount, h.streakCount);
    expect(copy.bestStreak, h.bestStreak);
  });
}
