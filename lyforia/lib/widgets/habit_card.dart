import 'package:flutter/material.dart';
import 'package:lyforia/models/habit.dart';
import 'package:lyforia/utils/app_constants.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool checkedToday;
  final VoidCallback onCheck;
  final VoidCallback onUndo;
  final VoidCallback? onEdit;
  final VoidCallback? onArchive;

  const HabitCard({
    super.key,
    required this.habit,
    required this.checkedToday,
    required this.onCheck,
    required this.onUndo,
    this.onEdit,
    this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final label = checkedToday
        ? 'Undo today for ${habit.title}'
        : 'Mark ${habit.title} done today';
    return Semantics(
      container: true,
      label: 'Habit card: ${habit.title}',
      child: Card(
        elevation: AppSizes.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            children: [
              Text(habit.emoji ?? '✅', style: const TextStyle(fontSize: 24)),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(habit.title, style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Streak: ${habit.streakCount}  •  Best: ${habit.bestStreak}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Semantics(
                button: true,
                label: label,
                child: Tooltip(
                  message: checkedToday ? 'Undo check-in' : 'Check in',
                  child: ElevatedButton.icon(
                    onPressed: checkedToday ? onUndo : onCheck,
                    icon: Icon(checkedToday ? Icons.undo : Icons.check_circle),
                    label: Text(checkedToday ? 'Undo' : 'Check in'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(AppSizes.buttonMinWidth, AppSizes.buttonHeight * 0.8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

