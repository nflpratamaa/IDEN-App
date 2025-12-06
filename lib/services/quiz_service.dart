/// Quiz Service untuk Supabase
/// CRUD operations untuk quiz questions dan results
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/quiz_model.dart';

class QuizService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  /// Get semua quiz questions
  Future<List<QuizQuestion>> getAllQuestions() async {
    try {
      final response = await _supabase
          .from('quizzes')
          .select()
          .order('order_index', ascending: true);
      
      return (response as List)
          .map((question) => QuizQuestion.fromMap(question))
          .toList();
    } catch (e) {
      throw Exception('Failed to load quiz questions: $e');
    }
  }
  
  /// Save quiz result
  Future<void> saveQuizResult(QuizResult result) async {
    try {
      await _supabase.from('quiz_results').insert(result.toMap());
      
      // Update user statistics
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        final userResponse = await _supabase
            .from('users')
            .select('quizzes_taken')
            .eq('id', userId)
            .single();
        
        final currentCount = userResponse['quizzes_taken'] as int? ?? 0;
        
        await _supabase
            .from('users')
            .update({'quizzes_taken': currentCount + 1})
            .eq('id', userId);
      }
    } catch (e) {
      throw Exception('Failed to save quiz result: $e');
    }
  }
  
  /// Get user quiz history
  Future<List<QuizResult>> getUserQuizHistory(String userId) async {
    try {
      final response = await _supabase
          .from('quiz_results')
          .select()
          .eq('user_id', userId)
          .order('completed_at', ascending: false);
      
      return (response as List)
          .map((result) => QuizResult.fromMap(result))
          .toList();
    } catch (e) {
      throw Exception('Failed to load quiz history: $e');
    }
  }
  
  /// Get latest quiz result for user
  Future<QuizResult?> getLatestQuizResult(String userId) async {
    try {
      final response = await _supabase
          .from('quiz_results')
          .select()
          .eq('user_id', userId)
          .order('completed_at', ascending: false)
          .limit(1)
          .single();
      
      return QuizResult.fromMap(response);
    } catch (e) {
      return null;
    }
  }
  
  /// Add quiz question (Admin only)
  Future<void> addQuestion(QuizQuestion question) async {
    try {
      await _supabase.from('quizzes').insert(question.toMap());
    } catch (e) {
      throw Exception('Failed to add question: $e');
    }
  }
  
  /// Update quiz question (Admin only)
  Future<void> updateQuestion(QuizQuestion question) async {
    try {
      await _supabase
          .from('quizzes')
          .update(question.toMap())
          .eq('id', question.id);
    } catch (e) {
      throw Exception('Failed to update question: $e');
    }
  }
  
  /// Delete quiz question (Admin only)
  Future<void> deleteQuestion(String id) async {
    try {
      await _supabase.from('quizzes').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete question: $e');
    }
  }
  
  /// Get quiz statistics (Admin)
  Future<Map<String, dynamic>> getQuizStatistics() async {
    try {
      final response = await _supabase
          .from('quiz_results')
          .select('total_score, risk_level');
      
      final results = response as List;
      
      // Calculate statistics
      final totalQuizzes = results.length;
      final avgScore = results.isEmpty
          ? 0.0
          : results.fold<double>(
                0,
                (sum, item) => sum + (item['total_score'] as int? ?? 0),
              ) /
              totalQuizzes;
      
      // Count risk levels
      final riskLevels = <String, int>{};
      for (final result in results) {
        final level = result['risk_level'] as String? ?? 'unknown';
        riskLevels[level] = (riskLevels[level] ?? 0) + 1;
      }
      
      return {
        'total_quizzes': totalQuizzes,
        'average_score': avgScore,
        'risk_levels': riskLevels,
      };
    } catch (e) {
      throw Exception('Failed to get quiz statistics: $e');
    }
  }
}
