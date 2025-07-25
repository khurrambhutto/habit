import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/habit.dart';

class HabitService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _tableName = 'habits';

  // Get current user ID
  String? get _userId => _client.auth.currentUser?.id;

  // Get all habits for the authenticated user
  Future<List<Habit>> getAllHabits() async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', _userId!)
          .order('created_at', ascending: true);

      return (response as List).map((json) => Habit.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch habits: $e');
    }
  }

  // Add a new habit for the authenticated user
  Future<Habit> addHabit(String name) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      final response = await _client
          .from(_tableName)
          .insert({'name': name, 'user_id': _userId!})
          .select()
          .single();

      return Habit.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add habit: $e');
    }
  }

  // Update an existing habit (only if it belongs to the user)
  Future<Habit> updateHabit(Habit habit) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      final response = await _client
          .from(_tableName)
          .update({'streak': habit.streak, 'checked_today': habit.checkedToday})
          .eq('id', habit.id!)
          .eq('user_id', _userId!) // Ensure user owns this habit
          .select()
          .single();

      return Habit.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update habit: $e');
    }
  }

  // Delete a habit (only if it belongs to the user)
  Future<void> deleteHabit(int id) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      await _client
          .from(_tableName)
          .delete()
          .eq('id', id)
          .eq('user_id', _userId!); // Ensure user owns this habit
    } catch (e) {
      throw Exception('Failed to delete habit: $e');
    }
  }

  // Toggle habit check status and update streak
  Future<Habit> toggleHabit(Habit habit) async {
    final updatedHabit = habit.copyWith(
      checkedToday: !habit.checkedToday,
      streak: !habit.checkedToday
          ? habit.streak + 1
          : (habit.streak > 0 ? habit.streak - 1 : 0),
    );

    return await updateHabit(updatedHabit);
  }
}
