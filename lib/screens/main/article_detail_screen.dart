/// Artikel Detail Screen - Tampilkan isi artikel lengkap
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/article_model.dart';
import '../../services/article_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  final ArticleModel article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final _articleService = ArticleService();
  bool _isTracked = false;
  bool _isBookmarked = false;
  bool _isLoadingBookmark = false;

  @override
  void initState() {
    super.initState();
    // Track artikel saat dibuka
    _trackArticleRead();
    // Cek status bookmark
    _checkBookmarkStatus();
  }

  Future<void> _trackArticleRead() async {
    if (_isTracked) return; // Prevent duplicate tracking
    
    try {
      await _articleService.trackArticleRead(widget.article.id);
      _isTracked = true;
      print('✅ Article ${widget.article.id} tracked successfully');
    } catch (e) {
      print('❌ Failed to track article: $e');
      // Silently fail - don't disrupt user experience
    }
  }
  
  Future<void> _checkBookmarkStatus() async {
    try {
      final isBookmarked = await _articleService.isBookmarked(widget.article.id);
      setState(() {
        _isBookmarked = isBookmarked;
      });
    } catch (e) {
      print('❌ Failed to check bookmark status: $e');
    }
  }
  
  Future<void> _toggleBookmark() async {
    setState(() => _isLoadingBookmark = true);
    
    try {
      if (_isBookmarked) {
        // Remove bookmark
        await _articleService.removeBookmark(widget.article.id);
        setState(() => _isBookmarked = false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dihapus dari tersimpan')),
          );
        }
      } else {
        // Add bookmark
        await _articleService.addBookmark(widget.article.id);
        setState(() => _isBookmarked = true);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Artikel disimpan ke bookmark')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingBookmark = false);
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
        title: const Text('Artikel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Artikel dibagikan')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                image: widget.article.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(widget.article.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.article.imageUrl.isEmpty
                  ? const Icon(
                      Icons.article,
                      size: 80,
                      color: AppColors.primary,
                    )
                  : null,
            ),
            const SizedBox(height: 16),

            // Kategori
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                widget.article.category,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Judul
            Text(
              widget.article.title,
              style: AppTextStyles.h3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Meta Info
            Text(
              'by ${widget.article.author}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Divider
            const Divider(),
            const SizedBox(height: 16),

            // Konten
            Text(
              widget.article.content,
              style: AppTextStyles.bodyMedium.copyWith(
                height: 1.6,
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingBookmark ? null : _toggleBookmark,
                    icon: Icon(
                      _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    ),
                    label: Text(_isBookmarked ? 'Tersimpan' : 'Simpan'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Artikel dibagikan')),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Bagikan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
