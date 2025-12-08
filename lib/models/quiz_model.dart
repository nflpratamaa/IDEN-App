/// Model untuk Quiz Question/Pertanyaan Quiz
/// Digunakan untuk assessment risiko penyalahgunaan narkotika
/// 
/// Properties:
/// - id: Unique identifier pertanyaan
/// - question: Teks pertanyaan
/// - type: Tipe pertanyaan (multiple_choice, yes_no, scale)
/// - options: List pilihan jawaban
/// - weight: Bobot untuk scoring (0-10)
/// - category: Kategori pertanyaan (perilaku, lingkungan, pengetahuan)
/// - orderIndex: Urutan pertanyaan

class QuizQuestion {
  final String id;
  final String question;
  final String type; // multiple_choice, yes_no, scale
  final List<String> options;
  final int weight; // 0-10 untuk scoring
  final String category; // perilaku, lingkungan, pengetahuan
  final int? orderIndex;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    required this.weight,
    required this.category,
    this.orderIndex,
  });

  /// Convert ke Map untuk Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'type': type,
      'options': options,
      'weight': weight,
      'category': category,
      'order_index': orderIndex,
    };
  }

  /// Buat dari Map
  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'].toString(),
      question: map['question'],
      type: map['type'],
      options: List<String>.from(map['options'] ?? []),
      weight: map['weight'] ?? 1,
      category: map['category'],
      orderIndex: map['order_index'] ?? map['orderIndex'],
    );
  }
}

/// Model untuk Quiz Result/Hasil Quiz
/// Menyimpan hasil assessment user
/// 
/// Properties:
/// - id: Unique identifier hasil
/// - userId: ID user yang mengerjakan
/// - totalScore: Total skor (0-100)
/// - riskLevel: Level risiko hasil: low, medium, high, extreme
/// - answers: Map jawaban user {questionId: answer}
/// - completedAt: Waktu selesai quiz
/// - recommendations: Rekomendasi berdasarkan hasil

class QuizResult {
  final String id;
  final String userId;
  final String? quizId;  // Optional quiz ID
  final int totalScore; // 0-100
  final int? maxScore;   // Max possible score
  final int? percentage; // Percentage score
  final String riskLevel; // low, medium, high, extreme
  final Map<String, dynamic>? answers; // {questionId: answer}
  final DateTime completedAt;
  final List<String>? recommendations;

  QuizResult({
    required this.id,
    required this.userId,
    this.quizId,
    required this.totalScore,
    this.maxScore,
    this.percentage,
    required this.riskLevel,
    this.answers,
    required this.completedAt,
    this.recommendations,
  });

  /// Convert ke Map untuk Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      if (quizId != null) 'quiz_id': quizId,
      'total_score': totalScore,
      if (maxScore != null) 'max_score': maxScore,
      if (percentage != null) 'percentage': percentage,
      'risk_level': riskLevel,
      if (answers != null) 'answers': answers,
      'completed_at': completedAt.toIso8601String(),
      if (recommendations != null) 'recommendations': recommendations,
    };
  }

  /// Buat dari Map
  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      id: map['id'].toString(),
      userId: map['user_id'] ?? map['userId'],
      quizId: map['quiz_id'],
      totalScore: map['total_score'] ?? map['totalScore'] ?? 0,
      maxScore: map['max_score'] ?? map['maxScore'],
      percentage: map['percentage'],
      riskLevel: map['risk_level'] ?? map['riskLevel'] ?? 'low',
      answers: map['answers'] != null ? Map<String, dynamic>.from(map['answers']) : null,
      completedAt: DateTime.parse(map['completed_at'] ?? map['completedAt']),
      recommendations: map['recommendations'] != null 
          ? List<String>.from(map['recommendations']) 
          : null,
    );
  }
}
