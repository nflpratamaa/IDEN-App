/// Content Management - Kelola artikel & katalog narkotika
/// 2 tabs: Articles (list artikel dengan edit/delete) dan Catalog (list drugs)
/// Button: tambah artikel/drug baru, edit, delete dengan konfirmasi
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class ContentManagementScreen extends StatefulWidget {
  const ContentManagementScreen({super.key});

  @override
  State<ContentManagementScreen> createState() => _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen> {
  int _selectedTab = 0;

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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_selectedTab == 0 ? 'Tambah Artikel' : 'Tambah Data Katalog'),
                ),
              );
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
            child: _selectedTab == 0 ? _buildArticleList() : _buildCatalogList(),
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
    final articles = [
      {'title': 'Bahaya Narkotika bagi Remaja', 'category': 'Edukasi', 'views': '1.2k'},
      {'title': 'Cara Menolak Ajakan Narkoba', 'category': 'Tips', 'views': '856'},
      {'title': 'Dampak Jangka Panjang Narkoba', 'category': 'Edukasi', 'views': '2.1k'},
      {'title': 'Gejala Awal Ketergantungan', 'category': 'Info', 'views': '945'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        final article = articles[index];
        return _buildContentCard(
          article['title']!,
          article['category']!,
          article['views']!,
          Icons.article,
        );
      },
    );
  }

  Widget _buildCatalogList() {
    final drugs = [
      {'name': 'Ganja (Marijuana)', 'risk': 'Tinggi', 'category': 'Narkotika'},
      {'name': 'Kokain', 'risk': 'Tinggi', 'category': 'Narkotika'},
      {'name': 'Heroin', 'risk': 'Tinggi', 'category': 'Narkotika'},
      {'name': 'Ekstasi (MDMA)', 'risk': 'Sedang', 'category': 'Psikotropika'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: drugs.length,
      itemBuilder: (context, index) {
        final drug = drugs[index];
        return _buildContentCard(
          drug['name']!,
          drug['category']!,
          drug['risk']!,
          Icons.medication,
        );
      },
    );
  }

  Widget _buildContentCard(String title, String category, String info, IconData icon) {
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
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Hapus')),
            ],
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$value: $title')),
              );
            },
          ),
        ],
      ),
    );
  }
}
