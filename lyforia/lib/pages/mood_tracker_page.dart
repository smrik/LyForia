import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lyforia/utils/firebase_refs.dart';

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  State<MoodTrackerPage> createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  double _moodValue = 3.0;
  final _notesController = TextEditingController();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Mood Check-in'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'How are you feeling today?',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            _buildMoodSlider(),
            const SizedBox(height: 20),
            _buildNotesField(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saving ? null : _saveMood,
              child: _saving
                  ? const CircularProgressIndicator()
                  : const Text('Save Mood'),
            ),
            const SizedBox(height: 20),
            Text(
              'Weekly/Monthly Mood Graph',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildMoodCharts(),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSlider() {
    return Column(
      children: [
        Slider(
          value: _moodValue,
          min: 1,
          max: 5,
          divisions: 4,
          label: _moodValue.round().toString(),
          onChanged: (value) {
            setState(() {
              _moodValue = value;
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('😔'),
            Text('😕'),
            Text('😐'),
            Text('🙂'),
            Text('😄'),
          ],
        )
      ],
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      decoration: const InputDecoration(
        labelText: 'Optional Notes',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Future<void> _saveMood() async {
    final uid = Fb.auth.currentUser?.uid;
    if (uid == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please sign in to save mood entries.')));
      return;
    }
    setState(() => _saving = true);
    try {
      await Fb.firestore.collection('moods').add({
        'mood': _moodValue.round(),
        'notes': _notesController.text.trim(),
        'dateTime': FieldValue.serverTimestamp(),
        'uid': uid,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Mood saved')));
      _notesController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to save mood: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildMoodCharts() {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 30));
    final uid = Fb.auth.currentUser?.uid;
    if (uid == null) {
      return const Center(
        child: Text('Sign in to view your mood trends.'),
      );
    }
    return StreamBuilder<QuerySnapshot>(
      stream: Fb.firestore
          .collection('moods')
          .where('uid', isEqualTo: uid)
          .where('dateTime', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .orderBy('dateTime', descending: false)
          .limit(1000)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading mood data'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        // Aggregate by day to average moods
        final Map<DateTime, List<int>> map = {};
        for (final d in docs) {
          final data = d.data() as Map<String, dynamic>?;
          final ts = data?['dateTime'] as Timestamp?;
          final mood = (data?['mood'] as num?)?.toInt();
          if (ts == null || mood == null) continue;
          final dt = ts.toDate();
          final day = DateTime(dt.year, dt.month, dt.day);
          map.putIfAbsent(day, () => []).add(mood);
        }
        final days = map.keys.toList()..sort();
        final last7Start = now.subtract(const Duration(days: 7));
        final weekly = <FlSpot>[];
        final monthly = <FlSpot>[];
        int idx7 = 0;
        int idx30 = 0;
        for (final day in days) {
          final vals = map[day]!;
          final avg = vals.reduce((a, b) => a + b) / vals.length;
          if (day.isAfter(last7Start)) {
            weekly.add(FlSpot(idx7.toDouble(), avg.toDouble()));
            idx7++;
          }
          monthly.add(FlSpot(idx30.toDouble(), avg.toDouble()));
          idx30++;
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Mood', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SizedBox(height: 90, child: _line(weekly)),
            const SizedBox(height: 12),
            Text('Monthly Mood', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SizedBox(height: 90, child: _line(monthly)),
          ],
        );
      },
    );
  }

  Widget _line(List<FlSpot> spots) {
    final color = Theme.of(context).colorScheme.primary;
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots.isEmpty ? [const FlSpot(0, 0)] : spots,
            isCurved: true,
            barWidth: 3,
            color: color,
            isStrokeCapRound: true,
            belowBarData:
                BarAreaData(show: true, color: color.withOpacity(0.12)),
          ),
        ],
      ),
    );
  }
}
