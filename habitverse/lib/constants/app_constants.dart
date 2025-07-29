import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'HabitVerse';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'http://localhost:3002/api';

  // Theme Colors
  static const Color primaryColor = Color(0xFF6366F1);
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  
  // Gamification
  static const int xpPerHabit = 10;
  static const int streakBonus = 5;
  static const Map<int, String> levelTitles = {
    1: 'Beginner',
    5: 'Novice',
    10: 'Apprentice',
    20: 'Expert',
    50: 'Master',
    100: 'Legend',
  };
  
  // Habit Categories
  static const List<String> habitCategories = [
    'Health',
    'Fitness',
    'Learning',
    'Productivity',
    'Mindfulness',
    'Social',
    'Creative',
    'Finance',
  ];
  
  // Habit Icons
  static const Map<String, String> habitIcons = {
    'Health': '🏥',
    'Fitness': '💪',
    'Learning': '📚',
    'Productivity': '⚡',
    'Mindfulness': '🧘',
    'Social': '👥',
    'Creative': '🎨',
    'Finance': '💰',
  };
  
  // Colors
  static const Map<String, int> habitColors = {
    'Health': 0xFF4CAF50,
    'Fitness': 0xFFFF5722,
    'Learning': 0xFF2196F3,
    'Productivity': 0xFFFF9800,
    'Mindfulness': 0xFF9C27B0,
    'Social': 0xFFE91E63,
    'Creative': 0xFF673AB7,
    'Finance': 0xFF009688,
  };
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  // Notification Settings
  static const String notificationChannelId = 'habit_reminders';
  static const String notificationChannelName = 'Habit Reminders';
  static const String notificationChannelDescription = 'Daily habit reminder notifications';
}
