/// Splash Screen - Layar pembuka aplikasi
/// Menampilkan logo dan nama app sambil melakukan session recovery
/// Navigasi ke Home jika user sudah login, ke Onboarding jika belum
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../main/home_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  /// Initialize session dan navigate ke page yang sesuai
  Future<void> _initializeAndNavigate() async {
    try {
      // Wait untuk session recovery dari SharedPreferences/localStorage
      // Supabase otomatis do this dengan persistSession: true
      await Future.delayed(const Duration(milliseconds: 500));

      // Check apakah ada active session
      final session = _supabase.auth.currentSession;
      final user = _supabase.auth.currentUser;

      print('🔍 Session Recovery Check:');
      print('  Current User: ${user?.email}');
      print('  Session exists: ${session != null}');
      print('  Session expires at: ${session?.expiresAt}');

      if (mounted) {
        // Navigate berdasarkan auth state
        if (user != null && session != null) {
          // User sudah login, go to home
          print('✅ User logged in, navigating to Home');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          // User belum login, go to onboarding
          print('❌ No session found, navigating to Onboarding');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const OnboardingScreen()),
          );
        }
      }
    } catch (e) {
      print('❌ Error during session recovery: $e');
      if (mounted) {
        // Default ke onboarding jika ada error
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // IDEN Text
            Text(
              'IDEN',
              style: AppTextStyles.h1.copyWith(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Loading indicator
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
