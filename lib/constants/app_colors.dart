/// App Colors - Palet warna aplikasi IDEN
/// Primary: Navy (#000080) - warna utama app
/// Risk levels: Rendah (hijau), Sedang (orange), Tinggi (merah), Ekstrem (merah tua)
/// Accent: #D4936D - warna secondary untuk highlight
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF000080);
  static const Color primaryDark = Color(0xFF000066);
  static const Color primaryLight = Color(0xFF0000B3);
  
  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFF9E9E9E);
  
  // Accent Colors
  static const Color accent = Color(0xFFD4936D);
  static const Color accentLight = Color(0xFFE5B299);
  
  // Risk Level Colors
  static const Color riskHigh = Color(0xFFD07059);
  static const Color riskMedium = Color(0xFFE5B299);
  static const Color riskLow = Color(0xFF9BC4A7);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFE57373);
  static const Color info = Color(0xFF64B5F6);
  
  // UI Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);
  static const Color shadow = Color(0x1A000000);
}
