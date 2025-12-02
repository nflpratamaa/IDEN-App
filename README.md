# IDEN - Indeks Risiko & Edukasi Narkotika

Aplikasi mobile edukasi dan assessment risiko penyalahgunaan narkotika berbasis Flutter.

## 🎯 Tujuan Proyek

Menyediakan platform yang reliable untuk:
- Edukasi tentang bahaya narkotika
- Penilaian risiko anonim
- Akses mudah ke pusat bantuan dan rehabilitasi

## ✨ Fitur Utama

### 1. Katalog Informasi Narkotika
- Daftar lengkap jenis-jenis narkotika
- Kategori (Stimulan, Depresan, Halusinogen)
- Informasi detail tentang:
  - Nama lain/street names
  - Efek jangka pendek dan panjang
  - Tanda-tanda penggunaan
  - Tingkat risiko dan kecanduan
  - Langkah-langkah bantuan

### 2. Quiz Penilaian Risiko
- Kuis anonim dengan 5 pertanyaan
- Penilaian berbasis skor
- Hasil dengan visualisasi:
  - Tingkat risiko (Rendah/Sedang/Tinggi)
  - Rincian skor (Frekuensi, Dampak Kesehatan, Ketergantungan)
  - Rekomendasi tindakan

### 3. Pusat Bantuan
- Hotline darurat 24/7
- Informasi pusat rehabilitasi
- Layanan konseling online
- Kelompok dukungan
- Semua layanan bersifat anonim dan rahasia

## 📱 Screens Overview

### User Screens (11 total)
1. **Splash** - Logo loading (100ms)
2. **Onboarding** - 3 slides pengenalan fitur
3. **Login** - Autentikasi user
4. **Register** - Pendaftaran akun
5. **Home** - Dashboard dengan 4 tabs (Beranda, Katalog, Riwayat, Profil)
6. **Catalog** - Daftar narkotika dengan search & filter
7. **Detail** - Info lengkap narkotika (Deskripsi, Efek, Bahaya)
8. **Quiz** - Assessment risiko interaktif
9. **Result** - Hasil quiz dengan visualisasi & rekomendasi
10. **Help Center** - FAQ & kontak darurat
11. **Profile** - Settings & info akun user

### Admin Screens (6 total)
1. **Admin Login** - Autentikasi admin (demo: `admin`/`admin123`)
2. **Dashboard** - Statistik overview (users, articles, quizzes, daily access)
3. **Content Management** - CRUD artikel & katalog narkotika
4. **User Management** - Kelola user (block/unblock, view activity)
5. **Quiz Management** - CRUD quiz questions dengan bobot
6. **Emergency Management** - CRUD kontak darurat

## 🎨 Design System

### Color Palette
- **Primary**: Navy `#000080` - Warna utama profesional
- **Accent**: `#D4936D` - Warna tan/coklat untuk highlight
- **Risk Levels**:
  - Rendah: `#4CAF50` (hijau)
  - Sedang: `#FF9800` (orange)
  - Tinggi: `#FF5252` (merah)
  - Ekstrem: `#D32F2F` (merah tua)

### Typography
- Font Family: Roboto
- Headings: Bold 32/24/20/18/16 (h1-h5)
- Body: Regular/Medium 16/14/12

## 🏗️ Struktur Folder

```
lib/
├── constants/           # Konstanta global
│   ├── app_colors.dart      # Palet warna (Navy #000080, risk levels)
│   └── app_text_styles.dart # Typography system (h1-h5, body)
│
├── models/             # Data models untuk database
│   ├── user_model.dart       # Model User (id, name, email, stats)
│   ├── drug_model.dart       # Model Drug/Narkotika (name, effects, dangers)
│   ├── article_model.dart    # Model Artikel (title, content, author)
│   └── quiz_model.dart       # Model Quiz & Result (questions, score)
│
├── screens/            # UI Screens
│   ├── onboarding/          # Onboarding flow
│   │   ├── splash_screen.dart       # Splash screen (100ms)
│   │   └── onboarding_screen.dart   # 3 slides pengenalan
│   │
│   ├── auth/               # Authentication
│   │   ├── login_screen.dart        # Login form
│   │   └── register_screen.dart     # Register form
│   │
│   ├── main/               # Main app screens
│   │   ├── home_screen.dart         # Home dengan bottom nav (4 tabs)
│   │   ├── catalog_screen.dart      # List narkotika dengan filter
│   │   ├── detail_screen.dart       # Detail info narkotika
│   │   ├── quiz_screen.dart         # Assessment quiz
│   │   ├── result_screen.dart       # Hasil quiz & rekomendasi
│   │   ├── help_center_screen.dart  # FAQ & kontak darurat
│   │   ├── profile_screen.dart      # Profil & settings user
│   │   └── history_screen.dart      # Riwayat quiz & artikel
│   │
│   └── admin/              # Admin panel
│       ├── admin_login_screen.dart         # Login admin
│       ├── admin_dashboard_screen.dart     # Dashboard statistik
│       ├── content_management_screen.dart  # Kelola artikel & katalog
│       ├── user_management_screen.dart     # Kelola user
│       ├── quiz_management_screen.dart     # Kelola quiz questions
│       └── emergency_management_screen.dart # Kelola kontak darurat
│
├── services/           # Business logic & API
│   └── (kosong - untuk integrasi Hive & API)
│
├── widgets/            # Reusable widgets
│   └── (kosong - untuk custom widgets)
│
├── utils/              # Helper functions
│   └── (kosong - untuk validators, formatters)
│
└── main.dart           # Entry point app
```

