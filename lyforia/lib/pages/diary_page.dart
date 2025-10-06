import 'package:flutter/material.dart';
import 'package:lyforia/screens/diary_screen.dart';
import 'package:lyforia/widgets/entry_tile.dart';

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final List<_DiaryEntry> _entries = <_DiaryEntry>[];
  // TODO: Persist entries locally (e.g., SharedPreferences/Hive).

  Future<void> _addEntry() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const DiaryScreen()),
    );
    final text = (result ?? '').trim();
    if (text.isNotEmpty) {
      setState(() {
        _entries.insert(0, _DiaryEntry(text: text, createdAt: DateTime.now()));
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry added')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _addEntry,
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              ),
              child: const Text('New Entry'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _entries.isEmpty
                  ? Center(
                      child: Text(
                        'No entries yet. Tap "New Entry" to add one.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      itemCount: _entries.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final e = _entries[index];
                        return EntryTile(text: e.text, timestamp: e.createdAt);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DiaryEntry {
  final String text;
  final DateTime createdAt;
  _DiaryEntry({required this.text, required this.createdAt});
}
