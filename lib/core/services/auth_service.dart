import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AuthService {
  final SupabaseClient _supabase = SupabaseConfig.client;

  // Get current user
  User? get currentUser => _supabase.auth.currentUser;

  // Get current session
  Session? get currentSession => _supabase.auth.currentSession;

  // Check if user is logged in
  bool get isLoggedIn => currentUser != null;

  // Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'username': username,
          'full_name': fullName,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with phone number (OTP)
  Future<void> signInWithPhone({
    required String phoneNumber,
  }) async {
    try {
      await _supabase.auth.signInWithOtp(
        phone: phoneNumber,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP
  Future<AuthResponse> verifyOTP({
    required String phone,
    required String token,
  }) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword({required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Update password
  Future<UserResponse> updatePassword({required String newPassword}) async {
    try {
      final response = await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user != null) {
        // Delete user profile and related data will cascade
        await _supabase.from('profiles').delete().eq('id', user.id);
        await _supabase.auth.signOut();
      }
    } catch (e) {
      rethrow;
    }
  }
}
