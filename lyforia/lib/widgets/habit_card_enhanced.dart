import 'package:flutter/material.dart';
import 'package:lyforia/models/habit.dart';
import 'package:lyforia/utils/app_constants.dart';

/// Enhanced habit card showing 7-day completion history with visual dots
class HabitCardEnhanced extends StatelessWidget {
  final Habit habit;
  final bool checkedToday;
  final VoidCallback onCheck;
  final VoidCallback onUndo;
  final Map<DateTime, bool>? completionHistory; // last 7 days
  final VoidCallback? onTap; // tap card to see details

  const HabitCardEnhanced({
    super.key,
    required this.habit,
    required this.checkedToday,
    required this.onCheck,
    required this.onUndo,
    this.completionHistory,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: AppSizes.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: emoji, title, check-in button
              Row(
                children: [
                  // Emoji
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        habit.emoji ?? '✅',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Title and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          habit.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (habit.description != null && habit.description!.isNotEmpty)
                          Text(
                            habit.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  // Check-in button (compact)
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: IconButton.filled(
                      onPressed: checkedToday ? onUndo : onCheck,
                      icon: Icon(
                        checkedToday ? Icons.check_circle : Icons.circle_outlined,
                        size: 28,
                      ),
                      tooltip: checkedToday ? 'Undo today' : 'Check in',
                      style: IconButton.styleFrom(
                        backgroundColor: checkedToday
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        foregroundColor: checkedToday
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Streak info
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    size: 16,
                    color: habit.streakCount > 0
                        ? Colors.orange
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${habit.streakCount} day streak',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: habit.streakCount > 0
                          ? Colors.orange
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    '•',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    'Best: ${habit.bestStreak}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // 7-day visual history
              _build7DayHistory(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Build 7-day completion history with dots
  Widget _build7DayHistory(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Generate last 7 days (including today)
    final days = List.generate(7, (index) {
      return today.subtract(Duration(days: 6 - index));
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((day) {
        final isToday = day.year == today.year &&
            day.month == today.month &&
            day.day == today.day;

        // Check if completed (from history or today's state)
        final completed = isToday
            ? checkedToday
            : (completionHistory?[day] ?? false);

        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Day label
              Text(
                _getDayLabel(day, isToday),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: isToday
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 4),

              // Completion dot/check
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  border: isToday
                      ? Border.all(
                          color: theme.colorScheme.primary,
                          width: 2,
                        )
                      : null,
                ),
                child: completed
                    ? Icon(
                        Icons.check,
                        size: 18,
                        color: theme.colorScheme.onPrimary,
                      )
                    : null,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Get day label (M, T, W, etc.)
  String _getDayLabel(DateTime day, bool isToday) {
    if (isToday) return 'Today';

    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[day.weekday - 1].substring(0, 1); // M, T, W, etc.
  }
}
