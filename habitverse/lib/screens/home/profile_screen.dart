import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/habit_provider.dart';
import '../../widgets/avatar_widget.dart';
import '../../constants/app_constants.dart';
import '../../models/user.dart';
import '../../models/habit.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
        final completionRate = _overallStats?['completion_rate'] ?? 0.0;

        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            title: const Text(
              'Profile',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => _showSettings(context),
              ),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profile Header
                      _buildProfileHeader(theme, user),

                      const SizedBox(height: 32),

                      // Stats Cards
                      _buildStatsSection(theme, user, habits, completionRate),

                      const SizedBox(height: 24),

                      // Level Progress
                      _buildLevelProgress(theme, user),

                      const SizedBox(height: 24),

                      // Menu Items
                      _buildMenuSection(theme, context),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildProfileHeader(ThemeData theme, User? user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AnimatedAvatarWidget(
              user: user,
              size: 100,
              showLevel: true,
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'User',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getLevelTitle(user?.level ?? 1),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(ThemeData theme, User? user, List<Habit> habits, double completionRate) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            'Total Habits',
            '${habits.length}',
            Icons.psychology,
            theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme,
            'Completion Rate',
            '${(completionRate * 100).toInt()}%',
            Icons.analytics,
            Colors.green,
          ),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelProgress(ThemeData theme, User? user) {
    final currentXP = user?.xp ?? 0;
    final currentLevel = user?.level ?? 1;
    final xpForNextLevel = _getXPForLevel(currentLevel + 1);
    final xpForCurrentLevel = _getXPForLevel(currentLevel);
    final progress = (currentXP - xpForCurrentLevel) / (xpForNextLevel - xpForCurrentLevel);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Level Progress',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Level $currentLevel',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  'Level ${currentLevel + 1}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: theme.colorScheme.onSurface.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              '$currentXP / $xpForNextLevel XP',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection(ThemeData theme, BuildContext context) {
    return Card(
      child: Column(
        children: [
          _buildMenuItem(
            theme,
            'Notifications',
            Icons.notifications_outlined,
            () => _showNotificationSettings(context),
          ),
          _buildDivider(theme),
          _buildMenuItem(
            theme,
            'Friends',
            Icons.people_outlined,
            () => _showFriends(context),
          ),
          _buildDivider(theme),
          _buildMenuItem(
            theme,
            'Leaderboard',
            Icons.leaderboard_outlined,
            () => _showLeaderboard(context),
          ),
          _buildDivider(theme),
          _buildMenuItem(
            theme,
            'About',
            Icons.info_outlined,
            () => _showAbout(context),
          ),
          _buildDivider(theme),
          _buildMenuItem(
            theme,
            'Logout',
            Icons.logout,
            () => _logout(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    ThemeData theme,
    String title,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? theme.colorScheme.error : theme.colorScheme.onSurface,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? theme.colorScheme.error : null,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Divider(
      height: 1,
      color: theme.colorScheme.onSurface.withOpacity(0.1),
    );
  }

  String _getLevelTitle(int level) {
    for (final entry in AppConstants.levelTitles.entries.toList().reversed) {
      if (level >= entry.key) {
        return entry.value;
      }
    }
    return AppConstants.levelTitles[1]!;
  }

  int _getXPForLevel(int level) {
    // Simple XP calculation: level * 100
    return level * 100;
  }

  void _showSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings coming soon!')),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification settings coming soon!')),
    );
  }

  void _showFriends(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Friends feature coming soon!')),
    );
  }

  void _showLeaderboard(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Leaderboard coming soon!')),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: const Icon(
        Icons.psychology,
        size: 48,
        color: Color(0xFF6366F1),
      ),
      children: [
        const Text('Build better habits, level up your life!'),
      ],
    );
  }

  void _logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
