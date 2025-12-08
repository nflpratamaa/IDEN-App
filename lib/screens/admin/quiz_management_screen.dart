/// Quiz Management - Kelola pertanyaan quiz
/// Summary: total questions, by category
/// List pertanyaan dengan type, weight, actions edit/delete
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../models/quiz_model.dart';

class QuizManagementScreen extends StatefulWidget {
  const QuizManagementScreen({super.key});

  @override
  State<QuizManagementScreen> createState() => _QuizManagementScreenState();
}

class _QuizManagementScreenState extends State<QuizManagementScreen> {
  final _supabase = Supabase.instance.client;
  List<QuizQuestion> _questions = [];
  bool _isLoading = true;
  int _totalResponses = 0;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    try {
      setState(() => _isLoading = true);
      print('📥 Memuat data quiz...');
      
      final quizzesData = await _supabase.from('quizzes').select().order('created_at', ascending: false);
      final questions = quizzesData.map((json) => QuizQuestion.fromMap(json)).toList();
      
      // Get total responses count
      final responsesData = await _supabase.from('quiz_results').select();
      
      print('✅ Berhasil memuat ${questions.length} pertanyaan');
      setState(() {
        _questions = questions;
        _totalResponses = responsesData.length;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Gagal memuat quiz: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data quiz: $e')),
        );
      }
    }
  }

  Future<void> _deleteQuiz(String id, String question) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pertanyaan'),
        content: Text('Yakin ingin menghapus pertanyaan "$question"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        print('🔄 Menghapus quiz: $id');
        await _supabase.from('quizzes').delete().eq('id', id);
        print('✅ Quiz berhasil dihapus');
        await _loadQuizzes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pertanyaan berhasil dihapus')),
          );
        }
      } catch (e) {
        print('❌ Gagal menghapus quiz: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus pertanyaan: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalWeight = _questions.fold(0, (sum, q) => sum + q.weight);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Manajemen Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadQuizzes,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddQuizDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Summary Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Total Soal', '${_questions.length}'),
                _buildSummaryItem('Total Bobot', '$totalWeight'),
                _buildSummaryItem('Responden', '$_totalResponses'),
              ],
            ),
          ),
          
          // Question List
          Expanded(
            child: _questions.isEmpty
                ? const Center(child: Text('Belum ada pertanyaan quiz'))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final q = _questions[index];
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              q.question,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          PopupMenuButton(
                            icon: const Icon(Icons.more_vert),
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'edit', child: Text('Edit')),
                              const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                            ],
                            onSelected: (value) {
                              if (value == 'delete') {
                                _deleteQuiz(q.id, q.question);
                              } else if (value == 'edit') {
                                _showEditQuizDialog(q);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildChip('${q.options.length} pilihan', AppColors.accent),
                          const SizedBox(width: 8),
                          _buildChip('Bobot: ${q.weight}', AppColors.success),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontSize: 11,
        ),
      ),
    );
  }

  void _showAddQuizDialog() {
    final questionController = TextEditingController();
    final weightController = TextEditingController();
    final typeController = TextEditingController(text: 'multiple_choice');
    final categoryController = TextEditingController(text: 'perilaku');
    final List<TextEditingController> optionControllers = [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ];
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Pertanyaan Quiz'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  decoration: const InputDecoration(
                    labelText: 'Pertanyaan',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    labelText: 'Tipe (multiple_choice/yes_no/scale)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Kategori (perilaku/lingkungan/pengetahuan)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    labelText: 'Bobot (0-100)',
                    border: OutlineInputBorder(),
                    helperText: 'Masukkan angka antara 0-100 untuk scoring',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text('Pilihan Jawaban:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: optionControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Pilihan ${index + 1}',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                if (questionController.text.isEmpty || weightController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pertanyaan dan bobot harus diisi')),
                  );
                  return;
                }

                try {
                  print('🔄 Menambah pertanyaan quiz baru');
                  
                  final options = optionControllers
                      .where((c) => c.text.isNotEmpty)
                      .map((c) => c.text)
                      .toList();
                  
                  final weight = int.tryParse(weightController.text) ?? 1;
                  
                  // Validate weight (0-100)
                  if (weight < 0 || weight > 100) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bobot harus antara 0-100')),
                    );
                    return;
                  }
                  
                  final quiz = QuizQuestion(
                    id: const Uuid().v4(),
                    question: questionController.text,
                    type: typeController.text,
                    category: categoryController.text,
                    options: options,
                    weight: weight,
                    orderIndex: 0, // Default order
                  );
                  
                  await _supabase.from('quizzes').insert(quiz.toMap());
                  print('✅ Pertanyaan quiz berhasil ditambah');
                  
                  Navigator.pop(context);
                  await _loadQuizzes();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pertanyaan berhasil ditambah')),
                    );
                  }
                } catch (e) {
                  print('❌ Gagal menambah pertanyaan: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal menambah pertanyaan: $e')),
                    );
                  }
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditQuizDialog(QuizQuestion quiz) {
    final questionController = TextEditingController(text: quiz.question);
    final weightController = TextEditingController(text: quiz.weight.toString());
    final typeController = TextEditingController(text: quiz.type);
    final categoryController = TextEditingController(text: quiz.category);
    
    final List<TextEditingController> optionControllers = List.generate(
      4,
      (index) => TextEditingController(
        text: index < quiz.options.length ? quiz.options[index] : '',
      ),
    );
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Pertanyaan Quiz'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: questionController,
                  decoration: const InputDecoration(
                    labelText: 'Pertanyaan',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: typeController,
                  decoration: const InputDecoration(
                    labelText: 'Tipe (multiple_choice/yes_no/scale)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Kategori (perilaku/lingkungan/pengetahuan)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: weightController,
                  decoration: const InputDecoration(
                    labelText: 'Bobot (0-100)',
                    border: OutlineInputBorder(),
                    helperText: 'Masukkan angka antara 0-100 untuk scoring',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text('Pilihan Jawaban:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: optionControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Pilihan ${index + 1}',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                if (questionController.text.isEmpty || weightController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Pertanyaan dan bobot harus diisi')),
                  );
                  return;
                }

                try {
                  print('🔄 Mengupdate pertanyaan quiz: ${quiz.id}');
                  
                  final options = optionControllers
                      .where((c) => c.text.isNotEmpty)
                      .map((c) => c.text)
                      .toList();
                  
                  final weight = int.tryParse(weightController.text) ?? quiz.weight;
                  print('🔍 Weight value: $weight (from text: "${weightController.text}")');
                  
                  // Validate weight (0-100)
                  if (weight < 0 || weight > 100) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Bobot harus antara 0-100')),
                    );
                    return;
                  }
                  
                  final updatedQuiz = QuizQuestion(
                    id: quiz.id,
                    question: questionController.text,
                    type: typeController.text,
                    category: categoryController.text,
                    options: options,
                    weight: weight,
                    orderIndex: quiz.orderIndex ?? 0, // Fix: default to 0
                  );
                  
                  // Remove null values from map
                  final updateData = updatedQuiz.toMap();
                  updateData.removeWhere((key, value) => value == null);
                  
                  print('🔍 Sending to DB: $updateData');
                  await _supabase.from('quizzes').update(updateData).eq('id', quiz.id);
                  print('✅ Pertanyaan quiz berhasil diupdate');
                  
                  Navigator.pop(context);
                  await _loadQuizzes();
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pertanyaan berhasil diupdate')),
                    );
                  }
                } catch (e) {
                  print('❌ Gagal mengupdate pertanyaan: $e');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Gagal mengupdate pertanyaan: $e')),
                    );
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}