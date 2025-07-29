class Habit {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final String icon;
  final int color;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isCompletedToday;

  Habit({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    this.isPublic = false,
    required this.createdAt,
    this.updatedAt,
    this.isCompletedToday = false,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String,
      color: json['color'] as int,
      isPublic: json['is_public'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      isCompletedToday: json['is_completed_today'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'icon': icon,
      'color': color,
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Habit copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? category,
    String? icon,
    int? color,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Habit && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Habit(id: $id, title: $title, category: $category)';
  }
}
