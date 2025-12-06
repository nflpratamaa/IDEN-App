/// Authentication Service untuk Supabase
/// Menangani sign in, sign up, sign out, dan session management
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Get current user
  User? get currentUser => _supabase.auth.currentUser;
  
  // Get current session
  Session? get currentSession => _supabase.auth.currentSession;
  
  // Check if user is logged in
  bool get isLoggedIn => currentUser != null && currentSession != null;
  
  // Stream untuk mendengarkan perubahan auth state
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
  
  /// Recover session dari storage setelah app restart
  Future<bool> recoverSession() async {
    try {
      // Supabase Flutter SDK otomatis recover session dengan persistSession: true
      // Tapi kita bisa explicit call jika perlu
      final session = _supabase.auth.currentSession;
      final user = _supabase.auth.currentUser;
      
      print('📱 Session Recovery:');
      print('  User: ${user?.email}');
      print('  Session: ${session != null ? "Active" : "None"}');
      
      return session != null && user != null;
    } catch (e) {
      print('❌ Session recovery error: $e');
      return false;
    }
  }
  
  /// Sign Up dengan email dan password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      print('📝 Registering user: $email');
      
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'quizzes_taken': 0,
          'articles_read': 0,
          'saved_items': 0,
        },
      );
      
      print('✅ Sign up successful: ${response.user?.email}');
      
      // Simpan user data ke tabel users
      if (response.user != null) {
        await _supabase.from('users').insert({
          'id': response.user!.id,
          'name': name,
          'email': email,
          'quizzes_taken': 0,
          'articles_read': 0,
          'saved_items': 0,
          'created_at': DateTime.now().toIso8601String(),
        });
        print('✅ User profile created in database');
      }
      
      return response;
    } on AuthException catch (e) {
      print('❌ Auth Error during signup: ${e.message}');
      throw Exception('Registrasi gagal: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error during signup: $e');
      throw Exception('Registrasi gagal: $e');
    }
  }
  
  /// Sign In dengan email dan password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Attempting login: $email');
      
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      print('✅ Login successful: ${response.user?.email}');
      print('   Session expires at: ${response.session?.expiresAt}');
      
      return response;
    } on AuthException catch (e) {
      print('❌ Auth Error during login: ${e.message} (${e.statusCode})');
      throw Exception('Login gagal: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error during login: $e');
      throw Exception('Login gagal: $e');
    }
  }
  
  /// Sign Out
  Future<void> signOut() async {
    try {
      print('👋 Signing out user: ${currentUser?.email}');
      await _supabase.auth.signOut();
      print('✅ Sign out successful');
    } catch (e) {
      print('❌ Sign out error: $e');
      rethrow;
    }
  }
  
  /// Reset Password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Get User Profile dari database
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      return UserModel.fromMap(response);
    } catch (e) {
      return null;
    }
  }
  
  /// Update User Profile
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    int? quizzesTaken,
    int? articlesRead,
    int? savedItems,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (name != null) updateData['name'] = name;
      if (quizzesTaken != null) updateData['quizzes_taken'] = quizzesTaken;
      if (articlesRead != null) updateData['articles_read'] = articlesRead;
      if (savedItems != null) updateData['saved_items'] = savedItems;
      
      await _supabase.from('users').update(updateData).eq('id', userId);
    } catch (e) {
      rethrow;
    }
  }
}
