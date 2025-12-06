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
  final int totalScore; // 0-100
  final String riskLevel; // low, medium, high, extreme
  final Map<String, dynamic> answers; // {questionId: answer}
  final DateTime completedAt;
  final List<String> recommendations;

  QuizResult({
    required this.id,
    required this.userId,
    required this.totalScore,
    required this.riskLevel,
    required this.answers,
    required this.completedAt,
    required this.recommendations,
  });

  /// Convert ke Map untuk Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'total_score': totalScore,
      'risk_level': riskLevel,
      'answers': answers,
      'completed_at': completedAt.toIso8601String(),
      'recommendations': recommendations,
    };
  }

  /// Buat dari Map
  factory QuizResult.fromMap(Map<String, dynamic> map) {
    return QuizResult(
      id: map['id'].toString(),
      userId: map['user_id'] ?? map['userId'],
      totalScore: map['total_score'] ?? map['totalScore'] ?? 0,
      riskLevel: map['risk_level'] ?? map['riskLevel'] ?? 'low',
      answers: Map<String, dynamic>.from(map['answers'] ?? {}),
      completedAt: DateTime.parse(map['completed_at'] ?? map['completedAt']),
      recommendations: List<String>.from(map['recommendations'] ?? []),
    );
  }
}
