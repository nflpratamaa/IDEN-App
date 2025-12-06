/// Analytics & Reports Screen - Laporan dan analitik data
/// Menampilkan: statistik pengguna, aktivitas quiz, artikel populer, export data
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final _supabase = Supabase.instance.client;
  
  // Statistics
  int _totalUsers = 0;
  int _activeUsers = 0;
  int _totalQuizAttempts = 0;
  double _avgQuizScore = 0.0;
  int _totalArticlesRead = 0;
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      setState(() => _isLoading = true);
      print('📊 Memuat data analitik...');

      // Load user statistics
      final usersData = await _supabase.from('users').select();
      final totalUsers = usersData.length;
      
      // Count active users (those with quiz attempts)
      final quizResults = await _supabase.from('quiz_results').select();
      final uniqueUsers = (quizResults as List)
          .map((result) => result['user_id'])
          .toSet()
          .length;

      // Calculate average quiz score
      double avgScore = 0.0;
      if (quizResults.isNotEmpty) {
        final totalScore = (quizResults as List)
            .fold<int>(0, (sum, result) => sum + (result['score'] as int? ?? 0));
        avgScore = totalScore / quizResults.length;
      }

      // Count total articles read
      int totalArticlesRead = 0;
      for (var user in usersData) {
        totalArticlesRead += (user['articlesRead'] as int? ?? 0);
      }

      setState(() {
        _totalUsers = totalUsers;
        _activeUsers = uniqueUsers;
        _totalQuizAttempts = quizResults.length;
        _avgQuizScore = avgScore;
        _totalArticlesRead = totalArticlesRead;
        _isLoading = false;
      });

      print('✅ Data analitik berhasil dimuat');
    } catch (e) {
      print('❌ Gagal memuat analitik: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat analitik: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Laporan & Analitik'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistik Utama
                  Text(
                    'Statistik Utama',
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Row 1: Users & Active Users
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Pengguna',
                          _totalUsers.toString(),
                          Icons.people,
                          AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Pengguna Aktif',
                          _activeUsers.toString(),
                          Icons.check_circle,
                          AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Row 2: Quiz Attempts & Average Score
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Quiz Dikerjakan',
                          _totalQuizAttempts.toString(),
                          Icons.quiz,
                          AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Nilai Rata-rata',
                          _avgQuizScore.toStringAsFixed(1),
                          Icons.trending_up,
                          AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Row 3: Articles Read
                  _buildStatCard(
                    'Total Artikel Dibaca',
                    _totalArticlesRead.toString(),
                    Icons.article,
                    AppColors.accent,
                  ),

                  const SizedBox(height: 32),

                  // Ringkasan Aktivitas
                  Text(
                    'Ringkasan Aktivitas',
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildActivityRow(
                          'Engagement Rate',
                          '${(_activeUsers / (_totalUsers > 0 ? _totalUsers : 1) * 100).toStringAsFixed(1)}%',
                          'Persentase pengguna yang telah menyelesaikan quiz',
                        ),
                        const Divider(height: 24),
                        _buildActivityRow(
                          'Quiz Per Pengguna',
                          (_totalQuizAttempts / (_activeUsers > 0 ? _activeUsers : 1)).toStringAsFixed(1),
                          'Rata-rata quiz yang dikerjakan per pengguna aktif',
                        ),
                        const Divider(height: 24),
                        _buildActivityRow(
                          'Konten Konsumsi',
                          '${_totalArticlesRead} artikel',
                          'Total artikel yang telah dibaca semua pengguna',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Export Options
                  Text(
                    'Export Data',
                    style: AppTextStyles.h4.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildExportButton(
                    'Export Laporan PDF',
                    'Unduh laporan lengkap dalam format PDF',
                    Icons.picture_as_pdf,
                    Colors.red,
                    () => _showExportDialog('PDF'),
                  ),
                  const SizedBox(height: 12),

                  _buildExportButton(
                    'Export Data CSV',
                    'Unduh data pengguna dan aktivitas dalam format CSV',
                    Icons.table_chart,
                    Colors.green,
                    () => _showExportDialog('CSV'),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(
    String title,
    String value,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.h5.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildExportButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: color),
            ],
          ),
        ),
      ),
    );
  }

  void _showExportDialog(String format) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export $format'),
        content: Text(
          'Fitur export $format akan segera tersedia.\n\nSaat ini, Anda dapat melihat statistik lengkap di halaman ini dan menggunakan tools database Supabase untuk export data lebih lanjut.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
