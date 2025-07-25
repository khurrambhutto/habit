import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Get current user
  User? get currentUser => _client.auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => currentUser != null;

  // Get auth state stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Get user profile data
  Map<String, dynamic>? get userProfile {
    final user = currentUser;
    if (user == null) return null;

    return {'id': user.id, 'email': user.email, 'created_at': user.createdAt};
  }
}
