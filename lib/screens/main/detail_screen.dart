/// Detail Screen - Info lengkap tentang narkotika
/// Menampilkan: gambar, nama, kategori, risk level, tabs (Deskripsi/Efek/Bahaya)
/// Button: bookmark dan share
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class DetailScreen extends StatefulWidget {
  final String drugName;

  const DetailScreen({super.key, required this.drugName});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header with background
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                ),
                onPressed: () {
                  setState(() {
                    _isBookmarked = !_isBookmarked;
                  });
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        widget.drugName,
                        style: AppTextStyles.h2.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Stimulan • Risiko Tinggi',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Danger Button
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Berbahaya',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Tabs
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textLight,
                indicatorColor: AppColors.primary,
                labelStyle: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Informasi'),
                  Tab(text: 'Efek'),
                  Tab(text: 'Tanda'),
                  Tab(text: 'Bantuan'),
                ],
              ),
            ),
          ),
          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInformasiTab(),
                _buildEfekTab(),
                _buildTandaTab(),
                _buildBantuanTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformasiTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            'Nama Lain',
            'Sabu, Crystal Meth, Ice, Shabu',
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            'Kategori',
            'Stimulan Sistem Saraf Pusat',
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            'Deskripsi',
            'Zat stimulan yang sangat adiktif yang mempengaruhi sistem saraf pusat. Meningkatkan dopamin secara drastis menyebabkan euforia dan hiperaktivitas.',
          ),
          const SizedBox(height: 24),
          _buildDurationCard('8-24 jam', 'Tergantung dosis'),
          const SizedBox(height: 16),
          _buildAddictionCard('Sangat Tinggi', 'Ketergantungan cepat'),
        ],
      ),
    );
  }

  Widget _buildEfekTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Efek Jangka Pendek',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: 12),
          _buildEffectItem('Euforia intens'),
          _buildEffectItem('Peningkatan energi'),
          _buildEffectItem('Berkurangnya nafsu makan'),
          _buildEffectItem('Detak jantung cepat'),
          const SizedBox(height: 24),
          Text(
            'Efek Jangka Panjang',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: 12),
          _buildEffectItem('Kerusakan gigi parah'),
          _buildEffectItem('Gangguan mental'),
          _buildEffectItem('Kerusakan organ'),
          _buildEffectItem('Ketergantungan berat'),
        ],
      ),
    );
  }

  Widget _buildTandaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tanda-tanda Penggunaan',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: 12),
          _buildSignItem('Pupil melebar'),
          _buildSignItem('Hiperaktivitas'),
          _buildSignItem('Tidak bisa tidur'),
          _buildSignItem('Penurunan berat badan drastis'),
          _buildSignItem('Perilaku agresif'),
          const SizedBox(height: 24),
          Text(
            'Gejala Overdosis',
            style: AppTextStyles.h4.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 12),
          _buildWarningItem('Detak jantung sangat cepat'),
          _buildWarningItem('Suhu tubuh tinggi'),
          _buildWarningItem('Kejang-kejang'),
          _buildWarningItem('Halusinasi parah'),
        ],
      ),
    );
  }

  Widget _buildBantuanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Langkah-langkah Bantuan',
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: 12),
          _buildStepItem('1', 'Hubungi hotline darurat 119 / 021-500-454'),
          _buildStepItem('2', 'Cari bantuan profesional kesehatan'),
          _buildStepItem('3', 'Pertimbangkan program rehabilitasi'),
          _buildStepItem('4', 'Dukungan keluarga dan teman'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info, color: AppColors.info),
                    const SizedBox(width: 8),
                    Text(
                      'Informasi Penting',
                      style: AppTextStyles.h4.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Semua informasi bersifat rahasia dan anonim. Anda tidak sendirian dalam menghadapi masalah ini.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.label.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDurationCard(String duration, String note) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DURASI EFEK',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                  ),
                ),
                Text(
                  duration,
                  style: AppTextStyles.h4,
                ),
                Text(
                  note,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddictionCard(String level, String note) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.riskHigh.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: AppColors.riskHigh),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KECANDUAN',
                  style: AppTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.riskHigh,
                  ),
                ),
                Text(
                  level,
                  style: AppTextStyles.h4,
                ),
                Text(
                  note,
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEffectItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.fiber_manual_record,
            size: 12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 20,
            color: AppColors.info,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            size: 20,
            color: AppColors.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                number,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                text,
                style: AppTextStyles.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
