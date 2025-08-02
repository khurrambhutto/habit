class Habit {
  final String id;
  final String name;
  bool isCompleted;
  int currentStreak;
  int bestStreak;
  int streakFreezes; // Number of available streak freezes
  DateTime createdDate;
  DateTime? lastCompletedDate;
  DateTime? lastStreakFreezeUsed; // Track when streak freeze was last used
  
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

  void toggleComplete() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    // Check if habit should be auto-reset for new day
    checkDailyReset();
    
    if (isCompleted) {
      // Uncompleting - only if it was completed today
      if (lastCompletedDate != null) {
        final lastDate = DateTime(
          lastCompletedDate!.year, 
          lastCompletedDate!.month, 
          lastCompletedDate!.day
        );
        if (lastDate.isAtSameMomentAs(todayDate)) {
          // Only allow uncompleting if it was completed today
          isCompleted = false;
          lastCompletedDate = null;
          currentStreak = 0; // Reset streak when uncompleting today's task
        }
      }
    } else {
      // Completing for today
      isCompleted = true;
      
      // Calculate streak based on last completion
      if (lastCompletedDate != null) {
        final lastDate = DateTime(
          lastCompletedDate!.year, 
          lastCompletedDate!.month, 
          lastCompletedDate!.day
        );
        final yesterday = todayDate.subtract(Duration(days: 1));
        
        if (lastDate.isAtSameMomentAs(yesterday)) {
          // Consecutive day - increase streak
          currentStreak++;
        } else if (lastDate.isAtSameMomentAs(todayDate)) {
          // Already completed today (shouldn't happen after reset check)
          return;
        } else {
          // Gap in streak - reset to 1
          currentStreak = 1;
        }
      } else {
        // First completion ever
        currentStreak = 1;
      }
      
      // Set the completion date to today
      lastCompletedDate = today;
      
      // Update best streak if current is higher
      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
      }
      
      // Check if user earned a streak freeze (3 consecutive days)
      _checkStreakFreezeEarning();
    }
  }

  // Check if habit should be reset for a new day
  void checkDailyReset() {
    if (!isCompleted) return; // Already unchecked
    
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    if (lastCompletedDate != null) {
      final lastDate = DateTime(
        lastCompletedDate!.year, 
        lastCompletedDate!.month, 
        lastCompletedDate!.day
      );
      
      // If last completion was not today, reset the habit
      if (!lastDate.isAtSameMomentAs(todayDate)) {
        isCompleted = false;
        
        // Calculate days between last completion and today
        final daysDifference = todayDate.difference(lastDate).inDays;
        
        if (daysDifference == 1) {
          // Yesterday - keep streak, just reset for new day
          // Streak will increase when habit is completed today
        } else if (daysDifference == 2 && streakFreezes > 0) {
          // Missed exactly 1 day and have freezes - auto-use freeze
          _autoUseStreakFreeze();
        } else if (daysDifference > 1) {
          // Missed 2+ days or no freezes - break streak
          currentStreak = 0;
        }
      }
    }
  }

  // Automatically use a streak freeze for missed day
  void _autoUseStreakFreeze() {
    if (streakFreezes > 0) {
      streakFreezes--;
      lastStreakFreezeUsed = DateTime.now();
      // Keep the streak intact
    }
  }

  // Check if user earned a streak freeze by completing 3 consecutive days
  void _checkStreakFreezeEarning() {
    // Earn 1 streak freeze every 3 days (at days 3, 6, 9, 12, etc.)
    // Maximum of 3 streak freezes
    if (currentStreak % 3 == 0 && currentStreak > 0 && streakFreezes < 3) {
      streakFreezes++;
    }
  }

  // Use a streak freeze to maintain streak when missing a day
  bool useStreakFreeze() {
    if (streakFreezes > 0) {
      streakFreezes--;
      lastStreakFreezeUsed = DateTime.now();
      return true;
    }
    return false;
  }

  // Check if streak should be reset due to missed days, considering streak freezes
  void checkStreakReset() {
    if (lastCompletedDate != null && !isCompleted) {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final lastDate = DateTime(
        lastCompletedDate!.year, 
        lastCompletedDate!.month, 
        lastCompletedDate!.day
      );
      final daysDifference = todayDate.difference(lastDate).inDays;
      
      if (daysDifference > 1) {
        // Check if we can use a streak freeze
        if (streakFreezes > 0 && daysDifference == 2) {
          // Only use streak freeze for exactly 2 days gap (1 missed day)
          useStreakFreeze();
          // Don't reset streak, just update last completed date to yesterday
          lastCompletedDate = todayDate.subtract(Duration(days: 1));
        } else {
          // Reset streak if gap is too large or no freezes available
          currentStreak = 0;
        }
      }
    }
  }

  void resetStreak() {
    currentStreak = 0;
    bestStreak = 0;
    streakFreezes = 0;
    isCompleted = false;
    lastCompletedDate = null;
    lastStreakFreezeUsed = null;
  }

  // Get streak freeze status for display
  String getStreakFreezeStatus() {
    if (streakFreezes > 0) {
      return '❄️ Streak Freezes: $streakFreezes';
    }
    return '';
  }

  // Check if streak freeze was recently used
  bool get wasStreakFreezeRecentlyUsed {
    if (lastStreakFreezeUsed == null) return false;
    final now = DateTime.now();
    final difference = now.difference(lastStreakFreezeUsed!).inDays;
    return difference <= 1; // Consider "recently used" if within 1 day
  }
} 