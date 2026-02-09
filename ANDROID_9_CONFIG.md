# Konfigurasi Android 9 (Pie) - Project Perkebunan Sawit

## Ringkasan Perubahan

Project ini telah dikonfigurasi untuk mendukung Android 9 (API level 28 - Pie) sebagai versi minimum.

## Perubahan yang Dilakukan

### 1. **build.gradle.kts** (`android/app/build.gradle.kts`)
- **minSdk**: Diset ke `28` (Android 9 Pie)
- **targetSdk**: Diset ke `34` (Android 14)
- **compileSdk**: Diset ke `34`

### 2. **AndroidManifest.xml** (`android/app/src/main/AndroidManifest.xml`)
- Menambahkan permission `INTERNET`
- Menambahkan `android:networkSecurityConfig` untuk keamanan jaringan
- Menambahkan `android:usesCleartextTraffic="false"` untuk memblokir HTTP secara default

### 3. **Network Security Config** (`android/app/src/main/res/xml/network_security_config.xml`)
File baru yang mengatur kebijakan keamanan jaringan:
- Secara default hanya mengizinkan HTTPS
- Menyediakan opsi untuk mengizinkan HTTP pada domain tertentu (untuk development)

## Fitur Android 9 yang Perlu Diperhatikan

### 1. **Cleartext Traffic (HTTP)**
Android 9 secara default memblokir koneksi HTTP yang tidak terenkripsi. Jika aplikasi Anda perlu menggunakan HTTP:

**Untuk Development/Testing:**
Edit `network_security_config.xml` dan uncomment bagian `domain-config`:
```xml
<domain-config cleartextTrafficPermitted="true">
    <domain includeSubdomains="true">localhost</domain>
    <domain includeSubdomains="true">10.0.2.2</domain>
    <domain includeSubdomains="true">your-api-domain.com</domain>
</domain-config>
```

**Untuk Production:**
Gunakan HTTPS untuk semua koneksi jaringan (recommended).

### 2. **Notch/Display Cutout Support**
Android 9 memperkenalkan dukungan untuk layar dengan notch. Jika diperlukan, tambahkan:
```xml
<meta-data
    android:name="android.max_aspect"
    android:value="2.1" />
```

### 3. **Power Management**
Android 9 memiliki pembatasan background yang lebih ketat. Pastikan:
- Gunakan WorkManager untuk background tasks
- Implementasikan foreground services dengan benar jika diperlukan

### 4. **Privacy Changes**
- Akses ke sensor dibatasi saat aplikasi di background
- Build serial number memerlukan permission khusus
- MAC address tidak bisa diakses langsung

## Testing

### Menjalankan di Emulator Android 9:
1. Buka Android Studio
2. AVD Manager → Create Virtual Device
3. Pilih device dan system image **Pie (API 28)**
4. Jalankan: `flutter run`

### Menjalankan di Device Fisik:
Pastikan device Anda menjalankan Android 9 atau lebih tinggi.

## Build APK/AAB

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Android App Bundle (untuk Google Play)
flutter build appbundle --release
```

## Troubleshooting

### Error: "Cleartext HTTP traffic not permitted"
**Solusi:** Edit `network_security_config.xml` dan izinkan domain yang diperlukan, atau gunakan HTTPS.

### Error: "Installation failed with message INSTALL_FAILED_OLDER_SDK"
**Solusi:** Pastikan device/emulator Anda menjalankan Android 9 (API 28) atau lebih tinggi.

### Error: "Execution failed for task ':app:processDebugManifest'"
**Solusi:** Clean dan rebuild project:
```bash
flutter clean
flutter pub get
flutter build apk
```

## Kompatibilitas

- **Minimum**: Android 9 (API 28) - Pie
- **Target**: Android 14 (API 34)
- **Tested on**: Android 9, 10, 11, 12, 13, 14

## Referensi

- [Android 9 Behavior Changes](https://developer.android.com/about/versions/pie/android-9.0-changes-all)
- [Network Security Configuration](https://developer.android.com/training/articles/security-config)
- [Flutter Android Setup](https://docs.flutter.dev/deployment/android)

---
**Terakhir diupdate:** 12 Desember 2025
