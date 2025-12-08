/// Content Management - Kelola artikel & katalog narkotika
/// 2 tabs: Articles (list artikel dengan edit/delete) dan Catalog (list drugs)
/// Button: tambah artikel/drug baru, edit, delete dengan konfirmasi
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../services/article_service.dart';
import '../../services/drug_service.dart';
import '../../models/article_model.dart';
import '../../models/drug_model.dart';

class ContentManagementScreen extends StatefulWidget {
  const ContentManagementScreen({super.key});

  @override
  State<ContentManagementScreen> createState() => _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen> {
  int _selectedTab = 0;
  final _articleService = ArticleService();
  final _drugService = DrugService();
  List<ArticleModel> _articles = [];
  List<DrugModel> _drugs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() => _isLoading = true);
      final articles = await _articleService.getAllArticles();
      final drugs = await _drugService.getAllDrugs();
      setState(() {
        _articles = articles;
        _drugs = drugs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
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
        title: const Text('Manajemen Konten'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              if (_selectedTab == 0) {
                _showAddArticleDialog();
              } else {
                _showAddDrugDialog();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: _buildTab('Artikel', 0),
                ),
                Expanded(
                  child: _buildTab('Katalog', 1),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _selectedTab == 0
                    ? _buildArticleList()
                    : _buildCatalogList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.h5.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildArticleList() {
    if (_articles.isEmpty) {
      return const Center(
        child: Text('Belum ada artikel'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _articles.length,
      itemBuilder: (context, index) {
        final article = _articles[index];
        return _buildContentCard(
          article.title,
          article.category,
          '${article.readCount} views',
          Icons.article,
          onEdit: () => _showEditArticleDialog(article),
          onDelete: () => _deleteArticle(article.id),
        );
      },
    );
  }

  Future<void> _deleteArticle(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Artikel'),
        content: const Text('Yakin ingin menghapus artikel ini?'),
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
        print('🔄 Menghapus artikel: $id');
        await _articleService.deleteArticle(id);
        print('✅ Artikel berhasil dihapus');
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Artikel berhasil dihapus')),
          );
        }
      } catch (e) {
        print('❌ Gagal menghapus artikel: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus artikel: $e')),
          );
        }
      }
    }
  }

  Widget _buildCatalogList() {
    if (_drugs.isEmpty) {
      return const Center(
        child: Text('Belum ada data katalog'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _drugs.length,
      itemBuilder: (context, index) {
        final drug = _drugs[index];
        return _buildContentCard(
          drug.name,
          drug.category,
          'Risiko: ${drug.riskLevel}',
          Icons.medication,
          onEdit: () => _showEditDrugDialog(drug),
          onDelete: () => _deleteDrug(drug.id),
        );
      },
    );
  }

  Future<void> _deleteDrug(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data'),
        content: const Text('Yakin ingin menghapus data narkotika ini?'),
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
        print('🔄 Menghapus data narkotika: $id');
        await _drugService.deleteDrug(id);
        print('✅ Data narkotika berhasil dihapus');
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data berhasil dihapus')),
          );
        }
      } catch (e) {
        print('❌ Gagal menghapus data: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus data: $e')),
          );
        }
      }
    }
  }

  Widget _buildContentCard(
    String title,
    String category,
    String info,
    IconData icon, {
    VoidCallback? onDelete,
    VoidCallback? onEdit,
  }) {
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.h5.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accent,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      info,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onDelete != null || onEdit != null)
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Hapus')),
              ],
              onSelected: (value) {
                if (value == 'delete') {
                  onDelete?.call();
                } else if (value == 'edit') {
                  onEdit?.call();
                }
              },
            )
          else
            const Icon(Icons.more_vert, color: AppColors.textLight),
        ],
      ),
    );
  }

  void _showAddArticleDialog() {
    showDialog(
      context: context,
      builder: (context) => _ArticleDialog(
        onSave: (article) async {
          try {
            await _articleService.addArticle(article);
            await _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Artikel berhasil ditambah')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal menambah artikel: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showAddDrugDialog() {
    showDialog(
      context: context,
      builder: (context) => _DrugDialog(
        onSave: (drug) async {
          try {
            await _drugService.addDrug(drug);
            await _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data berhasil ditambah')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal menambah data: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditArticleDialog(ArticleModel article) {
    showDialog(
      context: context,
      builder: (context) => _ArticleDialog(
        article: article,
        onSave: (updatedArticle) async {
          try {
            await _articleService.updateArticle(updatedArticle);
            await _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Artikel berhasil diupdate')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal mengupdate artikel: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditDrugDialog(DrugModel drug) {
    showDialog(
      context: context,
      builder: (context) => _DrugDialog(
        drug: drug,
        onSave: (updatedDrug) async {
          try {
            await _drugService.updateDrug(updatedDrug);
            await _loadData();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data berhasil diupdate')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Gagal mengupdate data: $e')),
              );
            }
          }
        },
      ),
    );
  }
}

// Dialog untuk Tambah/Edit Artikel dengan Image Picker
class _ArticleDialog extends StatefulWidget {
  final ArticleModel? article;
  final Function(ArticleModel) onSave;

  const _ArticleDialog({
    this.article,
    required this.onSave,
  });

  @override
  State<_ArticleDialog> createState() => _ArticleDialogState();
}

class _ArticleDialogState extends State<_ArticleDialog> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _authorController;
  late TextEditingController _categoryController;
  late TextEditingController _imageUrlController;
  
  String _imageMode = 'url'; // 'url' or 'gallery'
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.article?.title ?? '');
    _contentController = TextEditingController(text: widget.article?.content ?? '');
    _authorController = TextEditingController(text: widget.article?.author ?? '');
    _categoryController = TextEditingController(text: widget.article?.category ?? '');
    _imageUrlController = TextEditingController(text: widget.article?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _authorController.dispose();
    _categoryController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _imageUrlController.text = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.article == null ? 'Tambah Artikel' : 'Edit Artikel'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Judul Artikel',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Isi Artikel',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Penulis',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Kategori (Edukasi/Berita/Tips)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Image Section
            Text(
              'Gambar Artikel',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Mode Selector
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('URL'),
                    value: 'url',
                    groupValue: _imageMode,
                    onChanged: (value) {
                      setState(() {
                        _imageMode = value!;
                        _selectedImage = null;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Galeri'),
                    value: 'gallery',
                    groupValue: _imageMode,
                    onChanged: (value) {
                      setState(() {
                        _imageMode = value!;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // URL Input or Gallery Picker
            if (_imageMode == 'url') ...[
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/image.jpg',
                ),
              ),
              if (_imageUrlController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _imageUrlController.text,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.error, color: Colors.red),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ] else ...[
              ElevatedButton.icon(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Pilih dari Galeri'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              if (_selectedImage != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ],
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
            if (_titleController.text.isEmpty || 
                _contentController.text.isEmpty ||
                _authorController.text.isEmpty ||
                _categoryController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Semua field harus diisi')),
              );
              return;
            }

            // Note: Untuk gallery mode, di production harus upload ke storage dulu
            // Disini kita simpan path lokal atau bisa kosongkan
            String imageUrl = _imageUrlController.text;
            if (_imageMode == 'gallery' && _selectedImage != null) {
              // TODO: Upload to Supabase Storage atau cloud storage lainnya
              // Untuk sementara gunakan path lokal (tidak akan work di production)
              imageUrl = _selectedImage!.path;
              
              // Warning untuk development
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Note: Gambar dari galeri belum terupload ke server. Implementasikan Supabase Storage untuk production.'),
                  duration: Duration(seconds: 3),
                ),
              );
            }

            final article = ArticleModel(
              id: widget.article?.id ?? const Uuid().v4(),
              title: _titleController.text,
              content: _contentController.text,
              imageUrl: imageUrl,
              author: _authorController.text,
              category: _categoryController.text,
              readTime: widget.article?.readTime ?? 5,
              readCount: widget.article?.readCount ?? 0,
              publishedAt: widget.article?.publishedAt ?? DateTime.now(),
              tags: widget.article?.tags ?? [],
            );

            Navigator.pop(context);
            widget.onSave(article);
          },
          child: Text(widget.article == null ? 'Tambah' : 'Simpan'),
        ),
      ],
    );
  }
}

// Dialog untuk Tambah/Edit Data Narkotika dengan Image Picker
class _DrugDialog extends StatefulWidget {
  final DrugModel? drug;
  final Function(DrugModel) onSave;

  const _DrugDialog({
    this.drug,
    required this.onSave,
  });

  @override
  State<_DrugDialog> createState() => _DrugDialogState();
}

class _DrugDialogState extends State<_DrugDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _riskLevelController;
  late TextEditingController _imageUrlController;

  String _imageMode = 'url'; // 'url' atau 'gallery'
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.drug?.name ?? '');
    _descriptionController = TextEditingController(text: widget.drug?.description ?? '');
    _categoryController = TextEditingController(text: widget.drug?.category ?? '');
    _riskLevelController = TextEditingController(text: widget.drug?.riskLevel ?? '');
    _imageUrlController = TextEditingController(text: widget.drug?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _riskLevelController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _imageUrlController.text = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.drug == null ? 'Tambah Data Narkotika' : 'Edit Data Narkotika'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Narkotika',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Kategori (Golongan I/II/III/Stimulan/dll)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _riskLevelController,
              decoration: const InputDecoration(
                labelText: 'Level Risiko (low/medium/high/extreme)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Image Section
            Text(
              'Gambar',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('URL'),
                    value: 'url',
                    groupValue: _imageMode,
                    onChanged: (value) {
                      setState(() {
                        _imageMode = value!;
                        _selectedImage = null;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Galeri'),
                    value: 'gallery',
                    groupValue: _imageMode,
                    onChanged: (value) {
                      setState(() {
                        _imageMode = value!;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_imageMode == 'url') ...[
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar',
                  border: OutlineInputBorder(),
                  hintText: 'https://example.com/image.jpg',
                ),
              ),
              if (_imageUrlController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      _imageUrlController.text,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.error, color: Colors.red),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ] else ...[
              ElevatedButton.icon(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Pilih dari Galeri'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
              if (_selectedImage != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            if (_nameController.text.isEmpty ||
                _descriptionController.text.isEmpty ||
                _categoryController.text.isEmpty ||
                _riskLevelController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Semua field harus diisi')),
              );
              return;
            }

            String imageUrl = _imageUrlController.text;
            if (_imageMode == 'gallery' && _selectedImage != null) {
              imageUrl = _selectedImage!.path;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Note: Gambar dari galeri belum terupload ke server. Implementasikan Supabase Storage untuk production.'),
                  duration: Duration(seconds: 3),
                ),
              );
            }

            final drug = DrugModel(
              id: widget.drug?.id ?? const Uuid().v4(),
              name: _nameController.text,
              otherNames: widget.drug?.otherNames ?? '',
              category: _categoryController.text,
              description: _descriptionController.text,
              effects: widget.drug?.effects ?? [],
              dangers: widget.drug?.dangers ?? [],
              legalStatus: widget.drug?.legalStatus ?? 'Ilegal',
              imageUrl: imageUrl.isEmpty ? null : imageUrl,
              riskLevel: _riskLevelController.text.toLowerCase(),
            );

            Navigator.pop(context);
            widget.onSave(drug);
          },
          child: Text(widget.drug == null ? 'Tambah' : 'Simpan'),
        ),
      ],
    );
  }
}
