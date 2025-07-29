import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../constants/app_constants.dart';
import '../../widgets/habit_card.dart';
import '../../widgets/avatar_widget.dart';
import '../../widgets/progress_ring.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load habits when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HabitProvider>(context, listen: false).loadHabits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer2<AuthProvider, HabitProvider>(
      builder: (context, authProvider, habitProvider, child) {
        final user = authProvider.user;
        final habits = habitProvider.habits;
        final isLoading = habitProvider.isLoading;

        // Calculate stats
        final completedHabits = habits.where((h) => h.isCompletedToday).toList();
        final pendingHabits = habits.where((h) => !h.isCompletedToday).toList();
        final completionRate = habits.isEmpty ? 0.0 : completedHabits.length / habits.length;

        return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Provider.of<HabitProvider>(context, listen: false).loadHabits();
            await Provider.of<AuthProvider>(context, listen: false).refreshUser();
          },
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good ${_getGreeting()}!',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      user?.name ?? 'User',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: AvatarWidget(
                      user: user,
                      size: 40,
                    ),
                  ),
                ],
              ),
              
              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Progress Overview
                    _buildProgressOverview(
                      theme,
                      user,
                      completedHabits.length,
                      habits.length,
                      completionRate,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Today's Habits Section
                    _buildSectionHeader(theme, 'Today\'s Habits', pendingHabits.length),
                    
                    const SizedBox(height: 12),
                    
                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (habits.isEmpty)
                      _buildEmptyState(theme)
                    else
                      ...pendingHabits.take(3).map((habit) {
                        final stats = null;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: HabitCard(
                            habit: habit,
                            stats: stats,
                            onCheck: () => _checkHabit(habit.id),
                          ),
                        );
                      }),
                    
                    if (pendingHabits.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: TextButton(
                          onPressed: () {
                            // Navigate to habits tab
                            // This would be handled by the parent widget
                          },
                          child: Text('View ${pendingHabits.length - 3} more habits'),
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Completed Today Section
                    if (completedHabits.isNotEmpty) ...[
                      _buildSectionHeader(theme, 'Completed Today', completedHabits.length),
                      const SizedBox(height: 12),
                      ...completedHabits.map((habit) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: HabitCard(
                            habit: habit,
                            isCompleted: true,
                          ),
                        );
                      }),
                    ],
                    
                    const SizedBox(height: 100), // Bottom padding for navigation
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  Widget _buildProgressOverview(
    ThemeData theme,
    user,
    int completedToday,
    int totalHabits,
    double completionRate,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Progress',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$completedToday of $totalHabits habits',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                ProgressRing(
                  progress: totalHabits > 0 ? completedToday / totalHabits : 0.0,
                  size: 60,
                  strokeWidth: 6,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatItem(
                  theme,
                  'Level',
                  '${user?.level ?? 1}',
                  Icons.trending_up,
                ),
                _buildStatItem(
                  theme,
                  'XP',
                  '${user?.xp ?? 0}',
                  Icons.star,
                ),
                _buildStatItem(
                  theme,
                  'Rate',
                  '${(completionRate * 100).toInt()}%',
                  Icons.analytics,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.psychology_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No habits yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first habit to start building better routines',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkHabit(String habitId) async {
    await Provider.of<HabitProvider>(context, listen: false).checkHabit(habitId);
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}
