import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../constants/app_constants.dart';
import '../../widgets/avatar_widget.dart';
import '../../models/user.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = true;
  String _selectedPeriod = 'weekly';

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await ApiService.get(
        '/leaderboard?period=$_selectedPeriod&limit=50',
        token: authProvider.token,
      );

      if (response['success']) {
        setState(() {
          _leaderboard = List<Map<String, dynamic>>.from(
            response['data']['leaderboard']
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load leaderboard: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'weekly',
                        label: Text('Weekly'),
                      ),
                      ButtonSegment(
                        value: 'monthly',
                        label: Text('Monthly'),
                      ),
                      ButtonSegment(
                        value: 'all',
                        label: Text('All Time'),
                      ),
                    ],
                    selected: {_selectedPeriod},
                    onSelectionChanged: (Set<String> selection) {
                      setState(() {
                        _selectedPeriod = selection.first;
                      });
                      _loadLeaderboard();
                    },
                    style: SegmentedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      foregroundColor: Colors.white,
                      selectedBackgroundColor: Colors.white,
                      selectedForegroundColor: AppConstants.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLeaderboard,
              child: _leaderboard.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emoji_events_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No users found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _leaderboard.length,
                      itemBuilder: (context, index) {
                        final user = _leaderboard[index];
                        final rank = user['rank'];
                        final isCurrentUser = Provider.of<AuthProvider>(context, listen: false)
                            .user?.id == user['id'];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isCurrentUser
                                ? AppConstants.primaryColor.withValues(alpha: 0.1)
                                : null,
                            borderRadius: BorderRadius.circular(12),
                            border: isCurrentUser 
                                ? Border.all(color: AppConstants.primaryColor, width: 2)
                                : null,
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: _getRankColor(rank),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      rank <= 3 ? _getRankEmoji(rank) : '$rank',
                                      style: TextStyle(
                                        color: rank <= 3 ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: rank <= 3 ? 16 : 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                AvatarWidget(
                                  user: User(
                                    id: user['id'] ?? '',
                                    name: user['name'] ?? 'Unknown',
                                    email: user['email'] ?? '',
                                    xp: user['xp'] ?? 0,
                                    level: user['level'] ?? 1,
                                    avatarUrl: user['avatar_url'],
                                    createdAt: DateTime.now(),
                                  ),
                                  size: 48,
                                ),
                              ],
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    user['name'],
                                    style: TextStyle(
                                      fontWeight: isCurrentUser 
                                          ? FontWeight.bold 
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (isCurrentUser)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppConstants.primaryColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'You',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            subtitle: Text(
                              'Level ${user['level']}',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${user['xp']} XP',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber[600],
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${user['level']}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.grey[400]!; // Silver
      case 3:
        return Colors.brown[400]!; // Bronze
      default:
        return Colors.grey[200]!;
    }
  }

  String _getRankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '$rank';
    }
  }
}
