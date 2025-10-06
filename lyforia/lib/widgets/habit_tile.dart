import 'package:flutter/material.dart';

class HabitTile extends StatelessWidget {
  final String name;
  final bool completedToday;
  final DateTime? lastCompletedOn;
  final VoidCallback onToggle;

  const HabitTile({
    super.key,
    required this.name,
    required this.completedToday,
    required this.lastCompletedOn,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = lastCompletedOn == null
        ? 'Not completed yet'
        : 'Last done: ${_two(lastCompletedOn!.month)}/${_two(lastCompletedOn!.day)}/${lastCompletedOn!.year}';
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListTile(
      tileColor: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(name, style: theme.textTheme.titleMedium),
      subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
      trailing: ElevatedButton.icon(
        onPressed: onToggle,
        icon: Icon(
            completedToday ? Icons.check_circle : Icons.radio_button_unchecked),
        label: Text(completedToday ? 'Done' : 'Mark done'),
        style: ElevatedButton.styleFrom(
          backgroundColor: completedToday ? scheme.secondary : scheme.primary,
          foregroundColor:
              completedToday ? scheme.onSecondary : scheme.onPrimary,
        ),
      ),
    );
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}
