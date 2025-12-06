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

      if (mounted) {
        setState(() {
          _userName = userData['name'] ?? 'Pengguna IDEN';
          _userEmail = userData['email'] ?? user.email ?? 'user@iden.com';
          _profileImageUrl = userData['profile_image_url'];
          _quizzesTaken = userData['quizzesTaken'] ?? 0;
          _articlesRead = userData['articlesRead'] ?? 0;
          _savedItems = userData['savedItems'] ?? 0;
          _isLoading = false;
        });
        print('✅ Profile loaded successfully');
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur Edit Profil coming soon')),
              );
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
                  () {},
                ),
                _buildMenuItem(
                  Icons.email_outlined,
                  'Email & Notifikasi',
                  'Kelola preferensi email',
                  () {},
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
                  () {},
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
                  () {},
                ),
                _buildMenuItem(
                  Icons.privacy_tip_outlined,
                  'Kebijakan Privasi',
                  'Lihat kebijakan privasi',
                  () {},
                ),
                _buildMenuItem(
                  Icons.description_outlined,
                  'Syarat & Ketentuan',
                  'Baca syarat penggunaan',
                  () {},
                ),
                _buildMenuItem(
                  Icons.info_outline,
                  'Tentang IDEN',
                  'Versi 1.0.0',
                  () {},
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
}
