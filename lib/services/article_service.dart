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
}
