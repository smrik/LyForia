import 'package:flutter/material.dart';

class EntryTile extends StatelessWidget {
  final String text;
  final DateTime timestamp;

  const EntryTile({super.key, required this.text, required this.timestamp});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      title: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: Text(
        _formatTimestamp(timestamp),
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _formatTimestamp(DateTime dt) {
    final d = dt.toLocal();
    return '${_two(d.month)}/${_two(d.day)}/${d.year}  ${_two(d.hour)}:${_two(d.minute)}';
  }
}
