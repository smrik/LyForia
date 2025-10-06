import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lyforia/pages/settings_page.dart';
import 'package:lyforia/utils/firebase_refs.dart';
import 'package:lyforia/utils/migrations.dart';

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
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'migrate') {
                _runBackfill(context);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'migrate',
                child: Text('Run Migration (admin)'),
              ),
            ],
          ),
        ],
      ),
      body: Builder(builder: (context) {
        final uid = Fb.auth.currentUser?.uid;
        if (uid == null) {
          return _buildInfoState(
            context,
            title: 'Sign in required',
            message: 'Sign in to view your analytics.',
            icon: Icons.lock_outline,
          );
        }
        return StreamBuilder<QuerySnapshot>(
          stream: Fb.firestore
              .collection('binge_entries')
              .where('uid', isEqualTo: uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildInfoState(
                context,
                title: 'Analytics Unavailable',
                message: 'Connect Firebase to enable analytics.',
                icon: Icons.insights_outlined,
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting ||
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final entries = snapshot.data!.docs;
            if (entries.isEmpty) {
              return _buildInfoState(
                context,
                title: 'No Data Yet',
                message: 'Add some entries to see analytics.',
                icon: Icons.bar_chart,
              );
            }

            final weeklyCounts = _calculateWeeklyEntryCounts(entries);
            final hourlyCounts = _calculateHourlyEntryCounts(entries);
            final starredEvents = _calculateStarredEvents(entries);
            final totalMeals = entries.length;

            final theme = Theme.of(context);
            final localizations = MaterialLocalizations.of(context);
            final lineColor = theme.colorScheme.primary;
            final barColor = theme.colorScheme.tertiaryContainer;
            final weeklySpots = [
              for (int i = 0; i < weeklyCounts.length; i++)
                FlSpot(i.toDouble(), weeklyCounts[i].count.toDouble()),
            ];
            final weeklyLabelInterval = _labelInterval(weeklyCounts.length);
            final maxHourly = hourlyCounts.reduce(math.max);

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildChartCard(
                  'Entries per Week',
                  AspectRatio(
                    aspectRatio: 1.7,
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        gridData: const FlGridData(
                            show: true, drawVerticalLine: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: true, reservedSize: 36),
                          ),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= weeklyCounts.length) {
                                  return const SizedBox.shrink();
                                }
                                if (index % weeklyLabelInterval != 0 &&
                                    index != weeklyCounts.length - 1) {
                                  return const SizedBox.shrink();
                                }
                                final label = localizations
                                    .formatShortDate(weeklyCounts[index].date);
                                return SideTitleWidget(
                                  meta: meta,
                                  space: 8,
                                  child: Text(label,
                                      style: theme.textTheme.bodySmall),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            color: lineColor,
                            spots: weeklySpots.isEmpty
                                ? [const FlSpot(0, 0)]
                                : weeklySpots,
                            isCurved: true,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: lineColor.withValues(alpha: 0.15),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildMetricRow(context, [
                  _Metric('Starred Events', '$starredEvents', Icons.star),
                  _Metric('Total Meals', '$totalMeals', Icons.fastfood),
                ]),
                const SizedBox(height: 20),
                _buildChartCard(
                  'Entries by Hour',
                  SizedBox(
                    height: 220,
                    child: BarChart(
                      BarChartData(
                        maxY: maxHourly == 0 ? 1 : maxHourly.toDouble() * 1.2,
                        gridData: const FlGridData(
                            show: true, drawVerticalLine: false),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: true, reservedSize: 36),
                          ),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                final hour = value.toInt();
                                if (hour < 0 || hour >= hourlyCounts.length) {
                                  return const SizedBox.shrink();
                                }
                                if (hour % 6 != 0 &&
                                    hour != hourlyCounts.length - 1) {
                                  return const SizedBox.shrink();
                                }
                                final label = _formatHourLabel(hour);
                                return SideTitleWidget(
                                  meta: meta,
                                  space: 6,
                                  child: Text(label,
                                      style: theme.textTheme.bodySmall),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: [
                          for (int i = 0; i < hourlyCounts.length; i++)
                            BarChartGroupData(
                              x: i,
                              barRods: [
                                BarChartRodData(
                                  toY: hourlyCounts[i].toDouble(),
                                  color: barColor,
                                  width: 8,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                StreamBuilder<QuerySnapshot>(
                  stream: Fb.firestore
                      .collection('moods')
                      .where('uid', isEqualTo: uid)
                      .where(
                        'dateTime',
                        isGreaterThanOrEqualTo: Timestamp.fromDate(
                          DateTime.now().subtract(const Duration(days: 30)),
                        ),
                      )
                      .orderBy('dateTime', descending: false)
                      .limit(1000)
                      .snapshots(),
                  builder: (context, moodSnapshot) {
                    if (moodSnapshot.hasError) {
                      return _buildChartCard(
                        'Mood Trend',
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(child: Text('Error loading mood data')),
                        ),
                      );
                    }
                    if (moodSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _buildChartCard(
                        'Mood Trend',
                        const SizedBox(
                          height: 180,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }
                    final moodDocs = moodSnapshot.data?.docs ?? [];
                    if (moodDocs.isEmpty) {
                      return _buildChartCard(
                        'Mood Trend',
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text('Log your mood to see trends here.'),
                        ),
                      );
                    }

                    final moodAverages = _calculateDailyMoodAverages(moodDocs);
                    final moodSpots = [
                      for (int i = 0; i < moodAverages.length; i++)
                        FlSpot(i.toDouble(), moodAverages[i].value),
                    ];
                    final moodLabelInterval =
                        _labelInterval(moodAverages.length);
                    final averageMood = moodAverages.isEmpty
                        ? null
                        : moodAverages
                                .map((e) => e.value)
                                .reduce((a, b) => a + b) /
                            moodAverages.length;
                    final moodColor = theme.colorScheme.secondary;

                    return _buildChartCard(
                      'Mood Trend (Last 30 Days)',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 220,
                            child: LineChart(
                              LineChartData(
                                minY: 1,
                                maxY: 5,
                                gridData: const FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: const AxisTitles(
                                    sideTitles: SideTitles(
                                        showTitles: true, reservedSize: 28),
                                  ),
                                  rightTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  topTitles: const AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 32,
                                      interval: 1,
                                      getTitlesWidget: (value, meta) {
                                        final index = value.toInt();
                                        if (index < 0 ||
                                            index >= moodAverages.length) {
                                          return const SizedBox.shrink();
                                        }
                                        if (index % moodLabelInterval != 0 &&
                                            index != moodAverages.length - 1) {
                                          return const SizedBox.shrink();
                                        }
                                        final label =
                                            localizations.formatShortDate(
                                                moodAverages[index].date);
                                        return SideTitleWidget(
                                          meta: meta,
                                          space: 8,
                                          child: Text(label,
                                              style: theme.textTheme.bodySmall),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: moodSpots.isEmpty
                                        ? [const FlSpot(0, 0)]
                                        : moodSpots,
                                    isCurved: true,
                                    barWidth: 3,
                                    color: moodColor,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: moodColor.withValues(alpha: 0.12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (averageMood != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Average mood: ${averageMood.toStringAsFixed(1)}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      }),
    );
  }

  Widget _buildInfoState(BuildContext context,
      {required String title,
      required String message,
      required IconData icon}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            chart,
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(BuildContext context, List<_Metric> items) {
    return Row(
      children: [
        for (final m in items)
          Expanded(
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12),
                child: Column(
                  children: [
                    Icon(m.icon, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 8),
                    Text(m.title,
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    Text(m.value,
                        style: Theme.of(context).textTheme.titleLarge),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<_TimeCount> _calculateWeeklyEntryCounts(
      List<QueryDocumentSnapshot> entries) {
    final Map<DateTime, int> countsByWeekStart = {};
    for (final doc in entries) {
      try {
        final data = doc.data() as Map<String, dynamic>?;
        final ts =
            (data?['dateTime'] as Timestamp?) ?? (data?['date'] as Timestamp?);
        if (ts == null) continue;
        final d = ts.toDate();
        final dateOnly = DateTime(d.year, d.month, d.day);
        final weekStart =
            dateOnly.subtract(Duration(days: dateOnly.weekday - 1));
        final key = DateTime(weekStart.year, weekStart.month, weekStart.day);
        countsByWeekStart.update(key, (value) => value + 1, ifAbsent: () => 1);
      } catch (_) {
        // ignore malformed docs
      }
    }
    final sortedKeys = countsByWeekStart.keys.toList()..sort();
    final recentKeys = sortedKeys.length > 8
        ? sortedKeys.sublist(sortedKeys.length - 8)
        : sortedKeys;
    return [
      for (final k in recentKeys) _TimeCount(k, countsByWeekStart[k] ?? 0)
    ];
  }

  List<int> _calculateHourlyEntryCounts(List<QueryDocumentSnapshot> entries) {
    final counts = List<int>.filled(24, 0);
    for (final doc in entries) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) continue;
      try {
        Timestamp? ts = data['dateTime'] as Timestamp?;
        ts ??= data['date'] as Timestamp?;
        DateTime? dateTime = ts?.toDate();
        if (dateTime == null) {
          final hourFromString =
              _parseHourFromTimeString(data['time'] as String?);
          if (hourFromString == null) continue;
          counts[hourFromString]++;
        } else {
          counts[dateTime.hour]++;
        }
      } catch (_) {
        // ignore malformed docs
      }
    }
    return counts;
  }

  List<_TimeValue> _calculateDailyMoodAverages(
      List<QueryDocumentSnapshot> docs) {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final Map<DateTime, List<double>> moodsByDay = {};
    for (final doc in docs) {
      try {
        final data = doc.data() as Map<String, dynamic>?;
        final ts = (data?['dateTime'] as Timestamp?) ??
            (data?['createdAt'] as Timestamp?);
        final mood = (data?['mood'] as num?)?.toDouble();
        if (ts == null || mood == null) continue;
        final instant = ts.toDate();
        if (instant.isBefore(cutoff)) continue;
        final day = DateTime(instant.year, instant.month, instant.day);
        moodsByDay.putIfAbsent(day, () => <double>[]).add(mood);
      } catch (_) {
        // ignore malformed docs
      }
    }
    final days = moodsByDay.keys.toList()..sort();
    return [
      for (final day in days)
        _TimeValue(
          day,
          moodsByDay[day]!.reduce((a, b) => a + b) / moodsByDay[day]!.length,
        )
    ];
  }

  int _calculateStarredEvents(List<QueryDocumentSnapshot> entries) {
    int count = 0;
    for (final doc in entries) {
      final data = doc.data() as Map<String, dynamic>?;
      final starred = (data?['starred'] as bool?) ?? false;
      if (starred) count++;
    }
    return count;
  }

  int _labelInterval(int length) {
    if (length <= 1) {
      return 1;
    }
    return math.max(1, (length / 5).ceil());
  }

  int? _parseHourFromTimeString(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final parts = value.split(':');
    if (parts.isEmpty) {
      return null;
    }
    return int.tryParse(parts.first);
  }

  String _formatHourLabel(int hour) {
    if (hour == 0) {
      return '12a';
    }
    if (hour == 12) {
      return '12p';
    }
    if (hour < 12) {
      return '${hour}a';
    }
    final adjusted = hour - 12;
    return '${adjusted}p';
  }
}

Future<void> _runBackfill(BuildContext context) async {
  final messenger = ScaffoldMessenger.of(context);

  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Run Migration'),
      content: const Text(
          'Backfill missing dateTime values from date + time for binge_entries. Proceed?'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel')),
        ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Run')),
      ],
    ),
  );
  if (confirm != true) return;

  messenger.showSnackBar(
    const SnackBar(content: Text('Migration started...')),
  );

  try {
    final updated = await backfillBingeEntriesDateTime();
    if (!messenger.mounted) return;
    messenger.showSnackBar(
      SnackBar(
          content: Text('Migration complete. Updated $updated documents.')),
    );
  } catch (e) {
    if (!messenger.mounted) return;
    messenger.showSnackBar(
      SnackBar(content: Text('Migration failed: $e')),
    );
  }
}

class _Metric {
  final String title;
  final String value;
  final IconData icon;
  _Metric(this.title, this.value, this.icon);
}

class _TimeCount {
  final DateTime date;
  final int count;
  _TimeCount(this.date, this.count);
}

class _TimeValue {
  final DateTime date;
  final double value;
  _TimeValue(this.date, this.value);
}
