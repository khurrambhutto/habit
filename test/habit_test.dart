import 'package:flutter_test/flutter_test.dart';
import 'package:habit/models/habit.dart';

void main() {
  group('Habit Streak Tests', () {
    test('should increment streak for consecutive days', () {
      final habit = Habit(name: 'Test Habit');
      
      // Complete on day 1
      habit.toggleComplete();
      expect(habit.currentStreak, 1);
      expect(habit.bestStreak, 1);
      expect(habit.isCompleted, true);
      
      // Simulate next day by manually setting lastCompletedDate to yesterday
      final yesterday = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = yesterday;
      habit.isCompleted = false;
      
      // Complete on day 2
      habit.toggleComplete();
      expect(habit.currentStreak, 2);
      expect(habit.bestStreak, 2);
      expect(habit.isCompleted, true);
    });

    test('should maintain streak for 3 consecutive days', () {
      final habit = Habit(name: 'Test Habit');
      
      // Day 1
      habit.toggleComplete();
      expect(habit.currentStreak, 1);
      expect(habit.bestStreak, 1);
      
      // Simulate day 2
      final day2 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day2;
      habit.isCompleted = false;
      
      // Day 2
      habit.toggleComplete();
      expect(habit.currentStreak, 2);
      expect(habit.bestStreak, 2);
      
      // Simulate day 3
      final day3 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day3;
      habit.isCompleted = false;
      
      // Day 3
      habit.toggleComplete();
      expect(habit.currentStreak, 3);
      expect(habit.bestStreak, 3);
    });

    test('should reset streak when there is a gap of more than 1 day', () {
      final habit = Habit(name: 'Test Habit');
      
      // Day 1
      habit.toggleComplete();
      expect(habit.currentStreak, 1);
      
      // Simulate day 3 (skipping day 2)
      final day3 = DateTime.now().subtract(Duration(days: 2));
      habit.lastCompletedDate = day3;
      habit.isCompleted = false;
      
      // Complete on day 3
      habit.toggleComplete();
      expect(habit.currentStreak, 1); // Should reset to 1, not continue streak
      expect(habit.bestStreak, 1); // Best streak should remain 1
    });

    test('should handle multiple completions on the same day without affecting streak', () {
      final habit = Habit(name: 'Test Habit');
      
      // Complete on day 1
      habit.toggleComplete();
      expect(habit.currentStreak, 1);
      
      // Uncomplete and complete again on the same day
      habit.toggleComplete(); // Uncomplete
      habit.toggleComplete(); // Complete again
      expect(habit.currentStreak, 1); // Should still be 1
      expect(habit.bestStreak, 1);
    });

    test('should update best streak when current streak exceeds it', () {
      final habit = Habit(name: 'Test Habit');
      
      // Day 1
      habit.toggleComplete();
      expect(habit.currentStreak, 1);
      expect(habit.bestStreak, 1);
      
      // Simulate day 2
      final day2 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day2;
      habit.isCompleted = false;
      
      // Day 2
      habit.toggleComplete();
      expect(habit.currentStreak, 2);
      expect(habit.bestStreak, 2);
      
      // Simulate day 3
      final day3 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day3;
      habit.isCompleted = false;
      
      // Day 3
      habit.toggleComplete();
      expect(habit.currentStreak, 3);
      expect(habit.bestStreak, 3);
      
      // Now break the streak and start a new one
      final day5 = DateTime.now().subtract(Duration(days: 2)); // Skip day 4
      habit.lastCompletedDate = day5;
      habit.isCompleted = false;
      
      // Complete on day 5
      habit.toggleComplete();
      expect(habit.currentStreak, 1); // Reset to 1
      expect(habit.bestStreak, 3); // Best streak should remain 3
    });

    test('should handle streak reset when uncompleting on the same day', () {
      final habit = Habit(name: 'Test Habit');
      
      // Complete on day 1
      habit.toggleComplete();
      expect(habit.currentStreak, 1);
      
      // Uncomplete on the same day
      habit.toggleComplete();
      expect(habit.currentStreak, 0); // Should reset to 0
      expect(habit.bestStreak, 1); // Best streak should remain 1
      expect(habit.isCompleted, false);
    });

    test('should handle complex streak scenarios with gaps and resumptions', () {
      final habit = Habit(name: 'Test Habit');
      
      // Day 1
      habit.toggleComplete();
      expect(habit.currentStreak, 1);
      
      // Day 2
      final day2 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day2;
      habit.isCompleted = false;
      habit.toggleComplete();
      expect(habit.currentStreak, 2);
      
      // Day 3
      final day3 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day3;
      habit.isCompleted = false;
      habit.toggleComplete();
      expect(habit.currentStreak, 3);
      expect(habit.bestStreak, 3);
      
      // Skip days 4 and 5, complete on day 6
      final day6 = DateTime.now().subtract(Duration(days: 3));
      habit.lastCompletedDate = day6;
      habit.isCompleted = false;
      habit.toggleComplete();
      expect(habit.currentStreak, 1); // Should reset to 1
      expect(habit.bestStreak, 3); // Best streak should remain 3
      
      // Continue streak on day 7
      final day7 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day7;
      habit.isCompleted = false;
      habit.toggleComplete();
      expect(habit.currentStreak, 2);
      expect(habit.bestStreak, 3); // Should not update since 2 < 3
    });

    test('should handle checkStreakReset method correctly', () {
      final habit = Habit(name: 'Test Habit');
      
      // Complete on day 1
      habit.toggleComplete();
      expect(habit.currentStreak, 1);
      
      // Simulate checking streak reset after 2 days (should reset)
      final day3 = DateTime.now().subtract(Duration(days: 2));
      habit.lastCompletedDate = day3;
      habit.isCompleted = false;
      
      habit.checkStreakReset();
      expect(habit.currentStreak, 0); // Should reset to 0
    });

    test('should not reset streak when checking after only 1 day gap', () {
      final habit = Habit(name: 'Test Habit');
      
      // Complete on day 1
      habit.toggleComplete();
      expect(habit.currentStreak, 1);
      
      // Simulate checking streak reset after 1 day (should not reset)
      final day2 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day2;
      habit.isCompleted = false;
      
      habit.checkStreakReset();
      expect(habit.currentStreak, 1); // Should remain 1
    });
  });

  group('Streak Freeze Tests', () {
    test('should earn streak freeze after 3 consecutive days', () {
      final habit = Habit(name: 'Test Habit');
      
      // Day 1
      habit.toggleComplete();
      expect(habit.currentStreak, 1);
      expect(habit.streakFreezes, 0);
      
      // Day 2
      final day2 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day2;
      habit.isCompleted = false;
      habit.toggleComplete();
      expect(habit.currentStreak, 2);
      expect(habit.streakFreezes, 0);
      
      // Day 3 - should earn streak freeze
      final day3 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day3;
      habit.isCompleted = false;
      habit.toggleComplete();
      expect(habit.currentStreak, 3);
      expect(habit.streakFreezes, 1); // Should earn 1 streak freeze
    });

    test('should earn streak freeze every 3 days with maximum of 3', () {
      final habit = Habit(name: 'Test Habit');
      
      // Complete 3 days to earn first streak freeze
      habit.toggleComplete(); // Day 1
      final day2 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day2;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 2
      final day3 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day3;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 3
      
      expect(habit.streakFreezes, 1); // First freeze at day 3
      
      // Continue to day 6 - should earn second freeze
      final day4 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day4;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 4
      final day5 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day5;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 5
      final day6 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day6;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 6
      
      expect(habit.currentStreak, 6);
      expect(habit.streakFreezes, 2); // Second freeze at day 6
      
      // Continue to day 9 - should earn third freeze
      final day7 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day7;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 7
      final day8 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day8;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 8
      final day9 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day9;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 9
      
      expect(habit.currentStreak, 9);
      expect(habit.streakFreezes, 3); // Third freeze at day 9
      
      // Continue to day 12 - should NOT earn fourth freeze (max is 3)
      final day10 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day10;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 10
      final day11 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day11;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 11
      final day12 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day12;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 12
      
      expect(habit.currentStreak, 12);
      expect(habit.streakFreezes, 3); // Should still be 3, not 4
    });

    test('should earn new streak freeze after breaking and rebuilding 3-day streak', () {
      final habit = Habit(name: 'Test Habit');
      
      // Complete 3 days to earn first streak freeze
      habit.toggleComplete(); // Day 1
      final day2 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day2;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 2
      final day3 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day3;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 3
      
      expect(habit.streakFreezes, 1);
      
      // Break streak by skipping 2 days
      final day6 = DateTime.now().subtract(Duration(days: 3));
      habit.lastCompletedDate = day6;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 6
      
      expect(habit.currentStreak, 1);
      expect(habit.streakFreezes, 1); // Should still have 1 freeze
      
      // Rebuild 3-day streak
      final day7 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day7;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 7
      final day8 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day8;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 8
      
      expect(habit.currentStreak, 3);
      expect(habit.streakFreezes, 2); // Should earn another freeze at day 3 of new streak
    });

    test('should use streak freeze to maintain streak when missing one day', () {
      final habit = Habit(name: 'Test Habit');
      
      // Earn a streak freeze first
      habit.toggleComplete(); // Day 1
      final day2 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day2;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 2
      final day3 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day3;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 3
      
      expect(habit.streakFreezes, 1);
      expect(habit.currentStreak, 3);
      
      // Simulate missing day 4 and checking on day 5
      final day5 = DateTime.now().subtract(Duration(days: 2));
      habit.lastCompletedDate = day5;
      habit.isCompleted = false;
      
      habit.checkStreakReset();
      
      expect(habit.currentStreak, 3); // Should maintain streak
      expect(habit.streakFreezes, 0); // Should use the freeze
      expect(habit.wasStreakFreezeRecentlyUsed, true);
    });

    test('should not use streak freeze for gaps larger than 1 day', () {
      final habit = Habit(name: 'Test Habit');
      
      // Earn a streak freeze first
      habit.toggleComplete(); // Day 1
      final day2 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day2;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 2
      final day3 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day3;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 3
      
      expect(habit.streakFreezes, 1);
      
      // Simulate missing days 4 and 5, checking on day 6
      final day6 = DateTime.now().subtract(Duration(days: 3));
      habit.lastCompletedDate = day6;
      habit.isCompleted = false;
      
      habit.checkStreakReset();
      
      expect(habit.currentStreak, 0); // Should reset streak
      expect(habit.streakFreezes, 1); // Should not use freeze for 2+ day gap
    });

    test('should not use streak freeze when none available', () {
      final habit = Habit(name: 'Test Habit');
      
      // Complete 2 days (no streak freeze earned yet)
      habit.toggleComplete(); // Day 1
      final day2 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day2;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 2
      
      expect(habit.streakFreezes, 0);
      expect(habit.currentStreak, 2);
      
      // Simulate missing day 3 and checking on day 4
      final day4 = DateTime.now().subtract(Duration(days: 2));
      habit.lastCompletedDate = day4;
      habit.isCompleted = false;
      
      habit.checkStreakReset();
      
      expect(habit.currentStreak, 0); // Should reset streak
      expect(habit.streakFreezes, 0); // Should remain 0
    });

    test('should manually use streak freeze', () {
      final habit = Habit(name: 'Test Habit');
      
      // Earn a streak freeze
      habit.toggleComplete(); // Day 1
      final day2 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day2;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 2
      final day3 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day3;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 3
      
      expect(habit.streakFreezes, 1);
      
      // Manually use streak freeze
      final result = habit.useStreakFreeze();
      expect(result, true);
      expect(habit.streakFreezes, 0);
      expect(habit.wasStreakFreezeRecentlyUsed, true);
    });

    test('should not use streak freeze when none available', () {
      final habit = Habit(name: 'Test Habit');
      
      expect(habit.streakFreezes, 0);
      
      // Try to use streak freeze when none available
      final result = habit.useStreakFreeze();
      expect(result, false);
      expect(habit.streakFreezes, 0);
    });

    test('should reset streak freezes when resetting streak', () {
      final habit = Habit(name: 'Test Habit');
      
      // Earn a streak freeze
      habit.toggleComplete(); // Day 1
      final day2 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day2;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 2
      final day3 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day3;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 3
      
      expect(habit.streakFreezes, 1);
      
      // Reset streak
      habit.resetStreak();
      
      expect(habit.currentStreak, 0);
      expect(habit.bestStreak, 0);
      expect(habit.streakFreezes, 0);
      expect(habit.isCompleted, false);
      expect(habit.lastCompletedDate, null);
      expect(habit.lastStreakFreezeUsed, null);
    });

    test('should get correct streak freeze status string', () {
      final habit = Habit(name: 'Test Habit');
      
      // No streak freezes
      expect(habit.getStreakFreezeStatus(), '');
      
      // Earn a streak freeze
      habit.toggleComplete(); // Day 1
      final day2 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day2;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 2
      final day3 = DateTime.now().subtract(Duration(days: 1));
      habit.lastCompletedDate = day3;
      habit.isCompleted = false;
      habit.toggleComplete(); // Day 3
      
      expect(habit.getStreakFreezeStatus(), '❄️ Streak Freezes: 1');
    });
  });
} 