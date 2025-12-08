/// Quiz Result Detail Screen
/// Menampilkan detail lengkap dari hasil quiz yang sudah dikerjakan
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/quiz_model.dart';
import 'help_center_screen.dart';

class QuizResultDetailScreen extends StatelessWidget {
  final QuizResult result;

  const QuizResultDetailScreen({
    super.key,
    required this.result,
  });

  Map<String, dynamic> _getRiskData() {
    switch (result.riskLevel.toLowerCase()) {
      case 'low':
        return {
          'level': 'RENDAH',
          'color': AppColors.riskLow,
          'icon': Icons.check_circle,
          'message': 'Tingkat Risiko: RENDAH',
          'description': 'Anda memiliki risiko rendah terhadap penyalahgunaan narkoba',
        };
      case 'medium':
        return {
          'level': 'SEDANG',
          'color': AppColors.riskMedium,
          'icon': Icons.warning_amber,
          'message': 'Tingkat Risiko: SEDANG',
          'description': 'Anda memiliki risiko sedang terhadap penyalahgunaan narkoba',
        };
      case 'high':
        return {
          'level': 'TINGGI',
          'color': AppColors.riskHigh,
          'icon': Icons.error,
          'message': 'Tingkat Risiko: TINGGI',
          'description': 'Anda memiliki risiko tinggi terhadap penyalahgunaan narkoba',
        };
      case 'extreme':
        return {
          'level': 'EKSTREM',
          'color': AppColors.riskExtreme,
          'icon': Icons.dangerous,
          'message': 'Tingkat Risiko: EKSTREM',
          'description': 'Anda memiliki risiko sangat tinggi terhadap penyalahgunaan narkoba',
        };
      default:
        return {
          'level': 'SEDANG',
          'color': AppColors.riskMedium,
          'icon': Icons.warning_amber,
          'message': 'Tingkat Risiko: SEDANG',
          'description': 'Berdasarkan jawaban Anda',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskData = _getRiskData();
    final dateFormat = DateFormat('dd MMMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    final date = dateFormat.format(result.completedAt);
    final time = timeFormat.format(result.completedAt);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Detail Hasil Penilaian'),
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

            // Quiz Info Card
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
                    'Informasi Quiz',
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.calendar_today, 'Tanggal', date),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.access_time, 'Waktu', time),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.analytics, 'Indikator Risiko', '${result.totalScore}%'),
                  if (result.percentage != null) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.percent, 'Persentase', '${result.percentage}%'),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Score Visualization
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
                    'Tingkat Risiko Anda',
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: result.totalScore / 100,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        riskData['color'],
                      ),
                      minHeight: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Level: ${result.totalScore}/100',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recommendations
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
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.accent,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rekomendasi',
                        style: AppTextStyles.h4,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (result.recommendations != null && result.recommendations!.isNotEmpty)
                    ...result.recommendations!.map((rec) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: AppColors.success,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  rec,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                  else
                    Text(
                      result.riskLevel.toLowerCase() == 'low'
                          ? 'Pertahankan pola hidup sehat Anda dan terus tingkatkan pengetahuan tentang bahaya narkoba.'
                          : 'Kami menyarankan Anda untuk berkonsultasi dengan profesional kesehatan. Penggunaan zat ini dapat menimbulkan risiko kesehatan serius jika berkelanjutan.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HelpCenterScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.support_agent),
                label: const Text('Cari Bantuan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textLight,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
