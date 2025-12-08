/// History Screen - Riwayat aktivitas user
/// 3 tabs: Quiz (hasil quiz sebelumnya), Dibaca (artikel yang dibaca), Tersimpan (bookmarks)
/// Menampilkan data real dari Supabase dengan loading state
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/quiz_model.dart';
import '../../models/article_model.dart';
import '../../services/quiz_service.dart';
import 'article_detail_screen.dart';
import 'quiz_result_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabase = Supabase.instance.client;
  final _quizService = QuizService();

  List<QuizResult> _quizHistory = [];
  List<ArticleModel> _readHistory = [];
  List<ArticleModel> _bookmarks = [];

  bool _isLoadingQuiz = false;
  bool _isLoadingRead = false;
  bool _isLoadingBookmarks = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadQuizHistory(); // Load first tab immediately
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      // Lazy load data when tab changes
      if (_tabController.index == 1 && _readHistory.isEmpty) {
        _loadReadHistory();
      } else if (_tabController.index == 2 && _bookmarks.isEmpty) {
        _loadBookmarks();
      }
    }
  }

  Future<void> _loadQuizHistory() async {
    if (_isLoadingQuiz) return;

    setState(() => _isLoadingQuiz = true);
    
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('❌ User not authenticated');
        return;
      }

      print('📥 Loading quiz history for user: $userId');
      final history = await _quizService.getUserQuizHistory(userId);
      
      setState(() {
        _quizHistory = history;
      });
      
      print('✅ Loaded ${history.length} quiz results');
    } catch (e) {
      print('❌ Error loading quiz history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat riwayat quiz: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingQuiz = false);
      }
    }
  }

  Future<void> _loadReadHistory() async {
    if (_isLoadingRead) return;

    setState(() => _isLoadingRead = true);
    
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('❌ User not authenticated');
        return;
      }

      print('📥 Loading read history for user: $userId');
      final response = await _supabase
          .from('read_history')
          .select('*, articles(*)')
          .eq('user_id', userId)
          .order('read_at', ascending: false);
      
      final articles = <ArticleModel>[];
      for (var item in response) {
        if (item['articles'] != null) {
          articles.add(ArticleModel.fromMap(item['articles']));
        }
      }
      
      setState(() {
        _readHistory = articles;
      });
      
      print('✅ Loaded ${articles.length} read articles');
    } catch (e) {
      print('❌ Error loading read history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat riwayat bacaan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingRead = false);
      }
    }
  }

  Future<void> _loadBookmarks() async {
    if (_isLoadingBookmarks) return;

    setState(() => _isLoadingBookmarks = true);
    
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('❌ User not authenticated');
        return;
      }

      print('📥 Loading bookmarks for user: $userId');
      final response = await _supabase
          .from('bookmarks')
          .select('*, articles(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      final articles = <ArticleModel>[];
      for (var item in response) {
        if (item['articles'] != null) {
          articles.add(ArticleModel.fromMap(item['articles']));
        }
      }
      
      setState(() {
        _bookmarks = articles;
      });
      
      print('✅ Loaded ${articles.length} bookmarks');
    } catch (e) {
      print('❌ Error loading bookmarks: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat bookmark: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingBookmarks = false);
      }
    }
  }

  Future<void> _removeBookmark(ArticleModel article) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('bookmarks')
          .delete()
          .eq('user_id', userId)
          .eq('article_id', article.id);

      setState(() {
        _bookmarks.removeWhere((a) => a.id == article.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dihapus dari tersimpan')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus bookmark: $e')),
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
        return _buildBookmarkCard(item);
      },
    );
  }

  Widget _buildQuizHistoryCard(QuizResult result) {
    // Use the risk level stored in database instead of recalculating
    String displayRiskLevel;
    Color riskColor;
    
    switch (result.riskLevel.toLowerCase()) {
      case 'low':
        displayRiskLevel = 'RENDAH';
        riskColor = AppColors.riskLow;
        break;
      case 'medium':
        displayRiskLevel = 'SEDANG';
        riskColor = AppColors.riskMedium;
        break;
      case 'high':
        displayRiskLevel = 'TINGGI';
        riskColor = AppColors.riskHigh;
        break;
      case 'extreme':
        displayRiskLevel = 'EKSTREM';
        riskColor = AppColors.riskExtreme;
        break;
      default:
        displayRiskLevel = 'SEDANG';
        riskColor = AppColors.riskMedium;
    }

    // Format date (removed locale to avoid initialization error on Flutter Web)
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    final date = dateFormat.format(result.completedAt);
    final time = timeFormat.format(result.completedAt);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizResultDetailScreen(result: result),
          ),
        );
      },
      child: Container(
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
              color: riskColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.assessment,
              color: riskColor,
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
                        color: riskColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        displayRiskLevel,
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
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$date \u2022 $time',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.score,
                      size: 14,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Level: ${result.totalScore}%',
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
    ),
    );
  }

  Widget _buildReadHistoryCard(ArticleModel article) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArticleDetailScreen(article: article),
          ),
        );
      },
      child: Container(
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
                    article.title,
                    style: AppTextStyles.h4,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      article.category,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.accent,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'by ${article.author}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textLight,
                    ),
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
      ),
    );
  }

  Widget _buildBookmarkCard(ArticleModel article) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArticleDetailScreen(article: article),
          ),
        );
      },
      child: Container(
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
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.bookmark,
                color: AppColors.accent,
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
                    article.title,
                    style: AppTextStyles.h4,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'by ${article.author}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      article.category,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.bookmark_remove,
                color: AppColors.error,
              ),
              onPressed: () => _removeBookmark(article),
            ),
          ],
        ),
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