## 📦 Models Explained

### Perbedaan Screen vs Model:

- **Screen/View**: UI yang dilihat user (tampilan visual)
- **Model**: Struktur data/objek untuk menyimpan informasi di database

**ANALOGI:**
- Screen = **Formulir kertas** yang kamu lihat
- Model = **Data yang kamu tulis** di formulir (nama, alamat, dll)

### Kapan Model Digunakan:

Model saat ini kosong karena **belum ada database**. Ketika nanti integrasi **Hive** (database lokal), model akan digunakan untuk:

1. **UserModel** - Menyimpan data akun user
   ```dart
   UserModel user = UserModel(
     id: '123',
     name: 'Budi',
     email: 'budi@example.com',
     quizzesTaken: 5,
   );
   ```

2. **DrugModel** - Menyimpan info narkotika
   ```dart
   DrugModel drug = DrugModel(
     id: '1',
     name: 'Ganja',
     riskLevel: 'high',
     effects: ['Halusinasi', 'Euforia'],
   );
   ```

3. **ArticleModel** - Menyimpan artikel edukasi
4. **QuizModel** - Menyimpan pertanyaan & hasil quiz

### Cara Kerja dengan Database:

```dart
// 1. Simpan ke database
await userBox.put(user.id, user.toMap());

// 2. Ambil dari database
Map data = userBox.get('123');
UserModel user = UserModel.fromMap(data);

// 3. Update data
UserModel updated = user.copyWith(quizzesTaken: 6);
await userBox.put(user.id, updated.toMap());
```

## 📝 Dokumentasi Kode

Setiap file sudah dilengkapi dengan **header comment** yang menjelaskan:
- Fungsi file
- Fitur utama
- Dependencies/imports yang dibutuhkan

Contoh:
```dart
/// Login Screen - Layar autentikasi user
/// Form login dengan email & password, validasi input
/// Setelah login berhasil, masuk ke Home Screen
```

```

## 🚀 Cara Menjalankan

1. Pastikan Flutter sudah terinstall
```bash
flutter --version
```

2. Clone/navigasi ke project folder
```bash
cd "d:\Kodingan\Semester 5\projek pem mob\iden_app"
```

3. Install dependencies
```bash
flutter pub get
```

4. Run aplikasi
```bash
flutter run
```

## 🔐 Admin Credentials (Demo)

- **Username**: `admin`
- **Password**: `admin123`

## 📝 Rencana Pengembangan Selanjutnya

### Phase 1: Database Integration (Next)
- [ ] Setup Hive database
  ```yaml
  dependencies:
    hive: ^2.2.3
    hive_flutter: ^1.1.0
  ```
- [ ] Initialize Hive di `main.dart`
  ```dart
  await Hive.initFlutter();
  await Hive.openBox('users');
  await Hive.openBox('drugs');
  await Hive.openBox('articles');
  await Hive.openBox('quizzes');
  ```
- [ ] Create Service layer untuk business logic
  ```dart
  class UserService {
    Box userBox = Hive.box('users');
    
    Future<void> saveUser(UserModel user) async {
      await userBox.put(user.id, user.toMap());
    }
  }
  ```
- [ ] Seed initial data (drugs, articles, quiz questions)

### Phase 2: Advanced Features
- [ ] Search functionality dengan debounce
- [ ] Filter berdasarkan kategori dan risk level
- [ ] Bookmark/save functionality dengan persistent storage
- [ ] History penilaian risiko user
- [ ] Profile management (edit nama, email, photo)

### Phase 3: Enhancement
- [ ] Animasi dan transisi smooth
- [ ] Offline mode (data cached)
- [ ] Push notifikasi untuk reminder
- [ ] Multi-language support (EN/ID)
- [ ] Export hasil quiz ke PDF

## 🎓 Tantangan Pembelajaran

1. **Manajemen Data Hierarkis**: 
   - Kategori → Jenis Narkotika → Detail
   - Menggunakan Hive untuk local storage
   - Relasi antar models (User → Quiz Results)

2. **State Management**:
   - Quiz logic dan scoring algorithm
   - Navigation flow dengan callback pattern
   - User preferences dan session management

3. **UI/UX Design**:
   - Desain yang sensitif dan professional
   - Non-judgmental approach
   - Accessibility considerations
   - Responsive layout untuk berbagai screen size

## 📊 Project Statistics

- **Total Files**: 32
  - 25 Screens (11 user + 6 admin + 8 shared)
  - 4 Models (User, Drug, Article, Quiz)
  - 2 Constants (Colors, TextStyles)
  - 1 Main entry point
- **Lines of Code**: ~3500+ LOC
- **Flutter SDK**: 3.9.2+
- **Last Updated**: December 2, 2025

## 📄 License

Educational project for Mobile Programming course.

## 👥 Contributors

Project Semester 5 - Mobile Programming

---

**Note**: Aplikasi ini dibuat untuk tujuan edukasi dan awareness. Untuk kasus darurat atau konsultasi serius, selalu hubungi profesional kesehatan atau hotline yang tersedia.
