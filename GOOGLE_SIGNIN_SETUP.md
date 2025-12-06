# Setup Google Sign In untuk IDEN App

## 🔐 Konfigurasi Google OAuth

### 1. Buat Google OAuth Client ID

1. Buka [Google Cloud Console](https://console.cloud.google.com/)
2. Buat project baru atau pilih project existing
3. Enable **Google+ API**:
   - APIs & Services > Library
   - Cari "Google+ API"
   - Klik "Enable"

4. Buat OAuth 2.0 Credentials:
   - APIs & Services > Credentials
   - Click "Create Credentials" > "OAuth 2.0 Client ID"
   
5. Configure OAuth consent screen (jika belum):
   - User Type: **External**
   - App name: **IDEN App**
   - Support email: (email kamu)
   - Authorized domains: (optional untuk testing)
   - Save

### 2. Buat Client ID untuk Web

1. Application type: **Web application**
2. Name: **IDEN Web App**
3. Authorized JavaScript origins:
   ```
   http://localhost
   http://localhost:8080
   ```
4. Authorized redirect URIs:
   ```
   http://localhost
   https://YOUR_PROJECT.supabase.co/auth/v1/callback
   ```
5. **Create** dan copy **Client ID**

Format: `xxxxx-xxxxxxx.apps.googleusercontent.com`

### 3. Konfigurasi di Supabase

1. Buka Supabase Dashboard > Authentication > Providers
2. Cari **Google** provider
3. Enable **Google**
4. Masukkan:
   - **Client ID**: (dari step 2)
   - **Client Secret**: (dari Google Console > Credentials)
5. Copy **Redirect URL** dari Supabase
6. Paste ke Google Console > Authorized redirect URIs
7. **Save**

### 4. Update Flutter App

Edit `lib/screens/auth/login_screen.dart`:

```dart
final GoogleSignIn googleSignIn = GoogleSignIn(
  clientId: 'YOUR_GOOGLE_CLIENT_ID.apps.googleusercontent.com', // <<<< GANTI INI
);
```

Ganti `YOUR_GOOGLE_CLIENT_ID` dengan Client ID dari Google Console.

## 🧪 Testing Google Sign In

### Web (Chrome)
```bash
flutter run -d chrome
```
- Buka login screen
- Klik "Masuk dengan Google"
- Pilih akun Google
- Allow permissions
- Should redirect ke Home Screen ✅

### Android (Future)
Perlu setup tambahan:
1. SHA-1 fingerprint
2. Download `google-services.json`
3. Configure `android/app/build.gradle`

### iOS (Future)
Perlu setup:
1. Download `GoogleService-Info.plist`
2. Configure URL schemes
3. Update `Info.plist`

## ⚠️ Troubleshooting

### Error: "Access blocked"
- Pastikan email kamu di OAuth consent screen > Test users
- Atau publish app (bukan testing mode)

### Error: "Redirect URI mismatch"
- Cek authorized redirect URIs di Google Console
- Pastikan match dengan Supabase redirect URL

### Error: "Invalid client"
- Client ID salah
- Copy ulang dari Google Console

## 📝 Notes

**Development:**
- Google Sign In hanya work di web (Chrome) untuk sekarang
- Untuk Android/iOS perlu setup platform-specific

**Production:**
- Verify domain di Google Console
- Publish OAuth consent screen
- Update authorized domains

**Security:**
- Client ID bisa di-commit (public)
- **JANGAN** commit Client Secret ke git!

## 🔗 References

- [Supabase Google OAuth Guide](https://supabase.com/docs/guides/auth/social-login/auth-google)
- [Flutter Google Sign In](https://pub.dev/packages/google_sign_in)
- [Google OAuth Setup](https://developers.google.com/identity/protocols/oauth2)
