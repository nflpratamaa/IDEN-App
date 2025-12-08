/// Result Screen - Hasil quiz assessment
/// Menampilkan: skor, risk level dengan warna, badge, rekomendasi actions
/// Button: lihat detail dan kembali ke home
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/quiz_model.dart';
import '../../services/quiz_service.dart';
import 'home_screen.dart';
import 'help_center_screen.dart';

class ResultScreen extends StatefulWidget {
  final int totalScore;
  final int maxScore;

  const ResultScreen({
    super.key,
    required this.totalScore,
    required this.maxScore,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _quizService = QuizService();
  final _supabase = Supabase.instance.client;
  bool _isSaved = false;
  bool _isSaving = false;

  Map<String, dynamic> _getRiskLevel() {
    final percentage = (widget.totalScore / widget.maxScore) * 100;

    if (percentage <= 30) {
      return {
        'level': 'low',  // Changed from 'rendah' to match database constraint
        'color': AppColors.riskLow,
        'icon': Icons.check_circle,
        'message': 'Tingkat Risiko: RENDAH',
        'description': 'Berdasarkan jawaban Anda',
      };
    } else if (percentage <= 60) {
      return {
        'level': 'medium',  // Changed from 'sedang' to match database constraint
        'color': AppColors.riskMedium,
        'icon': Icons.warning_amber,
        'message': 'Tingkat Risiko: SEDANG',
        'description': 'Berdasarkan jawaban Anda',
      };
    } else {
      return {
        'level': 'high',  // Changed from 'tinggi' to match database constraint
        'color': AppColors.riskHigh,
        'icon': Icons.error,
        'message': 'Tingkat Risiko: TINGGI',
        'description': 'Berdasarkan jawaban Anda',
      };
    }
  }

  Map<String, int> _getScoreBreakdown() {
    final percentage = (widget.totalScore / widget.maxScore) * 100;
    return {
      'frequency': ((percentage * 0.6).round()),
      'health': ((percentage * 0.75).round()),
      'dependency': ((percentage * 0.4).round()),
    };
  }

  Future<void> _saveQuizResult() async {
    try {
      setState(() => _isSaving = true);

      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Calculate risk level
      final riskData = _getRiskLevel();
      final riskLevel = riskData['level'].toString();

      // Create quiz result
      final quizResult = QuizResult(
        id: const Uuid().v4(),
        userId: user.id,
        quizId: 'default-assessment',
        totalScore: widget.totalScore,
        maxScore: widget.maxScore,
        percentage: (widget.totalScore / widget.maxScore * 100).toInt(),
        riskLevel: riskLevel,
        completedAt: DateTime.now(),
      );

      // Save to database
      await _quizService.saveQuizResult(quizResult);

      setState(() {
        _isSaving = false;
        _isSaved = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Hasil quiz berhasil disimpan!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Gagal menyimpan hasil: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskData = _getRiskLevel();
    final breakdown = _getScoreBreakdown();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Hasil Penilaian'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Result Icon and Title
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: riskData['color'].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                riskData['icon'],
                color: riskData['color'],
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              riskData['message'],
              style: AppTextStyles.h2.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              riskData['description'],
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Score Breakdown
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Analisis Faktor Risiko',
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(height: 20),
                  _buildRiskIndicator(
                    'Indikator Frekuensi',
                    breakdown['frequency']!,
                  ),
                  const SizedBox(height: 16),
                  _buildRiskIndicator(
                    'Indikator Dampak',
                    breakdown['health']!,
                  ),
                  const SizedBox(height: 16),
                  _buildRiskIndicator(
                    'Indikator Ketergantungan',
                    breakdown['dependency']!,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Recommendation
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rekomendasi',
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Kami menyarankan Anda untuk berkonsultasi dengan profesional kesehatan. Penggunaan zat ini dapat menimbulkan risiko kesehatan serius jika berkelanjutan.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isSaved || _isSaving ? null : _saveQuizResult,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isSaved ? 'Sudah Tersimpan ✓' : 'Simpan Hasil'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HelpCenterScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Cari Bantuan',
                  style: AppTextStyles.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskIndicator(String label, int percentage) {
    Color barColor;
    if (percentage <= 30) {
      barColor = AppColors.riskLow;
    } else if (percentage <= 60) {
      barColor = AppColors.riskMedium;
    } else {
      barColor = AppColors.riskHigh;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$percentage%',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}
