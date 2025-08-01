import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/habit.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Get current user
  static User? get currentUser => _client.auth.currentUser;
  
  // Check if user is logged in
  static bool get isLoggedIn => currentUser != null;
  
  // Auth methods
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName ?? ''},
        emailRedirectTo: null, // Disable redirect for mobile apps
      );
      
      // For mobile apps, we don't need email verification
      // The user can log in immediately after signup
      
      // Try to create profile manually if auto-creation failed
      if (response.user != null) {
        try {
          await _client.from('profiles').insert({
            'id': response.user!.id,
            'email': email,
            'full_name': fullName ?? '',
          });
        } catch (e) {
          // Profile might already exist from trigger, that's okay
        }
      }
      
      return response;
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Signup failed: ${e.toString()}');
    }
  }
  
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException('Login failed: ${e.toString()}');
    }
  }
  
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }
  
  // Listen to auth changes
  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  
  // Habit methods
  static Future<List<Habit>> getHabits() async {
    if (!isLoggedIn) return [];
    
    try {
      final response = await _client
          .from('habits')
          .select()
          .eq('user_id', currentUser!.id)
          .order('created_date', ascending: true);
      
      return response.map<Habit>((json) => Habit.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load habits: ${_getErrorMessage(e)}');
    }
  }
  
  static Future<Habit> createHabit(Habit habit) async {
    if (!isLoggedIn) throw Exception('Please log in to create habits');
    
    try {
      final habitData = habit.toJson();
      habitData['user_id'] = currentUser!.id;
      
      // Remove the local ID and let Supabase generate a UUID
      habitData.remove('id');
      
      final response = await _client
          .from('habits')
          .insert(habitData)
          .select()
          .single();
      
      return Habit.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create habit: ${_getErrorMessage(e)}');
    }
  }
  
  static Future<Habit> updateHabit(Habit habit) async {
    if (!isLoggedIn) throw Exception('Please log in to update habits');
    
    try {
      final response = await _client
          .from('habits')
          .update(habit.toJson())
          .eq('id', habit.id)
          .eq('user_id', currentUser!.id)
          .select()
          .single();
      
      return Habit.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update habit: ${_getErrorMessage(e)}');
    }
  }
  
  static Future<void> deleteHabit(String habitId) async {
    if (!isLoggedIn) throw Exception('Please log in to delete habits');
    
    try {
      await _client
          .from('habits')
          .delete()
          .eq('id', habitId)
          .eq('user_id', currentUser!.id);
    } catch (e) {
      throw Exception('Failed to delete habit: ${_getErrorMessage(e)}');
    }
  }
  
  // Profile methods
  static Future<Map<String, dynamic>?> getProfile() async {
    if (!isLoggedIn) return null;
    
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', currentUser!.id)
        .maybeSingle();
    
    return response;
  }
  
  static Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    if (!isLoggedIn) throw Exception('User not logged in');
    
    final updates = <String, dynamic>{};
    if (fullName != null) updates['full_name'] = fullName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    updates['updated_at'] = DateTime.now().toIso8601String();
    
    await _client
        .from('profiles')
        .update(updates)
        .eq('id', currentUser!.id);
  }

  // Helper method to extract meaningful error messages
  static String _getErrorMessage(dynamic error) {
    if (error is PostgrestException) {
      // Database-specific errors
      switch (error.code) {
        case '23505':
          return 'This item already exists';
        case '23503':
          return 'Cannot delete - item is being used';
        case '42501':
          return 'You don\'t have permission to do this';
        default:
          return error.message;
      }
    } else if (error is AuthException) {
      return error.message;
    } else {
      return error.toString().replaceAll('Exception: ', '');
    }
  }
}