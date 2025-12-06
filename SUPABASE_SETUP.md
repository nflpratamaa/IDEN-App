# Setup Supabase untuk IDEN App

## 📋 Langkah-langkah Setup

### 1. Buat Project Supabase
1. Buka [https://supabase.com](https://supabase.com)
2. Sign up / Login
3. Klik "New Project"
4. Isi:
   - **Name**: IDEN-App
   - **Database Password**: (simpan password ini!)
   - **Region**: Southeast Asia (Singapore)
5. Tunggu setup selesai (~2 menit)

### 2. Jalankan SQL Schema
1. Di dashboard Supabase, buka **SQL Editor**
2. Klik **New Query**
3. Copy semua isi file `supabase_schema.sql`
4. Paste ke SQL Editor
5. Klik **Run** (atau tekan Ctrl+Enter)
6. Pastikan semua query berhasil (hijau ✓)

### 3. Dapatkan API Credentials
1. Di dashboard, buka **Project Settings** > **API**
2. Copy informasi berikut:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon/public key**: `eyJhbGc...` (token panjang)

### 4. Konfigurasi di Flutter App
1. Buka file `lib/config/supabase_config.dart`
2. Ganti nilai:
```dart
static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
static const String supabaseAnonKey = 'YOUR_ANON_KEY_HERE';
```

### 5. Verifikasi Setup
Cek di **Table Editor** bahwa semua tabel sudah dibuat:
- ✅ users
- ✅ drugs (dengan sample data)
- ✅ articles (dengan sample data)
- ✅ quizzes (dengan sample data)
- ✅ quiz_results
- ✅ emergency_contacts (dengan sample data)

## 🔐 Authentication Setup

### Enable Email Auth
1. Buka **Authentication** > **Providers**
2. Enable **Email** provider
3. Konfigurasi email templates (opsional)

### Disable Email Confirmation (untuk development)
1. Buka **Authentication** > **Settings**
2. Scroll ke **Email Auth**
3. **Disable** "Enable email confirmations"
   > ⚠️ Untuk production, harus enable!

## 📊 Database Schema Overview

### Tables:
1. **users** - Extended user profiles dari auth.users
2. **drugs** - Katalog narkotika dengan info lengkap
3. **articles** - Artikel edukasi tentang narkoba
4. **quizzes** - Pertanyaan quiz assessment
5. **quiz_results** - Hasil quiz per user
6. **emergency_contacts** - Kontak hotline & rehab

### Row Level Security (RLS):
- ✅ Sudah dikonfigurasi untuk semua tabel
- Users hanya bisa lihat data mereka sendiri
- Data public (drugs, articles) bisa diakses semua orang
- Admin operations butuh authentication

## 🧪 Testing Database

### Test Query di SQL Editor:
```sql
-- Cek drugs
SELECT * FROM drugs;

-- Cek articles
SELECT * FROM articles;

-- Cek quiz questions
SELECT * FROM quizzes ORDER BY order_index;

-- Cek emergency contacts
SELECT * FROM emergency_contacts;
```

## 🚀 Selanjutnya

Setelah setup Supabase selesai:
1. ✅ Run `flutter pub get` (sudah dilakukan)
2. ✅ Update `supabase_config.dart` dengan credentials
3. 🔄 Integrate auth screens dengan AuthService
4. 🔄 Test login/register functionality
5. 🔄 Connect UI screens dengan services

## 📝 Notes

- **Development**: Gunakan anon key untuk client-side
- **Production**: Jangan commit credentials ke git!
  - Gunakan environment variables atau `.env` file
  - Tambahkan `supabase_config.dart` ke `.gitignore`

## 🆘 Troubleshooting

### Error: "Invalid API key"
- Pastikan URL dan anon key sudah benar
- Copy ulang dari dashboard (jangan ada spasi)

### Error: "Row Level Security"
- Cek policies sudah dibuat dengan benar
- Untuk testing, bisa temporary disable RLS

### Error: "Connection refused"
- Cek internet connection
- Pastikan project Supabase tidak dalam status paused

## 🔗 Useful Links

- [Supabase Docs](https://supabase.com/docs)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
- [RLS Guide](https://supabase.com/docs/guides/auth/row-level-security)
