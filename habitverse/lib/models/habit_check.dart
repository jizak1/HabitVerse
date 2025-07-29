class HabitCheck {
  final String id;
  final String habitId;
  final DateTime dateChecked;
  final int xpEarned;
  final DateTime createdAt;

  HabitCheck({
    required this.id,
    required this.habitId,
    required this.dateChecked,
    required this.xpEarned,
    required this.createdAt,
  });

  factory HabitCheck.fromJson(Map<String, dynamic> json) {
    return HabitCheck(
      id: json['id'] as String,
      habitId: json['habit_id'] as String,
      dateChecked: DateTime.parse(json['date_checked'] as String),
      xpEarned: json['xp_earned'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habit_id': habitId,
      'date_checked': dateChecked.toIso8601String(),
      'xp_earned': xpEarned,
      'created_at': createdAt.toIso8601String(),
    };
  }

  HabitCheck copyWith({
    String? id,
    String? habitId,
    DateTime? dateChecked,
    int? xpEarned,
    DateTime? createdAt,
  }) {
    return HabitCheck(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      dateChecked: dateChecked ?? this.dateChecked,
      xpEarned: xpEarned ?? this.xpEarned,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitCheck && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'HabitCheck(id: $id, habitId: $habitId, dateChecked: $dateChecked, xpEarned: $xpEarned)';
  }
}

class HabitStats {
  final String habitId;
  final int totalChecks;
  final int currentStreak;
  final int longestStreak;
  final int totalXp;
  final DateTime? lastChecked;
  final List<DateTime> checkDates;

  HabitStats({
    required this.habitId,
    required this.totalChecks,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalXp,
    this.lastChecked,
    required this.checkDates,
  });

  factory HabitStats.fromJson(Map<String, dynamic> json) {
    return HabitStats(
      habitId: json['habit_id'] as String,
      totalChecks: json['total_checks'] as int? ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      totalXp: json['total_xp'] as int? ?? 0,
      lastChecked: json['last_checked'] != null 
          ? DateTime.parse(json['last_checked'] as String) 
          : null,
      checkDates: (json['check_dates'] as List<dynamic>?)
          ?.map((date) => DateTime.parse(date as String))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'habit_id': habitId,
      'total_checks': totalChecks,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'total_xp': totalXp,
      'last_checked': lastChecked?.toIso8601String(),
      'check_dates': checkDates.map((date) => date.toIso8601String()).toList(),
    };
  }

  bool get isCheckedToday {
    if (lastChecked == null) return false;
    final today = DateTime.now();
    return lastChecked!.year == today.year &&
           lastChecked!.month == today.month &&
           lastChecked!.day == today.day;
  }

  double get completionRate {
    if (totalChecks == 0) return 0.0;
    final daysSinceCreation = DateTime.now().difference(
      checkDates.isNotEmpty ? checkDates.first : DateTime.now()
    ).inDays + 1;
    return totalChecks / daysSinceCreation;
  }
}
