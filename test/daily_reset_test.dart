import 'package:flutter_test/flutter_test.dart';
import 'package:habit/models/habit.dart';

void main() {
  group('Daily Reset Tests', () {
    test('Should auto-uncheck habit when moving to new day', () {
      // Create a habit completed "yesterday"
      final yesterday = DateTime.now().subtract(Duration(days: 1));
      final habit = Habit(
        name: 'Test Habit',
        isCompleted: true,
        currentStreak: 1,
        lastCompletedDate: yesterday,
      );

      // Trigger daily reset check (simulating app opening next day)
      habit.checkDailyReset();

      // Habit should be unchecked for new day
      expect(habit.isCompleted, false);
      // Streak should be preserved (not reset to 0)
      expect(habit.currentStreak, 1);
    });

    test('Should preserve streak when completing habit next day', () {
      // Create a habit completed yesterday
      final yesterday = DateTime.now().subtract(Duration(days: 1));
      final habit = Habit(
        name: 'Test Habit',
        isCompleted: true,
        currentStreak: 1,
        lastCompletedDate: yesterday,
      );

      // Trigger daily reset
      habit.checkDailyReset();
      expect(habit.isCompleted, false);

      // Complete habit today
      habit.toggleComplete();

      // Streak should increase
      expect(habit.isCompleted, true);
      expect(habit.currentStreak, 2);
    });

    test('Should break streak when missing multiple days', () {
      // Create a habit completed 3 days ago
      final threeDaysAgo = DateTime.now().subtract(Duration(days: 3));
      final habit = Habit(
        name: 'Test Habit',
        isCompleted: true,
        currentStreak: 5,
        lastCompletedDate: threeDaysAgo,
      );

      // Trigger daily reset
      habit.checkDailyReset();

      // Habit should be unchecked and streak broken
      expect(habit.isCompleted, false);
      expect(habit.currentStreak, 0);
    });

    test('Should auto-use streak freeze when missing exactly 1 day', () {
      // Create a habit with streak freeze available, completed 2 days ago
      final twoDaysAgo = DateTime.now().subtract(Duration(days: 2));
      final habit = Habit(
        name: 'Test Habit',
        isCompleted: true,
        currentStreak: 5,
        streakFreezes: 2,
        lastCompletedDate: twoDaysAgo,
      );

      // Trigger daily reset
      habit.checkDailyReset();

      // Should auto-use freeze and preserve streak
      expect(habit.isCompleted, false);
      expect(habit.currentStreak, 5); // Streak preserved
      expect(habit.streakFreezes, 1); // One freeze used
      expect(habit.lastStreakFreezeUsed, isNotNull);
    });

    test('Should not break streak if habit was completed today', () {
      // Create a habit completed today
      final today = DateTime.now();
      final habit = Habit(
        name: 'Test Habit',
        isCompleted: true,
        currentStreak: 3,
        lastCompletedDate: today,
      );

      // Trigger daily reset
      habit.checkDailyReset();

      // Nothing should change - habit still completed, streak intact
      expect(habit.isCompleted, true);
      expect(habit.currentStreak, 3);
    });

    test('Should not reset if habit is already unchecked', () {
      // Create an unchecked habit
      final habit = Habit(
        name: 'Test Habit',
        isCompleted: false,
        currentStreak: 2,
      );

      // Trigger daily reset
      habit.checkDailyReset();

      // Nothing should change
      expect(habit.isCompleted, false);
      expect(habit.currentStreak, 2);
    });

    test('Midnight scenario: 10 PM to 12:03 AM behavior', () {
      // Simulate your exact scenario using relative dates:
      // Yesterday at 10 PM - habit completed
      final yesterday_10pm = DateTime.now().subtract(Duration(days: 1));
      final habit = Habit(
        name: 'Test Habit',
        isCompleted: true,
        currentStreak: 1, // Had a 1-day streak from yesterday
        lastCompletedDate: yesterday_10pm,
      );

      // Now simulate opening app today (next day)
      // (Daily reset should trigger)
      habit.checkDailyReset();

      // Expected behavior:
      expect(habit.isCompleted, false, 
        reason: 'Habit should auto-uncheck for new day');
      expect(habit.currentStreak, 1, 
        reason: 'Streak should be preserved from yesterday');

      // Now complete habit today
      habit.toggleComplete();

      expect(habit.isCompleted, true);
      expect(habit.currentStreak, 2, 
        reason: 'Completing today should increase streak to 2');
    });

    test('Should handle streak freeze correctly when no freezes available', () {
      // Create a habit with no freezes, missed 1 day
      final twoDaysAgo = DateTime.now().subtract(Duration(days: 2));
      final habit = Habit(
        name: 'Test Habit',
        isCompleted: true,
        currentStreak: 3,
        streakFreezes: 0, // No freezes available
        lastCompletedDate: twoDaysAgo,
      );

      // Trigger daily reset
      habit.checkDailyReset();

      // Should break streak since no freezes available
      expect(habit.isCompleted, false);
      expect(habit.currentStreak, 0); // Streak broken
      expect(habit.streakFreezes, 0); // No freezes used
    });

    test('Should not auto-use freeze for gaps longer than 1 day', () {
      // Create a habit with freezes, but missed 2+ days
      final fourDaysAgo = DateTime.now().subtract(Duration(days: 4));
      final habit = Habit(
        name: 'Test Habit',
        isCompleted: true,
        currentStreak: 5,
        streakFreezes: 3,
        lastCompletedDate: fourDaysAgo,
      );

      // Trigger daily reset
      habit.checkDailyReset();

      // Should break streak even with freezes (gap too large)
      expect(habit.isCompleted, false);
      expect(habit.currentStreak, 0); // Streak broken
      expect(habit.streakFreezes, 3); // No freezes used
    });

    test('Should handle consecutive day completion correctly', () {
      // Test multiple days in sequence
      final habit = Habit(name: 'Test Habit');

      // Day 1: Complete habit
      habit.toggleComplete();
      expect(habit.currentStreak, 1);
      expect(habit.isCompleted, true);

      // Simulate moving to Day 2
      final day1Completion = habit.lastCompletedDate!;
      habit.lastCompletedDate = day1Completion.subtract(Duration(days: 1));
      habit.checkDailyReset();
      
      // Should be unchecked for new day
      expect(habit.isCompleted, false);
      
      // Complete Day 2
      habit.toggleComplete();
      expect(habit.currentStreak, 2);

      // Simulate moving to Day 3
      final day2Completion = habit.lastCompletedDate!;
      habit.lastCompletedDate = day2Completion.subtract(Duration(days: 1));
      habit.checkDailyReset();
      expect(habit.isCompleted, false);
      
      // Complete Day 3 (should earn freeze at 3 days)
      final streakBefore = habit.currentStreak;
      habit.toggleComplete();
      expect(habit.currentStreak, 3);
      expect(habit.streakFreezes, 1, 
        reason: 'Should earn freeze at 3-day streak');
    });
  });

  group('Edge Cases', () {
    test('Should handle habit created today', () {
      // Create a brand new habit (never completed)
      final habit = Habit(name: 'New Habit');

      // Trigger daily reset
      habit.checkDailyReset();

      // Nothing should change for new habit
      expect(habit.isCompleted, false);
      expect(habit.currentStreak, 0);
    });

    test('Should handle timezone edge cases', () {
      // Test with specific times around midnight
      final late_night = DateTime(2024, 8, 1, 23, 59); // 11:59 PM
      final habit = Habit(
        name: 'Test Habit',
        isCompleted: true,
        currentStreak: 1,
        lastCompletedDate: late_night,
      );

      // Should still be considered "today" until actual day change
      habit.checkDailyReset();
      
      // If same calendar day, should remain completed
      final now = DateTime.now();
      final habitDay = DateTime(late_night.year, late_night.month, late_night.day);
      final today = DateTime(now.year, now.month, now.day);
      
      if (habitDay.isAtSameMomentAs(today)) {
        expect(habit.isCompleted, true);
      } else {
        expect(habit.isCompleted, false);
      }
    });
  });
}