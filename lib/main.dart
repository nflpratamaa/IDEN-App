/// Main entry point aplikasi IDEN
/// Mengatur konfigurasi app: orientasi layar, tema, routing, auth session
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'constants/app_colors.dart';
import 'screens/onboarding/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup orientasi layar portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Supabase dengan session persistence
  // Note: persistSession: true adalah default di Supabase Flutter SDK v2.x+
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );
  
  runApp(const IDENApp());
}

class IDENApp extends StatelessWidget {
  const IDENApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IDEN - Indeks Risiko & Edukasi Narkotika',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
