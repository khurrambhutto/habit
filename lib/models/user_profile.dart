class UserProfile {
  final String id;
  final int streakFreezes;
  final int totalFreezesEarned;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    this.streakFreezes = 1,
    this.totalFreezesEarned = 0,
    this.createdAt,
    this.updatedAt,
  });

  // Convert from Supabase JSON to UserProfile object
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      streakFreezes: json['streak_freezes'] as int? ?? 1,
      totalFreezesEarned: json['total_freezes_earned'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // Convert from UserProfile object to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'streak_freezes': streakFreezes,
      'total_freezes_earned': totalFreezesEarned,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // Create a copy with modified fields
  UserProfile copyWith({
    String? id,
    int? streakFreezes,
    int? totalFreezesEarned,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      streakFreezes: streakFreezes ?? this.streakFreezes,
      totalFreezesEarned: totalFreezesEarned ?? this.totalFreezesEarned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods for streak freeze logic
  bool get hasStreakFreezes => streakFreezes > 0;

  bool get canEarnMoreFreezes => streakFreezes < 3;

  UserProfile useFreeze() {
    if (!hasStreakFreezes) return this;
    return copyWith(streakFreezes: streakFreezes - 1);
  }

  UserProfile earnFreeze() {
    if (!canEarnMoreFreezes) return this;
    return copyWith(
      streakFreezes: streakFreezes + 1,
      totalFreezesEarned: totalFreezesEarned + 1,
    );
  }
}
