
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MoodTrackerPage extends StatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  State<MoodTrackerPage> createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends State<MoodTrackerPage> {
  double _moodValue = 3.0;
  final _notesController = TextEditingController();

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
            const Text('How are you feeling today?', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            _buildMoodSlider(),
            const SizedBox(height: 20),
            _buildNotesField(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Save Mood'),
            ),
            const SizedBox(height: 20),
            const Text('Weekly/Monthly Mood Graph', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: _buildMoodChart(),
            ),
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

  Widget _buildMoodChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: const [
              FlSpot(0, 3),
              FlSpot(1, 4),
              FlSpot(2, 2),
              FlSpot(3, 5),
              FlSpot(4, 3),
              FlSpot(5, 4),
              FlSpot(6, 3),
            ],
            isCurved: true,
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}
