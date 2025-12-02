/// History Screen - Riwayat aktivitas user
/// 2 tabs: Quiz (hasil quiz sebelumnya) dan Artikel (artikel yang dibaca)
/// Menampilkan tanggal, skor, status untuk filter data lama
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _quizHistory = [
    {
      'date': '28 Nov 2025',
      'time': '14:30',
      'riskLevel': 'SEDANG',
      'score': 60,
      'color': AppColors.riskMedium,
    },
    {
      'date': '15 Nov 2025',
      'time': '09:15',
      'riskLevel': 'RENDAH',
      'score': 25,
      'color': AppColors.riskLow,
    },
    {
      'date': '02 Nov 2025',
      'time': '16:45',
      'riskLevel': 'SEDANG',
      'score': 55,
      'color': AppColors.riskMedium,
    },
  ];

  final List<Map<String, dynamic>> _readHistory = [
    {
      'title': 'Metamfetamin',
      'category': 'Stimulan',
      'date': '01 Des 2025',
      'riskLevel': 'Tinggi',
    },
    {
      'title': 'Kokain',
      'category': 'Stimulan',
      'date': '30 Nov 2025',
      'riskLevel': 'Tinggi',
    },
    {
      'title': 'MDMA (Ekstasi)',
      'category': 'Stimulan',
      'date': '28 Nov 2025',
      'riskLevel': 'Sedang',
    },
  ];

  final List<Map<String, dynamic>> _bookmarks = [
    {
      'title': 'Metamfetamin',
      'category': 'Stimulan',
      'riskLevel': 'Tinggi',
      'riskColor': AppColors.riskHigh,
    },
    {
      'title': 'MDMA (Ekstasi)',
      'category': 'Stimulan',
      'riskLevel': 'Sedang',
      'riskColor': AppColors.riskMedium,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Riwayat'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(text: 'Quiz'),
            Tab(text: 'Dibaca'),
            Tab(text: 'Tersimpan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQuizHistoryTab(),
          _buildReadHistoryTab(),
          _buildBookmarksTab(),
        ],
      ),
    );
  }

  Widget _buildQuizHistoryTab() {
    if (_quizHistory.isEmpty) {
      return _buildEmptyState(
        Icons.quiz_outlined,
        'Belum Ada Riwayat Quiz',
        'Quiz yang Anda ikuti akan muncul di sini',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _quizHistory.length,
      itemBuilder: (context, index) {
        final item = _quizHistory[index];
        return _buildQuizHistoryCard(item);
      },
    );
  }

  Widget _buildReadHistoryTab() {
    if (_readHistory.isEmpty) {
      return _buildEmptyState(
        Icons.history,
        'Belum Ada Riwayat Bacaan',
        'Artikel yang Anda baca akan muncul di sini',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _readHistory.length,
      itemBuilder: (context, index) {
        final item = _readHistory[index];
        return _buildReadHistoryCard(item);
      },
    );
  }

  Widget _buildBookmarksTab() {
    if (_bookmarks.isEmpty) {
      return _buildEmptyState(
        Icons.bookmark_border,
        'Belum Ada Tersimpan',
        'Simpan artikel untuk dibaca nanti',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bookmarks.length,
      itemBuilder: (context, index) {
        final item = _bookmarks[index];
        return _buildBookmarkCard(item, index);
      },
    );
  }

  Widget _buildQuizHistoryCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.assessment,
              color: item['color'],
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Penilaian Risiko',
                      style: AppTextStyles.h4,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: item['color'],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item['riskLevel'],
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item['date']} • ${item['time']}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.score,
                      size: 14,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Skor: ${item['score']}%',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadHistoryCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.article,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: 4),
                Text(
                  item['category'],
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item['date'],
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppColors.textLight,
          ),
        ],
      ),
    );
  }

  Widget _buildBookmarkCard(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item['riskColor'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: item['riskColor'],
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: 4),
                Text(
                  item['category'],
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: item['riskColor'],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Risiko ${item['riskLevel']}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.bookmark,
              color: AppColors.primary,
            ),
            onPressed: () {
              setState(() {
                _bookmarks.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dihapus dari tersimpan')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
