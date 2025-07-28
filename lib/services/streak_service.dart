import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/habit.dart';
// import '../models/user_profile.dart'; // Removed
// import 'user_profile_service.dart'; // Removed
import '../utils/date_utils.dart';

class StreakService {
  final SupabaseClient _client = Supabase.instance.client;
  // final UserProfileService _userProfileService = UserProfileService(); // Removed

  String? get _userId => _client.auth.currentUser?.id;

  /// Process habit check with advanced streak logic
  Future<StreakCheckResult> processHabitCheck(Habit habit) async {
    print('🎯 Processing habit check: ${habit.name}');

    // Check if habit can be checked today
    if (habit.checkedToday) {
      // Changed from !habit.canCheckToday to habit.checkedToday for the condition
      throw Exception('Habit already checked today');
    }

    final today = DateTime.now();
    // final userProfile = await _userProfileService.getUserProfile(); // Removed

    // if (userProfile == null) { // Removed
    //   throw Exception('User profile not found'); // Removed
    // } // Removed

    // Calculate new streak based on last checked date
    final newStreakData = _calculateNewStreak(
      habit,
      today /*, userProfile */,
    ); // Removed userProfile param

    return newStreakData;
  }

  /// Calculate new streak value and handle freeze logic
  StreakCheckResult _calculateNewStreak(
    Habit habit,
    DateTime today,
    // UserProfile userProfile, // Removed param
  ) {
    int newStreak = habit.streak;
    // bool usedFreeze = false; // Removed
    // bool earnedFreeze = false; // Removed
    // UserProfile updatedProfile = userProfile; // Removed

    // Determine effective last checked date for logic
    DateTime? effectiveLastCheckedDate = habit.lastCheckedDate;
    // Handle uncheck-recheck: if lastCheckedDate is today but checkedToday is false, treat as yesterday
    if (!habit.checkedToday &&
        habit.lastCheckedDate != null &&
        DateUtils.isSameDay(habit.lastCheckedDate!, today)) {
      effectiveLastCheckedDate = habit.lastCheckedDate!.subtract(
        const Duration(days: 1),
      );
    }

    // If this is the first check ever
    if (effectiveLastCheckedDate == null) {
      newStreak = 1;
      print('🌟 First time checking habit: ${habit.name}');
    } else {
      final daysSinceLastCheck = today
          .difference(effectiveLastCheckedDate)
          .inDays;

      if (daysSinceLastCheck == 1) {
        // Perfect! Checked yesterday, continue streak
        newStreak = habit.streak + 1;
        print('✅ Continuing streak: ${habit.name} (${newStreak} days)');
      } else if (daysSinceLastCheck > 1) {
        // Missed days! Reset to zero
        newStreak = 0;
        print('💔 Streak broken for: ${habit.name}, reset to zero');
      } else {
        // This shouldn't happen (daysSinceLastCheck == 0 means same day)
        throw Exception('Cannot check habit twice in the same day');
      }
    }

    // Removed entire milestone freeze earning block

    return StreakCheckResult(
      newStreak: newStreak,
      lastCheckedDate: today,
      // usedFreeze: usedFreeze, // Removed
      // earnedFreeze: earnedFreeze, // Removed
      // updatedProfile: updatedProfile, // Removed
    );
  }

  /// Check all habits for streak breaking (call this daily/on app start)
  Future<List<Habit>> checkForBrokenStreaks(List<Habit> habits) async {
    print('🔍 Checking for broken streaks across ${habits.length} habits');

    final today = DateTime.now();
    // final userProfile = await _userProfileService.getUserProfile(); // Removed

    // if (userProfile == null) { // Removed
    //   print('⚠️ No user profile found'); // Removed
    //   return habits; // Removed
    // } // Removed

    List<Habit> updatedHabits = [];
    // UserProfile currentProfile = userProfile; // Removed

    for (final habit in habits) {
      if (habit.lastCheckedDate == null) {
        // Never checked, no streak to break
        updatedHabits.add(habit);
        continue;
      }

      final daysSinceLastCheck = today
          .difference(habit.lastCheckedDate!)
          .inDays;

      if (daysSinceLastCheck > 1 && habit.streak > 0) {
        // Streak should be broken
        // Removed freeze auto-use block
        // Just break the streak
        final brokenHabit = habit.copyWith(
          streak: 0,
          // streakFreezeUsed: false, // Removed
        );
        updatedHabits.add(brokenHabit);
        print('💔 Streak broken: ${habit.name}');
      } else {
        // Streak is safe
        updatedHabits.add(habit);
      }
    }

    // Removed profile update block if freezes were used

    return updatedHabits;
  }

  /// Reset daily check status (for new day)
  List<Habit> resetDailyStatus(List<Habit> habits) {
    final today = DateTime.now();

    return habits.map((habit) {
      // Reset checked_today if it's a new day
      if (habit.lastCheckedDate == null) {
        return habit.copyWith(checkedToday: false);
      }

      final isSameDay = _isSameDay(today, habit.lastCheckedDate!);
      if (!isSameDay) {
        return habit.copyWith(
          checkedToday: false,
          // streakFreezeUsed: false, // Removed
        );
      }

      return habit;
    }).toList();
  }

  /// Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

/// Result of processing a habit check
class StreakCheckResult {
  final int newStreak;
  final DateTime lastCheckedDate;
  // final bool usedFreeze; // Removed
  // final bool earnedFreeze; // Removed
  // final UserProfile updatedProfile; // Removed

  StreakCheckResult({
    required this.newStreak,
    required this.lastCheckedDate,
    // required this.usedFreeze, // Removed
    // required this.earnedFreeze, // Removed
    // required this.updatedProfile, // Removed
  });
}
