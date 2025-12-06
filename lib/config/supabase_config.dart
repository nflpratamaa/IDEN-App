/// Konfigurasi Supabase
/// Ganti dengan URL dan Anon Key dari project Supabase kamu
/// 
/// Cara mendapatkan credentials:
/// 1. Buat project di https://supabase.com
/// 2. Buka Project Settings > API
/// 3. Copy URL dan anon/public key

class SupabaseConfig {
  static const String supabaseUrl = 'https://ewfjweofdmnyfeyvamts.supabase.co';
  
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV3Zmp3ZW9mZG1ueWZleXZhbXRzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ3NjQ3ODQsImV4cCI6MjA4MDM0MDc4NH0.SQiS0NOOASH6YhcgmAap_QtErVsphZjnptSPp1hMgPA';
  
  // Nama tabel di database
  static const String usersTable = 'users';
  static const String drugsTable = 'drugs';
  static const String articlesTable = 'articles';
  static const String quizzesTable = 'quizzes';
  static const String quizResultsTable = 'quiz_results';
  static const String emergencyContactsTable = 'emergency_contacts';
}
