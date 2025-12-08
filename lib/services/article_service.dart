/// Article Service untuk Supabase
/// CRUD operations untuk artikel edukasi
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/article_model.dart';

class ArticleService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  /// Get semua articles
  Future<List<ArticleModel>> getAllArticles() async {
    try {
      final response = await _supabase
          .from('articles')
          .select()
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((article) => ArticleModel.fromMap(article))
          .toList();
    } catch (e) {
      throw Exception('Failed to load articles: $e');
    }
  }
  
  /// Get article by ID
  Future<ArticleModel?> getArticleById(String id) async {
    try {
      final response = await _supabase
          .from('articles')
          .select()
          .eq('id', id)
          .single();
      
      return ArticleModel.fromMap(response);
    } catch (e) {
      return null;
    }
  }
  
  /// Search articles
  Future<List<ArticleModel>> searchArticles(String query) async {
    try {
      final response = await _supabase
          .from('articles')
          .select()
          .or('title.ilike.%$query%,content.ilike.%$query%')
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((article) => ArticleModel.fromMap(article))
          .toList();
    } catch (e) {
      throw Exception('Failed to search articles: $e');
    }
  }
  
  /// Get articles by category
  Future<List<ArticleModel>> getArticlesByCategory(String category) async {
    try {
      final response = await _supabase
          .from('articles')
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((article) => ArticleModel.fromMap(article))
          .toList();
    } catch (e) {
      throw Exception('Failed to filter articles: $e');
    }
  }
  
  /// Add new article (Admin only)
  Future<void> addArticle(ArticleModel article) async {
    try {
      await _supabase.from('articles').insert(article.toMap());
    } catch (e) {
      throw Exception('Failed to add article: $e');
    }
  }
  
  /// Update article (Admin only)
  Future<void> updateArticle(ArticleModel article) async {
    try {
      await _supabase
          .from('articles')
          .update(article.toMap())
          .eq('id', article.id);
    } catch (e) {
      throw Exception('Failed to update article: $e');
    }
  }
  
  /// Delete article (Admin only)
  Future<void> deleteArticle(String id) async {
    try {
      await _supabase.from('articles').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete article: $e');
    }
  }
  
  /// Increment read count
  Future<void> incrementReadCount(String articleId) async {
    try {
      // Get current read count
      final article = await getArticleById(articleId);
      if (article != null) {
        await _supabase
            .from('articles')
            .update({'read_count': (article.readCount ?? 0) + 1})
            .eq('id', articleId);
      }
    } catch (e) {
      // Silently fail untuk analytics
    }
  }
  
  /// Track article read - simpan ke read_history
  /// Akan mencatat artikel yang dibaca user, tapi hanya sekali per artikel
  Future<void> trackArticleRead(String articleId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('❌ User not authenticated, cannot track read');
        return;
      }

      // Cek apakah sudah pernah dibaca sebelumnya
      final existing = await _supabase
          .from('read_history')
          .select()
          .eq('user_id', userId)
          .eq('article_id', articleId)
          .maybeSingle();

      if (existing != null) {
        // Sudah pernah dibaca, update waktu baca terakhir
        await _supabase
            .from('read_history')
            .update({'read_at': DateTime.now().toIso8601String()})
            .eq('user_id', userId)
            .eq('article_id', articleId);
        print('✅ Updated read timestamp for article $articleId');
      } else {
        // Belum pernah dibaca, insert baru
        await _supabase.from('read_history').insert({
          'user_id': userId,
          'article_id': articleId,
          'read_at': DateTime.now().toIso8601String(),
        });
        print('✅ Tracked new article read: $articleId');
        
        // 🔥 INCREMENT articles_read counter di users table
        final currentUser = await _supabase
            .from('users')
            .select('articles_read')
            .eq('id', userId)
            .single();
        
        final currentCount = currentUser['articles_read'] as int? ?? 0;
        await _supabase
            .from('users')
            .update({'articles_read': currentCount + 1})
            .eq('id', userId);
        
        print('✅ Incremented articles_read counter to ${currentCount + 1}');
      }

      // Increment read count juga
      await incrementReadCount(articleId);
    } catch (e) {
      print('❌ Error tracking article read: $e');
      // Silently fail - jangan ganggu UX kalau tracking gagal
    }
  }
  
  /// Cek apakah user sudah pernah baca artikel ini
  Future<bool> hasUserReadArticle(String articleId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final result = await _supabase
          .from('read_history')
          .select('id')
          .eq('user_id', userId)
          .eq('article_id', articleId)
          .maybeSingle();

      return result != null;
    } catch (e) {
      print('❌ Error checking read status: $e');
      return false;
    }
  }
  
  /// Tambahkan artikel ke bookmark
  Future<void> addBookmark(String articleId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('❌ User not authenticated, cannot add bookmark');
        throw Exception('User not authenticated');
      }

      // Cek apakah sudah di-bookmark sebelumnya
      final existing = await _supabase
          .from('bookmarks')
          .select()
          .eq('user_id', userId)
          .eq('article_id', articleId)
          .maybeSingle();

      if (existing != null) {
        print('⚠️ Article already bookmarked');
        return; // Sudah ada, skip
      }

      // Insert bookmark baru
      await _supabase.from('bookmarks').insert({
        'user_id': userId,
        'article_id': articleId,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      print('✅ Bookmark added for article: $articleId');
    } catch (e) {
      print('❌ Error adding bookmark: $e');
      rethrow; // Throw error supaya UI bisa handle
    }
  }
  
  /// Hapus artikel dari bookmark
  Future<void> removeBookmark(String articleId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        print('❌ User not authenticated, cannot remove bookmark');
        throw Exception('User not authenticated');
      }

      await _supabase
          .from('bookmarks')
          .delete()
          .eq('user_id', userId)
          .eq('article_id', articleId);
      
      print('✅ Bookmark removed for article: $articleId');
    } catch (e) {
      print('❌ Error removing bookmark: $e');
      rethrow;
    }
  }
  
  /// Cek apakah artikel sudah di-bookmark
  Future<bool> isBookmarked(String articleId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final result = await _supabase
          .from('bookmarks')
          .select('id')
          .eq('user_id', userId)
          .eq('article_id', articleId)
          .maybeSingle();

      return result != null;
    } catch (e) {
      print('❌ Error checking bookmark status: $e');
      return false;
    }
  }
}
