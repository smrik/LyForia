
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lyforia/pages/settings_page.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('binge_entries').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = snapshot.data!.docs;
          final weeklyWeights = _calculateWeeklyWeights(entries);
          final starredEvents = _calculateStarredEvents(entries);
          final totalMeals = entries.length;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildChartCard(
                'Average Weight Over Weeks',
                AspectRatio(
                  aspectRatio: 1.7,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: weeklyWeights.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                          isCurved: true,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          belowBarData: BarAreaData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildMetricCard('Starred Events', '$starredEvents'),
              const SizedBox(height: 20),
              _buildMetricCard('Total Meals', '$totalMeals'),
              const SizedBox(height: 20),
              _buildChartCard('Mood Graph', const Text('Mood graph coming soon!')),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            chart,
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }

  Map<int, double> _calculateWeeklyWeights(List<QueryDocumentSnapshot> entries) {
    // This is a placeholder. You will need to implement the logic to calculate the average weight per week.
    return {1: 70, 2: 71, 3: 70.5, 4: 72};
  }

  int _calculateStarredEvents(List<QueryDocumentSnapshot> entries) {
    return entries.where((doc) => doc['starred'] == true).length;
  }
}
