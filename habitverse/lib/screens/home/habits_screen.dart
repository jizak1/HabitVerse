import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/habit_provider.dart';
import '../../constants/app_constants.dart';
import '../../widgets/habit_card.dart';
import '../../models/habit.dart';
import '../habits/create_habit_screen.dart';
import '../habits/habit_detail_screen.dart';
import '../social/friends_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  String _selectedCategory = 'All';

  final List<String> _categories = [
    'All', 'Health', 'Fitness', 'Learning', 'Productivity', 
    'Mindfulness', 'Social', 'Creative', 'Finance'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HabitProvider>(context, listen: false).loadHabits();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        return Scaffold(
          backgroundColor: theme.colorScheme.surface,
          appBar: AppBar(
            title: const Text(
              'My Habits',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppConstants.primaryColor,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const FriendsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.people),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateHabitScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          body: habitProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : habitProvider.habits.isEmpty
                  ? _buildEmptyState()
                  : _buildHabitsList(habitProvider.habits),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No habits yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first habit to get started!',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CreateHabitScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Habit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsList(List<Habit> habits) {
    final filteredHabits = _selectedCategory == 'All'
        ? habits
        : habits.where((habit) => habit.category == _selectedCategory).toList();

    return Column(
      children: [
        // Category Filter
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = category == _selectedCategory;
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  selectedColor: AppConstants.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppConstants.primaryColor,
                ),
              );
            },
          ),
        ),
        // Habits List
        Expanded(
          child: filteredHabits.isEmpty
              ? Center(
                  child: Text(
                    'No habits in $_selectedCategory category',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredHabits.length,
                  itemBuilder: (context, index) {
                    final habit = filteredHabits[index];
                    return HabitCard(
                      habit: habit,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => HabitDetailScreen(habit: habit),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
