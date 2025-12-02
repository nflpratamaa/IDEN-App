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

class QuizQuestionModel {
  final String id;
  final String question;
  final String type; // multiple_choice, yes_no, scale
  final List<String> options;
  final int weight; // 0-10 untuk scoring
  final String category; // perilaku, lingkungan, pengetahuan

  QuizQuestionModel({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    required this.weight,
    required this.category,
  });

  /// Convert ke Map untuk Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'type': type,
      'options': options,
      'weight': weight,
      'category': category,
    };
  }

  /// Buat dari Map
  factory QuizQuestionModel.fromMap(Map<String, dynamic> map) {
    return QuizQuestionModel(
      id: map['id'],
      question: map['question'],
      type: map['type'],
      options: List<String>.from(map['options']),
      weight: map['weight'],
      category: map['category'],
    );
  }
}

/// Model untuk Quiz Result/Hasil Quiz
/// Menyimpan hasil assessment user
/// 
/// Properties:
/// - id: Unique identifier hasil
/// - userId: ID user yang mengerjakan
/// - score: Total skor (0-100)
/// - riskLevel: Level risiko hasil: low, medium, high, extreme
/// - answers: Map jawaban user {questionId: answer}
/// - completedAt: Waktu selesai quiz
/// - recommendations: Rekomendasi berdasarkan hasil

class QuizResultModel {
  final String id;
  final String userId;
  final int score; // 0-100
  final String riskLevel; // low, medium, high, extreme
  final Map<String, String> answers; // {questionId: answer}
  final DateTime completedAt;
  final List<String> recommendations;

  QuizResultModel({
    required this.id,
    required this.userId,
    required this.score,
    required this.riskLevel,
    required this.answers,
    required this.completedAt,
    required this.recommendations,
  });

  /// Convert ke Map untuk Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'score': score,
      'riskLevel': riskLevel,
      'answers': answers,
      'completedAt': completedAt.toIso8601String(),
      'recommendations': recommendations,
    };
  }

  /// Buat dari Map
  factory QuizResultModel.fromMap(Map<String, dynamic> map) {
    return QuizResultModel(
      id: map['id'],
      userId: map['userId'],
      score: map['score'],
      riskLevel: map['riskLevel'],
      answers: Map<String, String>.from(map['answers']),
      completedAt: DateTime.parse(map['completedAt']),
      recommendations: List<String>.from(map['recommendations']),
    );
  }
}
