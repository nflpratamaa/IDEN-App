/// Catalog Screen - Daftar narkotika dengan search & filter
/// Menampilkan: search bar, filter chips (semua/rendah/sedang/tinggi/ekstrem)
/// List narkotika dengan nama, kategori, risk badge, navigasi ke detail
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import 'detail_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _selectedCategory = 'Semua';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _drugs = [
    {
      'name': 'Metamfetamin',
      'otherNames': 'Sabu, Crystal Meth, Ice, Shabu',
      'category': 'Stimulan',
      'riskLevel': 'Tinggi',
      'riskColor': AppColors.riskHigh,
    },
    {
      'name': 'Kokain',
      'otherNames': 'Coke, Snow, Crack',
      'category': 'Stimulan',
      'riskLevel': 'Tinggi',
      'riskColor': AppColors.riskHigh,
    },
    {
      'name': 'MDMA (Ekstasi)',
      'otherNames': 'Ecstasy, Molly',
      'category': 'Stimulan',
      'riskLevel': 'Sedang',
      'riskColor': AppColors.riskMedium,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Katalog Informasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari jenis narkotika...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textLight,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textLight,
                ),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // Category Filter
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildCategoryChip('Semua'),
                _buildCategoryChip('Stimulan'),
                _buildCategoryChip('Depresan'),
              ],
            ),
          ),
          // Category Title
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  'Kategori Stimulan',
                  style: AppTextStyles.h4,
                ),
              ],
            ),
          ),
          // Subtitle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Zat yang meningkatkan aktivitas sistem saraf pusat',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Drug List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _drugs.length,
              itemBuilder: (context, index) {
                final drug = _drugs[index];
                return _buildDrugCard(drug);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label) {
    final isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = label;
          });
        },
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          color: isSelected ? Colors.white : AppColors.textSecondary,
        ),
        backgroundColor: Colors.white,
        selectedColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
      ),
    );
  }

  Widget _buildDrugCard(Map<String, dynamic> drug) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(drugName: drug['name']),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            // Warning Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: drug['riskColor'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: drug['riskColor'],
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            // Drug Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    drug['name'],
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nama lain: ${drug['otherNames']}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: drug['riskColor'],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Risiko ${drug['riskLevel']}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textLight,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
