import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lyforia/utils/firebase_refs.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lyforia/widgets/quick_log_card.dart';

class BingeEatingLogPage extends StatefulWidget {
  const BingeEatingLogPage({super.key});

  @override
  State<BingeEatingLogPage> createState() => _BingeEatingLogPageState();
}

class BingeEntry {
  final String id;
  final TimeOfDay time;
  final String place;
  final bool v;
  final bool l;
  final bool starred;
  final String food;
  final String comments;
  final DateTime date;

  BingeEntry({
    required this.id,
    required this.time,
    required this.place,
    required this.v,
    required this.l,
    required this.starred,
    required this.food,
    required this.comments,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'time': '${time.hour}:${time.minute}',
      'place': place,
      'v': v,
      'l': l,
      'starred': starred,
      'food': food,
      'comments': comments,
      'date': Timestamp.fromDate(date),
      'dateTime': Timestamp.fromDate(
        DateTime(date.year, date.month, date.day, time.hour, time.minute),
      ),
      // Prefer server time to avoid client clock skew
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory BingeEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    final timeStr = (data['time'] as String?) ?? '0:0';
    final parts = timeStr.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final ts = data['date'] as Timestamp?;
    final date = ts?.toDate() ?? DateTime.now();
    return BingeEntry(
      id: doc.id,
      time: TimeOfDay(hour: hour, minute: minute),
      place: (data['place'] as String?) ?? '',
      v: (data['v'] as bool?) ?? false,
      l: (data['l'] as bool?) ?? false,
      starred: (data['starred'] as bool?) ?? false,
      food: (data['food'] as String?) ?? '',
      comments: (data['comments'] as String?) ?? '',
      date: date,
    );
  }
}

class _BingeEatingLogPageState extends State<BingeEatingLogPage> {
  final _formKey = GlobalKey<FormState>();
  TimeOfDay? _time;
  final _placeController = TextEditingController();
  bool _vChecked = false;
  bool _lChecked = false;
  bool _starredChecked = false;
  final _foodController = TextEditingController();
  final _commentsController = TextEditingController();
  final _weightController = TextEditingController();
  bool _showCalendar = true;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, double> _weights = {};

  final CollectionReference _bingeCollection =
      Fb.firestore.collection('binge_entries');

  /// Handle quick-log submission (time + place only)
  Future<void> _handleQuickLog(DateTime selectedTime, String place) async {
    final uid = Fb.auth.currentUser?.uid;
    if (uid == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to add entries.')));
      return;
    }

    try {
      final data = BingeEntry(
        id: '', // Firestore will generate an ID
        time: TimeOfDay.fromDateTime(selectedTime),
        place: place,
        v: false, // Quick-log defaults
        l: false,
        starred: false,
        food: '', // Empty in quick-log
        comments: '',
        date: _selectedDay ?? DateTime.now(),
      ).toJson();
      data['uid'] = uid;
      data['source'] = 'quick_log'; // Track origin for analytics

      await _bingeCollection.add(data);

      if (!mounted) return;

      // Show success SnackBar with "Add details?" option
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Entry saved. Want to add details?'),
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Yes',
            onPressed: () {
              // Pre-fill the full form with time and place
              setState(() {
                _time = TimeOfDay.fromDateTime(selectedTime);
                _placeController.text = place;
              });
              // Scroll to full form (user will see pre-filled fields)
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save entry: $e')),
      );
    }
  }

