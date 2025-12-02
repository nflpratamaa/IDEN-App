/// Emergency Management - Kelola kontak darurat
/// List kontak: nama, nomor telepon, tipe (hotline/rumah sakit/konseling)
/// Info ketersediaan 24/7, actions edit/delete
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class EmergencyManagementScreen extends StatelessWidget {
  const EmergencyManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contacts = [
      {
        'name': 'BNN Hotline',
        'phone': '021-80871566',
        'type': 'Pemerintah',
        'available': '24/7',
      },
      {
        'name': 'Yayasan Cinta Anak Bangsa',
        'phone': '021-7278-0808',
        'type': 'NGO',
        'available': '24/7',
      },
      {
        'name': 'Rumah Rehabilitasi Harapan',
        'phone': '021-5555-6789',
        'type': 'Rehabilitasi',
        'available': 'Senin-Jumat',
      },
      {
        'name': 'Polda Metro Jaya',
        'phone': '110',
        'type': 'Kepolisian',
        'available': '24/7',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Manajemen Emergency'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tambah Kontak Darurat')),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.emergency,
                    color: AppColors.error,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact['name']!,
                        style: AppTextStyles.h5.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            contact['phone']!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              contact['type']!,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.accent,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            contact['available']!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.success,
                              fontSize: 11,
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
                      SnackBar(content: Text('$value: ${contact['name']}')),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
