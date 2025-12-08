/// Profile Screen - Layar profil & pengaturan user
/// Menampilkan: info user real dari Supabase, stats quiz/artikel, menu settings
/// Menu: Edit Profil, Upload Photo, Password, Notifikasi, Admin Panel, Logout
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../services/auth_service.dart';
import '../admin/admin_login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  bool _notificationsEnabled = true;
  bool _isLoading = true;
  
  // User data
  String _userName = 'Loading...';
  String _userEmail = 'Loading...';
  String? _profileImageUrl;
  int _quizzesTaken = 0;
  int _articlesRead = 0;
  int _savedItems = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() => _isLoading = true);
      
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('❌ No user logged in');
        return;
      }

      print('📥 Loading profile for user: ${user.id}');
      
      // Load user data from users table
      final userData = await _supabase
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      // Count quiz results
      final quizResults = await _supabase
          .from('quiz_results')
          .select('id')
          .eq('user_id', user.id);
      final quizCount = (quizResults as List).length;

      // Count read history
      final readHistory = await _supabase
          .from('read_history')
          .select('id')
          .eq('user_id', user.id);
      final readCount = (readHistory as List).length;

      // Count bookmarks
      final bookmarks = await _supabase
          .from('bookmarks')
          .select('id')
          .eq('user_id', user.id);
      final bookmarkCount = (bookmarks as List).length;

      if (mounted) {
        setState(() {
          _userName = userData['name'] ?? 'Pengguna IDEN';
          _userEmail = userData['email'] ?? user.email ?? 'user@iden.com';
          _profileImageUrl = userData['profile_image_url'];
          _quizzesTaken = quizCount;
          _articlesRead = readCount;
          _savedItems = bookmarkCount;
          _isLoading = false;
        });
        print('✅ Profile loaded - Quiz: $quizCount, Read: $readCount, Saved: $bookmarkCount');
      }
    } catch (e) {
      print('❌ Failed to load profile: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat profil: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        // Show loading
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 16),
                  Text('Mengupload foto profil...'),
                ],
              ),
              duration: Duration(seconds: 10),
            ),
          );
        }

        try {
          final user = _supabase.auth.currentUser;
          if (user == null) {
            throw Exception('User tidak ditemukan');
          }

          // Read image as bytes
          final bytes = await image.readAsBytes();
          
          // Extract clean file extension (avoid blob: URLs)
          String fileExt = 'jpg'; // default
          final path = image.path.toLowerCase();
          
          if (path.contains('.png')) {
            fileExt = 'png';
          } else if (path.contains('.webp')) {
            fileExt = 'webp';
          } else if (path.contains('.jpg') || path.contains('.jpeg')) {
            fileExt = 'jpg';
          }
          
          final fileName = '${user.id}.$fileExt';

          // Determine content type based on extension
          String contentType = 'image/jpeg'; // default
          if (fileExt == 'png') {
            contentType = 'image/png';
          } else if (fileExt == 'webp') {
            contentType = 'image/webp';
          } else {
            contentType = 'image/jpeg';
          }

          print('📤 Uploading avatar: $fileName (${bytes.length} bytes, $contentType)');

          // Upload to Supabase Storage with proper content type
          await _supabase.storage.from('avatars').uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: contentType, // Fix MIME type error
              cacheControl: '3600',
              upsert: true, // Overwrite if exists
            ),
          );

          // Get public URL
          final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
          print('✅ Upload successful: $imageUrl');

          // Update profile_image_url in database
          await _supabase
              .from('users')
              .update({'profile_image_url': imageUrl})
              .eq('id', user.id);

          // Update local state
          setState(() {
            _profileImageUrl = imageUrl;
          });

          // Hide loading and show success
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 16),
                    Text('Foto profil berhasil diperbarui!'),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } catch (uploadError) {
          print('❌ Upload failed: $uploadError');
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text('Gagal upload: $uploadError'),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('❌ Failed to pick image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  void _showEditNameDialog() {
    final TextEditingController nameController = TextEditingController(text: _userName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Nama'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nama Lengkap',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama tidak boleh kosong')),
                );
                return;
              }

              try {
                final user = _supabase.auth.currentUser;
                if (user != null) {
                  await _supabase
                      .from('users')
                      .update({'name': newName})
                      .eq('id', user.id);
                  
                  setState(() => _userName = newName);
                  
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nama berhasil diupdate')),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal update nama: $e')),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              _showEditNameDialog();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // Avatar with edit button
                  Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.accent, width: 3),
                          image: _profileImageUrl != null
                              ? DecorationImage(
                                  image: NetworkImage(_profileImageUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _profileImageUrl == null
                            ? Icon(
                                Icons.person,
                                size: 50,
                                color: AppColors.primary,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Name
                  Text(
                    _userName,
                    style: AppTextStyles.h3.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userEmail,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem('$_quizzesTaken', 'Quiz Diikuti'),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      _buildStatItem('$_articlesRead', 'Artikel Dibaca'),
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      _buildStatItem('$_savedItems', 'Tersimpan'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Menu Items
            _buildMenuSection(
              'Akun',
              [
                _buildMenuItem(
                  Icons.person_outline,
                  'Edit Nama',
                  'Ubah nama tampilan',
                  () => _showEditNameDialog(),
                ),
                _buildMenuItem(
                  Icons.refresh,
                  'Refresh Profile',
                  'Muat ulang data profil',
                  () => _loadUserProfile(),
                ),
                _buildMenuItem(
                  Icons.lock_outline,
                  'Ubah Password',
                  'Perbarui password Anda',
                  () => _showChangePasswordDialog(),
                ),
                _buildMenuItem(
                  Icons.email_outlined,
                  'Email & Notifikasi',
                  'Kelola preferensi email',
                  () => _showEmailSettingsDialog(),
                ),
              ],
            ),
            _buildMenuSection(
              'Pengaturan',
              [
                _buildSwitchMenuItem(
                  Icons.notifications_outlined,
                  'Notifikasi',
                  'Aktifkan notifikasi push',
                  _notificationsEnabled,
                  (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                _buildMenuItem(
                  Icons.language,
                  'Bahasa',
                  'Indonesia',
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Hanya tersedia dalam Bahasa Indonesia')),
                    );
                  },
                ),
              ],
            ),
            _buildMenuSection(
              'Bantuan & Informasi',
              [
                _buildMenuItem(
                  Icons.help_outline,
                  'Pusat Bantuan',
                  'FAQ dan panduan',
                  () => _showHelpCenter(),
                ),
                _buildMenuItem(
                  Icons.privacy_tip_outlined,
                  'Kebijakan Privasi',
                  'Lihat kebijakan privasi',
                  () => _showPrivacyPolicy(),
                ),
                _buildMenuItem(
                  Icons.description_outlined,
                  'Syarat & Ketentuan',
                  'Baca syarat penggunaan',
                  () => _showTermsConditions(),
                ),
                _buildMenuItem(
                  Icons.info_outline,
                  'Tentang IDEN',
                  'Versi 1.0.0',
                  () => _showAboutApp(),
                ),
                _buildMenuItem(
                  Icons.admin_panel_settings,
                  'Admin Panel',
                  'Akses panel admin',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text(
                    'Keluar',
                    style: TextStyle(color: AppColors.error),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
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
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: AppTextStyles.label.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
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
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchMenuItem(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 24),
      ),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textLight),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Close dialog first
                Navigator.pop(context);
                
                print('👋 Signing out user');
                final authService = AuthService();
                
                // Sign out from auth service
                await authService.signOut();
                print('✅ Sign out completed');
                
                // Navigate away from profile screen to root (OnboardingScreen)
                // The app will automatically route based on auth state in SplashScreen
                if (mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/',
                    (route) => false,
                  );
                }
              } catch (e) {
                print('❌ Sign out error: $e');
                // Show error only if context is still valid
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error keluar: $e')),
                  );
                }
              }
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final TextEditingController currentPasswordController = TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password Saat Ini',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password Baru',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final currentPassword = currentPasswordController.text.trim();
              final newPassword = newPasswordController.text.trim();
              final confirmPassword = confirmPasswordController.text.trim();

              if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Semua field harus diisi')),
                );
                return;
              }

              if (newPassword != confirmPassword) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password baru tidak cocok')),
                );
                return;
              }

              if (newPassword.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password minimal 6 karakter')),
                );
                return;
              }

              try {
                // Update password via Supabase Auth
                await _supabase.auth.updateUser(
                  UserAttributes(password: newPassword),
                );

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password berhasil diubah'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal mengubah password: $e')),
                  );
                }
              }
            },
            child: const Text('Ubah Password'),
          ),
        ],
      ),
    );
  }

  void _showEmailSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email & Notifikasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email terdaftar: $_userEmail'),
            const SizedBox(height: 16),
            const Text('Pengaturan Notifikasi Email:'),
            CheckboxListTile(
              title: const Text('Notifikasi Quiz'),
              subtitle: const Text('Terima reminder quiz'),
              value: true,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Artikel Baru'),
              subtitle: const Text('Info artikel terbaru'),
              value: true,
              onChanged: (value) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showHelpCenter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.help_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'Pusat Bantuan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  _buildFaqItem(
                    'Apa itu IDEN?',
                    'IDEN adalah aplikasi edukasi tentang bahaya narkotika dan pencegahan penyalahgunaan narkoba untuk remaja dan masyarakat umum.',
                  ),
                  _buildFaqItem(
                    'Bagaimana cara menggunakan aplikasi?',
                    'Anda bisa membaca artikel edukasi, mengikuti quiz penilaian risiko, dan menyimpan artikel favorit untuk dibaca kembali.',
                  ),
                  _buildFaqItem(
                    'Apakah quiz saya bersifat anonim?',
                    'Ya, hasil quiz Anda hanya dapat dilihat oleh Anda sendiri dan tidak dibagikan kepada pihak lain.',
                  ),
                  _buildFaqItem(
                    'Bagaimana cara menghubungi dukungan?',
                    'Anda bisa menghubungi kami melalui email support@iden.app atau langsung dari menu "Kontak Kami".',
                  ),
                  _buildFaqItem(
                    'Apakah data saya aman?',
                    'Ya, semua data Anda terenkripsi dan tersimpan dengan aman. Kami tidak membagikan informasi pribadi Anda kepada pihak ketiga.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.privacy_tip_outlined, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'Kebijakan Privasi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: const [
                  Text(
                    'Kebijakan Privasi IDEN',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '1. Pengumpulan Data\n\n'
                    'Kami mengumpulkan informasi yang Anda berikan saat mendaftar, termasuk nama, email, dan data profil lainnya.\n\n'
                    '2. Penggunaan Data\n\n'
                    'Data Anda digunakan untuk:\n'
                    '• Menyediakan dan meningkatkan layanan aplikasi\n'
                    '• Mengirimkan notifikasi dan pembaruan\n'
                    '• Menganalisis penggunaan aplikasi\n\n'
                    '3. Keamanan Data\n\n'
                    'Kami menggunakan enkripsi dan praktik keamanan terbaik untuk melindungi informasi Anda.\n\n'
                    '4. Berbagi Data\n\n'
                    'Kami tidak membagikan data pribadi Anda kepada pihak ketiga tanpa persetujuan Anda.\n\n'
                    '5. Hak Anda\n\n'
                    'Anda memiliki hak untuk mengakses, mengubah, atau menghapus data pribadi Anda kapan saja.\n\n'
                    '6. Perubahan Kebijakan\n\n'
                    'Kami dapat memperbarui kebijakan privasi ini dari waktu ke waktu. Perubahan akan diinformasikan melalui aplikasi.\n\n'
                    'Terakhir diperbarui: Desember 2025',
                    style: TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTermsConditions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, color: Colors.white),
                  const SizedBox(width: 12),
                  const Text(
                    'Syarat & Ketentuan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: const [
                  Text(
                    'Syarat & Ketentuan Penggunaan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '1. Penerimaan Syarat\n\n'
                    'Dengan menggunakan aplikasi IDEN, Anda setuju untuk mematuhi syarat dan ketentuan ini.\n\n'
                    '2. Penggunaan Aplikasi\n\n'
                    'Aplikasi ini ditujukan untuk tujuan edukasi dan pencegahan penyalahgunaan narkotika. Anda setuju untuk menggunakan aplikasi secara bertanggung jawab.\n\n'
                    '3. Akun Pengguna\n\n'
                    'Anda bertanggung jawab untuk menjaga kerahasiaan akun dan password Anda.\n\n'
                    '4. Konten\n\n'
                    'Konten dalam aplikasi disediakan untuk tujuan informasi dan edukasi. Kami berusaha untuk memastikan keakuratan informasi.\n\n'
                    '5. Larangan\n\n'
                    'Anda dilarang:\n'
                    '• Menyalahgunakan layanan atau konten\n'
                    '• Mengunggah konten yang melanggar hukum\n'
                    '• Mengakses akun orang lain tanpa izin\n\n'
                    '6. Penghentian Layanan\n\n'
                    'Kami berhak untuk menghentikan atau membatasi akses Anda jika melanggar syarat ini.\n\n'
                    '7. Perubahan Syarat\n\n'
                    'Kami dapat mengubah syarat dan ketentuan ini kapan saja dengan pemberitahuan kepada pengguna.\n\n'
                    'Terakhir diperbarui: Desember 2025',
                    style: TextStyle(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.info, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text('Tentang IDEN'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'IDEN - Informasi & Deteksi Narkotika',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text('Versi 1.0.0'),
            const SizedBox(height: 16),
            const Text(
              'Aplikasi edukasi untuk pencegahan penyalahgunaan narkotika di Indonesia.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.copyright, size: 16, color: AppColors.textLight),
                SizedBox(width: 8),
                Text(
                  '2025 IDEN App',
                  style: TextStyle(color: AppColors.textLight),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                Icon(Icons.email, size: 16, color: AppColors.textLight),
                SizedBox(width: 8),
                Text(
                  'support@iden.app',
                  style: TextStyle(color: AppColors.textLight),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