  Future<void> _addEntry() async {
    if (_formKey.currentState!.validate() && _time != null) {
      final uid = Fb.auth.currentUser?.uid;
      if (uid == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please sign in to add entries.')));
        return;
      }
      try {
        final data = BingeEntry(
          id: '', // Firestore will generate an ID
          time: _time!,
          place: _placeController.text,
          v: _vChecked,
          l: _lChecked,
          starred: _starredChecked,
          food: _foodController.text,
          comments: _commentsController.text,
          date: _selectedDay ?? DateTime.now(),
        ).toJson();
        data['uid'] = uid;
        data['source'] = 'full_form'; // Track origin for analytics
        await _bingeCollection.add(data);
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Entry saved')));
        _formKey.currentState!.reset();
        setState(() {
          _time = null;
          _vChecked = false;
          _lChecked = false;
          _starredChecked = false;
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save entry: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Binge Eating Log'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Quick-log card at top
              QuickLogCard(
                onSubmit: _handleQuickLog,
              ),
              const SizedBox(height: 20),
              Text(
                'Or use the full form below:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 20),
              _buildTimePicker(),
              const SizedBox(height: 10),
              _buildTextField(_placeController, 'Place', isRequired: true),
              const SizedBox(height: 10),
              _buildCheckboxes(),
              const SizedBox(height: 10),
              _buildTextField(_foodController, 'Food and drink consumed'),
              const SizedBox(height: 10),
              _buildTextField(_commentsController, 'Context and comments',
                  maxLines: 3),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addEntry,
                child: const Text('Add Entry'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showCalendar = !_showCalendar;
                  });
                },
                child: Text(_showCalendar ? 'Hide Calendar' : 'Show Calendar'),
              ),
              if (_showCalendar) ...[
                _buildCalendar(),
                const SizedBox(height: 20),
                if (_selectedDay != null) ...[
                  Text(
                    'Entries for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildEntriesForSelectedDay(),
                  const SizedBox(height: 20),
                ],
              ],
              const SizedBox(height: 20),
              _buildWeightLog(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _showEntries(context),
                child: const Text('View All Past Entries'),
              ),
              const SizedBox(height: 20),
              Text(
                'Weekly Starred Entries (this month)',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              _buildWeeklySummary(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimePicker() {
    return InkWell(
      onTap: () async {
        final time = await showTimePicker(
            context: context, initialTime: TimeOfDay.now());
        if (time != null) {
          setState(() {
            _time = time;
          });
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Time *',
        ),
        child: Text(_time?.format(context) ?? 'Select time'),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isRequired = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' *' : ''),
      ),
      maxLines: maxLines,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Please enter a value';
        }
        return null;
      },
    );
  }

  Widget _buildCheckboxes() {
    return Row(
      children: [
        Tooltip(
          message: 'Vomited',
          child: Checkbox(
            value: _vChecked,
            onChanged: (value) => setState(() => _vChecked = value!),
          ),
        ),
        const Text('V', semanticsLabel: 'Vomited'),
        const SizedBox(width: 20),
        Tooltip(
          message: 'Laxatives',
          child: Checkbox(
            value: _lChecked,
            onChanged: (value) => setState(() => _lChecked = value!),
          ),
        ),
        const Text('L', semanticsLabel: 'Laxatives'),
        const SizedBox(width: 20),
        Tooltip(
          message: 'Starred / notable event',
          child: Checkbox(
            value: _starredChecked,
            onChanged: (value) => setState(() => _starredChecked = value!),
          ),
        ),
        const Text('*', semanticsLabel: 'Starred event'),
      ],
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (_weights.containsKey(DateTime(date.year, date.month, date.day))) {
            return Positioned(
              right: 1,
              bottom: 1,
              child: Text(
                _weights[DateTime(date.year, date.month, date.day)].toString(),
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            );
          }
          return null;
        },
      ),
    );
  }

  Widget _buildWeightLog() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(_weightController, 'Weekly Weight (kg)'),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            if (_selectedDay != null && _weightController.text.isNotEmpty) {
              setState(() {
                _weights[DateTime(_selectedDay!.year, _selectedDay!.month,
                    _selectedDay!.day)] = double.parse(_weightController.text);
                _weightController.clear();
              });
            }
          },
          child: const Text('Log Weight'),
        ),
      ],
    );
  }

  Widget _buildWeeklySummary() {
    return DataTable(
      columns: const [
        DataColumn(label: Text('Year')),
        DataColumn(label: Text('Week')),
        DataColumn(label: Text('★ x / y')),
      ],
      rows: const [
        // Example data
        DataRow(cells: [
          DataCell(Text('2025')),
          DataCell(Text('31')),
          DataCell(Text('★ 3 / 5')),
        ]),
      ],
    );
  }

  Widget _buildEntriesForSelectedDay() {
    final uid = Fb.auth.currentUser?.uid;
    if (uid == null) {
      return const Text('Sign in to view entries for the selected day.');
    }
    final start =
        DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final end = start.add(const Duration(days: 1));
    return StreamBuilder<QuerySnapshot>(
      stream: _bingeCollection
          .where('uid', isEqualTo: uid)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThan: Timestamp.fromDate(end))
          .orderBy('date', descending: false)
          .limit(200)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final entries = snapshot.data!.docs
            .map((doc) => BingeEntry.fromFirestore(doc))
            .toList();

        if (entries.isEmpty) {
          return const Text('No entries for this day.');
        }

        final theme = Theme.of(context);
        return Column(
          children: entries
              .map(
                (entry) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(
                      '${entry.time.format(context)} - ${entry.food}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    subtitle: Text(entry.place),
                    trailing: IconButton(
                      icon: Icon(Icons.info_outline,
                          color: theme.colorScheme.primary),
                      onPressed: () => _showEntryDetails(context, entry),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  void _showEntries(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      final uid = Fb.auth.currentUser?.uid;
      if (uid == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Past Entries')),
          body: const Center(child: Text('Sign in to view your past entries.')),
        );
      }
      return Scaffold(
        appBar: AppBar(title: const Text('Past Entries')),
        body: StreamBuilder<QuerySnapshot>(
          stream: _bingeCollection
              .where('uid', isEqualTo: uid)
              .orderBy('date', descending: true)
              .limit(500)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final entries = snapshot.data!.docs
                .map((doc) => BingeEntry.fromFirestore(doc))
                .toList();
            final theme = Theme.of(context);

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    title: Text(
                      '${entry.date.day}/${entry.date.month}/${entry.date.year} at ${entry.time.format(context)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    subtitle: Text(entry.food),
                    trailing: Icon(Icons.chevron_right,
                        color: theme.colorScheme.primary),
                    onTap: () => _showEntryDetails(context, entry),
                  ),
                );
              },
            );
          },
        ),
      );
    }));
  }

  void _showEntryDetails(BuildContext context, BingeEntry entry) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              '${entry.date.day}/${entry.date.month}/${entry.date.year} at ${entry.time.format(context)}'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Place: ${entry.place}'),
              Text('Food: ${entry.food}'),
              Text('Comments: ${entry.comments}'),
              Row(
                children: [
                  if (entry.v) const Chip(label: Text('V')),
                  if (entry.l) const Chip(label: Text('L')),
                  if (entry.starred) const Chip(label: Text('*')),
                ],
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            )
          ],
        );
      },
    );
  }
}
