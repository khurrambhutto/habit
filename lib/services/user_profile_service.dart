import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';

class UserProfileService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _tableName = 'user_profiles';

  String? get _userId => _client.auth.currentUser?.id;

  // Get user profile stream for real-time updates
  Stream<UserProfile?> getUserProfileStream() {
    if (_userId == null) {
      throw Exception('User not authenticated');
    }

    print('🔄 Starting user profile stream for user: $_userId');

    return _client
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .eq('id', _userId!)
        .map((maps) {
          if (maps.isEmpty) return null;
          final profile = UserProfile.fromJson(maps.first);
          print('📡 Profile stream received: ${profile.streakFreezes} freezes');
          return profile;
        })
        .handleError((error) {
          print('Profile stream error: $error');
          throw Exception('Failed to stream user profile: $error');
        });
  }

  // Get user profile (single fetch)
  Future<UserProfile?> getUserProfile() async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      print('📋 Fetching user profile for: $_userId');
      final response = await _client
          .from(_tableName)
          .select()
          .eq('id', _userId!)
          .maybeSingle();

      if (response == null) {
        print('⚠️ No profile found, creating default profile');
        return await createUserProfile();
      }

      final profile = UserProfile.fromJson(response);
      print('✅ Profile fetched: ${profile.streakFreezes} freezes');
      return profile;
    } catch (e) {
      print('❌ Failed to fetch user profile: $e');
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  // Create user profile (for new users)
  Future<UserProfile> createUserProfile() async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      print('🆕 Creating new user profile for: $_userId');
      final response = await _client
          .from(_tableName)
          .insert({
            'id': _userId!,
            'streak_freezes': 1,
            'total_freezes_earned': 0,
          })
          .select()
          .single();

      final profile = UserProfile.fromJson(response);
      print('✅ Profile created with ${profile.streakFreezes} freezes');
      return profile;
    } catch (e) {
      print('❌ Failed to create user profile: $e');
      throw Exception('Failed to create user profile: $e');
    }
  }

  // Update user profile
  Future<UserProfile> updateUserProfile(UserProfile profile) async {
    if (_userId == null) throw Exception('User not authenticated');

    try {
      print('🔄 Updating user profile: ${profile.streakFreezes} freezes');
      final response = await _client
          .from(_tableName)
          .update({
            'streak_freezes': profile.streakFreezes,
            'total_freezes_earned': profile.totalFreezesEarned,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _userId!)
          .select()
          .single();

      final updatedProfile = UserProfile.fromJson(response);
      print('✅ Profile updated: ${updatedProfile.streakFreezes} freezes');
      return updatedProfile;
    } catch (e) {
      print('❌ Failed to update user profile: $e');
      throw Exception('Failed to update user profile: $e');
    }
  }

  // Use a streak freeze
  Future<UserProfile> useStreakFreeze() async {
    final currentProfile = await getUserProfile();
    if (currentProfile == null) {
      throw Exception('User profile not found');
    }

    if (!currentProfile.hasStreakFreezes) {
      throw Exception('No streak freezes available');
    }

    final updatedProfile = currentProfile.useFreeze();
    return await updateUserProfile(updatedProfile);
  }

  // Earn a streak freeze (when user gets 3-day streak)
  Future<UserProfile> earnStreakFreeze() async {
    final currentProfile = await getUserProfile();
    if (currentProfile == null) {
      throw Exception('User profile not found');
    }

    if (!currentProfile.canEarnMoreFreezes) {
      print('⚠️ User already has maximum freezes (3)');
      return currentProfile; // Don't throw error, just return current profile
    }

    final updatedProfile = currentProfile.earnFreeze();
    print(
      '🎉 User earned a streak freeze! Total: ${updatedProfile.streakFreezes}',
    );
    return await updateUserProfile(updatedProfile);
  }
}
