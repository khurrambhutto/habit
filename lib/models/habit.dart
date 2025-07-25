class Habit {
  final int? id;
  final String name;
  final int streak;
  final bool checkedToday;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Habit({
    this.id,
    required this.name,
    this.streak = 0,
    this.checkedToday = false,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  // Convert from Supabase JSON to Habit object
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as int?,
      name: json['name'] as String,
      streak: json['streak'] as int? ?? 0,
      checkedToday: json['checked_today'] as bool? ?? false,
      userId: json['user_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // Convert from Habit object to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'streak': streak,
      'checked_today': checkedToday,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // Create a copy with modified fields
  Habit copyWith({
    int? id,
    String? name,
    int? streak,
    bool? checkedToday,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      streak: streak ?? this.streak,
      checkedToday: checkedToday ?? this.checkedToday,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
