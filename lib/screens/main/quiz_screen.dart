/// Quiz Screen - Assessment risiko penyalahgunaan narkotika
/// Pertanyaan dengan options, progress indicator, validasi jawaban
/// Setelah selesai, navigasi ke Result Screen dengan skor
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestion = 0;
  final List<int> _answers = [];

  final List<Map<String, dynamic>> _questions = [
    {
      'question':
          'Seberapa sering Anda menggunakan zat terlarang dalam 30 hari terakhir?',
      'options': [
        {'text': 'Tidak pernah', 'score': 0},
        {'text': '1-2 kali', 'score': 1},
        {'text': '3-5 kali', 'score': 2},
        {'text': 'Lebih dari 5 kali', 'score': 3},
      ],
    },
    {
      'question':
          'Apakah Anda merasa sulit mengendalikan penggunaan zat tersebut?',
      'options': [
        {'text': 'Tidak sama sekali', 'score': 0},
        {'text': 'Kadang-kadang', 'score': 1},
        {'text': 'Sering', 'score': 2},
        {'text': 'Selalu', 'score': 3},
      ],
    },
    {
      'question':
          'Apakah penggunaan zat tersebut mengganggu aktivitas sehari-hari Anda?',
      'options': [
        {'text': 'Tidak', 'score': 0},
        {'text': 'Sedikit', 'score': 1},
        {'text': 'Cukup mengganggu', 'score': 2},
        {'text': 'Sangat mengganggu', 'score': 3},
      ],
    },
    {
      'question':
          'Apakah orang terdekat Anda mengkhawatirkan penggunaan zat tersebut?',
      'options': [
        {'text': 'Tidak', 'score': 0},
        {'text': 'Mungkin', 'score': 1},
        {'text': 'Ya', 'score': 2},
        {'text': 'Sangat khawatir', 'score': 3},
      ],
    },
    {
      'question':
          'Apakah Anda pernah mencoba berhenti tetapi tidak berhasil?',
      'options': [
        {'text': 'Tidak pernah mencoba', 'score': 0},
        {'text': 'Pernah, berhasil', 'score': 1},
        {'text': 'Pernah, tidak berhasil', 'score': 2},
        {'text': 'Sering mencoba, selalu gagal', 'score': 3},
      ],
    },
  ];

  void _selectAnswer(int score) {
    setState(() {
      if (_answers.length > _currentQuestion) {
        _answers[_currentQuestion] = score;
      } else {
        _answers.add(score);
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
      });
    } else {
      _submitQuiz();
    }
  }

  void _previousQuestion() {
    if (_currentQuestion > 0) {
      setState(() {
        _currentQuestion--;
      });
    }
  }

  void _submitQuiz() {
    final totalScore = _answers.reduce((a, b) => a + b);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          totalScore: totalScore,
          maxScore: _questions.length * 3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _questions[_currentQuestion];
    final progress = (_currentQuestion + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Penilaian Risiko'),
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pertanyaan ${_currentQuestion + 1} dari ${_questions.length}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.accent,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          // Question Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.riskLow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: AppColors.riskLow,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Question Text
                  Text(
                    currentQ['question'],
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: 32),
                  // Options
                  ...List.generate(
                    currentQ['options'].length,
                    (index) {
                      final option = currentQ['options'][index];
                      final isSelected = _answers.length > _currentQuestion &&
                          _answers[_currentQuestion] == option['score'];

                      return GestureDetector(
                        onTap: () => _selectAnswer(option['score']),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: 2,
                                  ),
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 16,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option['text'],
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Row(
              children: [
                if (_currentQuestion > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousQuestion,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Sebelumnya'),
                    ),
                  ),
                if (_currentQuestion > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _answers.length > _currentQuestion
                        ? _nextQuestion
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: AppColors.border,
                    ),
                    child: Text(
                      _currentQuestion == _questions.length - 1
                          ? 'Selesai'
                          : 'Selanjutnya',
                      style: AppTextStyles.button,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
