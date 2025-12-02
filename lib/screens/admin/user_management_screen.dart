/// User Management - Kelola akun user
/// List users dengan avatar, email, stats quiz, status aktif
/// Actions: block/unblock user, lihat detail aktivitas user
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final users = [
      {'name': 'Budi Santoso', 'email': 'budi@email.com', 'quiz': '5', 'status': 'Aktif'},
      {'name': 'Ani Wijaya', 'email': 'ani@email.com', 'quiz': '3', 'status': 'Aktif'},
      {'name': 'Citra Dewi', 'email': 'citra@email.com', 'quiz': '8', 'status': 'Aktif'},
      {'name': 'Dedi Kurniawan', 'email': 'dedi@email.com', 'quiz': '2', 'status': 'Blocked'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Manajemen Pengguna'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final isBlocked = user['status'] == 'Blocked';
          
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
                CircleAvatar(
                  radius: 28,
                  backgroundColor: isBlocked ? AppColors.textLight : AppColors.primary,
                  child: Text(
                    user['name']![0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name']!,
                        style: AppTextStyles.h5.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isBlocked ? AppColors.textLight : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['email']!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user['quiz']} quiz diambil',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'view', child: Text('Lihat Detail')),
                    PopupMenuItem(
                      value: 'block',
                      child: Text(isBlocked ? 'Unblock' : 'Block'),
                    ),
                    const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                  ],
                  onSelected: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$value: ${user['name']}')),
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
