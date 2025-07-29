import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/habit_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/progress_ring.dart';
import '../../models/user.dart';
import '../../models/habit.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  Map<String, dynamic>? _overallStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await Provider.of<HabitProvider>(context, listen: false)
          .getOverallStats();
      setState(() {
        _overallStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, HabitProvider>(
      builder: (context, authProvider, habitProvider, child) {
        final user = authProvider.user;
        final habits = habitProvider.habits;

        final theme = Theme.of(context);
        final completionRate = _overallStats?['completion_rate'] ?? 0.0;

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            title: const Text(
              'Statistics',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overview Cards
                      _buildOverviewSection(theme, user, habits, completionRate),

                      const SizedBox(height: 24),

                      // Progress Chart
                      _buildProgressChart(theme),

                      const SizedBox(height: 24),

                      // Habit Breakdown
                      _buildHabitBreakdown(theme, habits),

                      const SizedBox(height: 24),

                      // Streaks Section
                      _buildStreaksSection(theme),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildOverviewSection(
    ThemeData theme,
    User? user,
    List<Habit> habits,
    double completionRate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                'Level',
                '${user?.level ?? 1}',
                Icons.trending_up,
                theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme,
                'Total XP',
                '${user?.xp ?? 0}',
                Icons.star,
                Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                'Habits',
                '${habits.length}',
                Icons.psychology,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme,
                'Completion',
                '${(completionRate * 100).toInt()}%',
                Icons.analytics,
                Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Progress',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Text(
                              days[value.toInt()],
                              style: theme.textTheme.bodySmall,
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateWeeklyData(),
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitBreakdown(ThemeData theme, List<Habit> habits) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habit Categories',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            if (habits.isEmpty)
              Center(
                child: Text(
                  'No habits to analyze',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              )
            else
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: _generateCategoryData(habits, theme),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreaksSection(ThemeData theme) {
    // Mock streaks data since we don't have habit stats loaded here
    final streaks = <Map<String, dynamic>>[];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Current Streaks',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (streaks.isEmpty)
              Center(
                child: Text(
                  'No active streaks',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              )
            else
              ...streaks.take(5).map((stats) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        stats['title'] ?? 'Habit Streak',
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    Text(
                      '${stats['current_streak'] ?? 0} days',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateWeeklyData() {
    // Mock data for weekly progress
    return [
      const FlSpot(0, 3),
      const FlSpot(1, 4),
      const FlSpot(2, 2),
      const FlSpot(3, 5),
      const FlSpot(4, 3),
      const FlSpot(5, 4),
      const FlSpot(6, 6),
    ];
  }

  List<PieChartSectionData> _generateCategoryData(List<Habit> habits, ThemeData theme) {
    final categoryCount = <String, int>{};
    
    for (final habit in habits) {
      categoryCount[habit.category] = (categoryCount[habit.category] ?? 0) + 1;
    }

    final colors = [
      theme.colorScheme.primary,
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
    ];

    return categoryCount.entries.map((entry) {
      final index = categoryCount.keys.toList().indexOf(entry.key);
      final percentage = (entry.value / habits.length) * 100;
      
      return PieChartSectionData(
        value: entry.value.toDouble(),
        title: '${percentage.toInt()}%',
        color: colors[index % colors.length],
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
