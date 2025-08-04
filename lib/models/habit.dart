class Habit {
  final String id;
  final String name;
  bool isCompleted;
  int currentStreak;
  int bestStreak;
  int streakFreezes;
  DateTime createdDate;
  DateTime? lastCompletedDate;
  DateTime? lastStreakFreezeUsed;
  
  // Constants for better maintainability
  static const int maxStreakFreezes = 3;
  static const int streakFreezeEarnInterval = 3;
  
  Habit({
    String? id,
    required this.name,
    this.isCompleted = false,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.streakFreezes = 0,
    DateTime? createdDate,
    this.lastCompletedDate,
    this.lastStreakFreezeUsed,
  }) : 
    id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
    createdDate = createdDate ?? DateTime.now();

  // Optimized: Extract date-only logic to reduce repetition
  static DateTime _dateOnly(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  // Optimized: Single method to calculate days between dates
  static int _daysBetween(DateTime date1, DateTime date2) {
    return _dateOnly(date2).difference(_dateOnly(date1)).inDays;
  }

  // Factory constructor for creating from JSON (Supabase)
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      name: json['name'],
      isCompleted: json['is_completed'] ?? false,
      currentStreak: json['current_streak'] ?? 0,
      bestStreak: json['best_streak'] ?? 0,
      streakFreezes: json['streak_freezes'] ?? 0,
      createdDate: json['created_date'] != null 
          ? DateTime.parse(json['created_date'])
          : DateTime.now(),
      lastCompletedDate: json['last_completed_date'] != null
          ? DateTime.parse(json['last_completed_date'])
          : null,
      lastStreakFreezeUsed: json['last_streak_freeze_used'] != null
          ? DateTime.parse(json['last_streak_freeze_used'])
          : null,
    );
  }

  // Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    final json = {
      'name': name,
      'is_completed': isCompleted,
      'current_streak': currentStreak,
      'best_streak': bestStreak,
      'streak_freezes': streakFreezes,
      'created_date': createdDate.toIso8601String(),
      'last_completed_date': lastCompletedDate?.toIso8601String(),
      'last_streak_freeze_used': lastStreakFreezeUsed?.toIso8601String(),
    };
    
    // Only include ID if it looks like a valid UUID (contains hyphens)
    if (id.contains('-')) {
      json['id'] = id;
    }
    
    return json;
  }

  // Optimized: Main toggle method with cleaner logic flow
  void toggleComplete() {
    final now = DateTime.now();
    final today = _dateOnly(now);
    
    // Always check for daily reset first
    _performDailyReset(today);
    
    if (isCompleted) {
      _handleUncompletion(today);
    } else {
      _handleCompletion(now, today);
    }
  }

  // Optimized: Separated uncompletion logic
  void _handleUncompletion(DateTime today) {
    if (lastCompletedDate == null) return;
    
    final lastDate = _dateOnly(lastCompletedDate!);
    if (lastDate.isAtSameMomentAs(today)) {
      isCompleted = false;
      lastCompletedDate = null;
      currentStreak = (currentStreak > 0) ? currentStreak - 1 : 0;
    }
  }

  // Optimized: Separated completion logic with cleaner streak calculation
  void _handleCompletion(DateTime now, DateTime today) {
    isCompleted = true;
    
    // Calculate new streak
    currentStreak = _calculateNewStreak(today);
    
    // Update completion date
    lastCompletedDate = now;
    
    // Update best streak if needed
    if (currentStreak > bestStreak) {
      bestStreak = currentStreak;
    }
    
    // Check for streak freeze earning
    _checkStreakFreezeEarning();
  }

  // Optimized: Cleaner streak calculation
  int _calculateNewStreak(DateTime today) {
    if (lastCompletedDate == null) return 1;
    
    final lastDate = _dateOnly(lastCompletedDate!);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (lastDate.isAtSameMomentAs(yesterday)) {
      return currentStreak + 1; // Consecutive day
    } else if (lastDate.isAtSameMomentAs(today)) {
      return currentStreak; // Already completed today (edge case)
    } else {
      return 1; // Gap in streak, restart
    }
  }

  // Optimized: Renamed and simplified daily reset
  void _performDailyReset(DateTime today) {
    if (!isCompleted || lastCompletedDate == null) return;
    
    final lastDate = _dateOnly(lastCompletedDate!);
    if (lastDate.isAtSameMomentAs(today)) return; // Same day, no reset needed
    
    // Reset completion status for new day
    isCompleted = false;
    
    // Handle streak based on gap
    final daysMissed = _daysBetween(lastDate, today);
    _handleStreakForMissedDays(daysMissed);
  }

  // Optimized: Cleaner missed days handling
  void _handleStreakForMissedDays(int daysMissed) {
    switch (daysMissed) {
      case 1:
        // Yesterday - streak continues, no action needed
        break;
      case 2:
        // Missed exactly 1 day - try to use streak freeze
        if (streakFreezes > 0) {
          _useStreakFreeze();
        } else {
          currentStreak = 0;
        }
        break;
      default:
        // Missed 2+ days - break streak
        if (daysMissed > 1) {
          currentStreak = 0;
        }
    }
  }

  // Optimized: Simplified streak freeze usage
  void _useStreakFreeze() {
    if (streakFreezes > 0) {
      streakFreezes--;
      lastStreakFreezeUsed = DateTime.now();
    }
  }

  // Optimized: Cleaner streak freeze earning
  void _checkStreakFreezeEarning() {
    if (currentStreak > 0 && 
        currentStreak % streakFreezeEarnInterval == 0 && 
        streakFreezes < maxStreakFreezes) {
      streakFreezes++;
    }
  }

  // Public method for manual streak freeze usage
  bool useStreakFreeze() {
    if (streakFreezes > 0) {
      _useStreakFreeze();
      return true;
    }
    return false;
  }

  // PUBLIC COMPATIBILITY METHODS (for existing main.dart and tests)
  void checkDailyReset() {
    final today = _dateOnly(DateTime.now());
    _performDailyReset(today);
  }
  
  void checkStreakReset() {
    // Legacy method - now just calls the optimized daily reset logic
    checkDailyReset();
  }
  
  void resetStreak() {
    currentStreak = 0;
    bestStreak = 0;
    streakFreezes = 0;
    isCompleted = false;
    lastCompletedDate = null;
    lastStreakFreezeUsed = null;
  }

  // Optimized: Better string formatting
  String getStreakFreezeStatus() {
    return streakFreezes > 0 ? '❄️ Streak Freezes: $streakFreezes' : '';
  }

  // Optimized: More descriptive property name and cleaner logic
  bool get wasStreakFreezeRecentlyUsed {
    if (lastStreakFreezeUsed == null) return false;
    return _daysBetween(lastStreakFreezeUsed!, DateTime.now()) <= 1;
  }

  // Added: Helpful getters for UI
  bool get isOnStreak => currentStreak > 0;
  bool get canEarnStreakFreeze => (currentStreak + 1) % streakFreezeEarnInterval == 0 && streakFreezes < maxStreakFreezes;
  String get streakDisplay => currentStreak > 0 ? '🔥 $currentStreak days' : 'Start your streak!';
}