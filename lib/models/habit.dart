class Habit {
  final String id;
  final String name;
  bool isCompleted;
  int currentStreak;
  int bestStreak;
  DateTime createdDate;
  DateTime? lastCompletedDate;
  
  Habit({
    required this.name,
    this.isCompleted = false,
    this.currentStreak = 0,
    this.bestStreak = 0,
    DateTime? createdDate,
  }) : 
    id = DateTime.now().millisecondsSinceEpoch.toString(),
    createdDate = createdDate ?? DateTime.now();

  void toggleComplete() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    if (isCompleted) {
      // Uncompleting - reset streak if it was completed today
      if (lastCompletedDate != null) {
        final lastDate = DateTime(
          lastCompletedDate!.year, 
          lastCompletedDate!.month, 
          lastCompletedDate!.day
        );
        if (lastDate.isAtSameMomentAs(todayDate)) {
          currentStreak = 0;
        }
      }
      isCompleted = false;
      lastCompletedDate = null;
    } else {
      // Completing
      isCompleted = true;
      
      // Check if this continues the streak
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
          // Same day - no change to streak
        } else {
          // Gap in streak - reset to 1
          currentStreak = 1;
        }
      } else {
        // First completion ever
        currentStreak = 1;
      }
      
      // Set the completion date after logic
      lastCompletedDate = today;
      
      // Update best streak if current is higher
      if (currentStreak > bestStreak) {
        bestStreak = currentStreak;
      }
    }
  }

  void resetStreak() {
    currentStreak = 0;
    bestStreak = 0;
    isCompleted = false;
    lastCompletedDate = null;
  }

  // Check if streak should be reset due to missed days
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
        currentStreak = 0;
      }
    }
  }
} 