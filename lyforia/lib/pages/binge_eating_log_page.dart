
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

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
    };
  }

  factory BingeEntry.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    final timeParts = data['time'].split(':');
    return BingeEntry(
      id: doc.id,
      time: TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1])),
      place: data['place'] ?? '',
      v: data['v'] ?? false,
      l: data['l'] ?? false,
      starred: data['starred'] ?? false,
      food: data['food'] ?? '',
      comments: data['comments'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
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
  bool _showCalendar = false;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Map<DateTime, double> _weights = {};

  final CollectionReference _bingeCollection = FirebaseFirestore.instance.collection('binge_entries');

  void _addEntry() {
    if (_formKey.currentState!.validate() && _time != null) {
      _bingeCollection.add(BingeEntry(
        id: '', // Firestore will generate an ID
        time: _time!,
        place: _placeController.text,
        v: _vChecked,
        l: _lChecked,
        starred: _starredChecked,
        food: _foodController.text,
        comments: _commentsController.text,
        date: _selectedDay ?? DateTime.now(),
      ).toJson());
      _formKey.currentState!.reset();
      setState(() {
        _time = null;
        _vChecked = false;
        _lChecked = false;
        _starredChecked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Binge Eating Log'),
        backgroundColor: Theme.of(context).primaryColor.withAlpha(25),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text('Track your eating habits.', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
              _buildTimePicker(),
              const SizedBox(height: 10),
              _buildTextField(_placeController, 'Place', isRequired: true),
              const SizedBox(height: 10),
              _buildCheckboxes(),
              const SizedBox(height: 10),
              _buildTextField(_foodController, 'Food and drink consumed'),
              const SizedBox(height: 10),
              _buildTextField(_commentsController, 'Context and comments', maxLines: 3),
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
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              const Text('Weekly Starred Entries (this month)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
        final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
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

  Widget _buildTextField(TextEditingController controller, String label, {bool isRequired = false, int maxLines = 1}) {
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
        Checkbox(value: _vChecked, onChanged: (value) => setState(() => _vChecked = value!)),
        const Text('V'),
        const SizedBox(width: 20),
        Checkbox(value: _lChecked, onChanged: (value) => setState(() => _lChecked = value!)),
        const Text('L'),
        const SizedBox(width: 20),
        Checkbox(value: _starredChecked, onChanged: (value) => setState(() => _starredChecked = value!)),
        const Text('*'),
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
                style: const TextStyle(fontSize: 10, color: Colors.red),
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
                _weights[DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day)] =
                    double.parse(_weightController.text);
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
    return StreamBuilder<QuerySnapshot>(
      stream: _bingeCollection.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(_selectedDay!)).where('date', isLessThan: Timestamp.fromDate(_selectedDay!.add(const Duration(days: 1)))).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final entries = snapshot.data!.docs.map((doc) => BingeEntry.fromFirestore(doc)).toList();

        if (entries.isEmpty) {
          return const Text('No entries for this day.');
        }

        return Column(
          children: entries.map((entry) => ListTile(
            title: Text('${entry.time.format(context)} - ${entry.food}'),
            subtitle: Text(entry.place),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showEntryDetails(context, entry),
            ),
          )).toList(),
        );
      },
    );
  }

  void _showEntries(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(title: const Text('Past Entries')),
        body: StreamBuilder<QuerySnapshot>(
          stream: _bingeCollection.orderBy('date', descending: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            final entries = snapshot.data!.docs.map((doc) => BingeEntry.fromFirestore(doc)).toList();

            return ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return ListTile(
                  title: Text('${entry.date.day}/${entry.date.month}/${entry.date.year} at ${entry.time.format(context)}'),
                  subtitle: Text(entry.food),
                  onTap: () => _showEntryDetails(context, entry),
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
          title: Text('${entry.date.day}/${entry.date.month}/${entry.date.year} at ${entry.time.format(context)}'),
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

