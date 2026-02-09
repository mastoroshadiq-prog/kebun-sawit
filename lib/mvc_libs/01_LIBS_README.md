# Dokumentasi MVC Libs

## 📋 Overview

Folder `mvc_libs` berisi library dan utility classes yang digunakan di seluruh aplikasi untuk fungsi-fungsi umum seperti koneksi internet, error handling, dan utility lainnya.

**Current Files:**
1. `connection_utils.dart` - Utility untuk cek koneksi dan parsing error

---

## 🛠️ ConnectionUtils

**File:** `connection_utils.dart`  
**Class:** `ConnectionUtils`

Class ini menyediakan fungsi-fungsi statis dan instance methods untuk menangani koneksi jaringan dan formatting pesan error dari database atau API.

### Methods

| Method | Type | Return | Description |
|--------|------|--------|-------------|
| `checkConnection()` | `static Future` | `bool` | Cek koneksi internet (ping google.com) |
| `parseSqlError(String message)` | `Instance` | `String` | Parse pesan error SQL menjadi user-friendly message |
| `handleErrorStatus(String errorCode)` | `Instance` | `String` | Convert error code menjadi pesan bahasa Indonesia |

### 1. checkConnection

Mengecek apakah perangkat terhubung ke internet dengan cara melakukan ping ke `google.com`.

```dart
bool isConnected = await ConnectionUtils.checkConnection();
if (isConnected) {
  // Lanjut proses online
} else {
  // Tampilkan pesan offline
}
```

### 2. parseSqlError

Mengambil pesan error mentah (biasanya dari exception database) dan mengekstrak informasi penting seperti error code atau nama tabel, kemudian mengembalikan pesan yang lebih mudah dibaca.

**Logic:**
1. Mencari Error Code (regex: `Error Code:\s*(\d+)` atau `errno\s*=\s*(\d+)`)
2. Mencari Nama Tabel (regex: `INSERT INTO\s+([A-Za-z0-9_.]+)`)
3. Mengembalikan pesan error yang diformat

```dart
try {
  // Database operation
} catch (e) {
  final utils = ConnectionUtils();
  String friendlyError = utils.parseSqlError(e.toString());
  print(friendlyError);
}
```

### 3. handleErrorStatus

Mengubah kode status HTTP atau custom error code menjadi pesan yang mudah dimengerti user dalam Bahasa Indonesia.

**Daftar Kode Status:**

| Code | Pesan |
|------|-------|
| 200 | Berhasil diproses. |
| 201 | Data berhasil dibuat. |
| 204 | Tidak ada data. |
| 400 | Permintaan tidak valid. |
| 401 | Silakan login kembali. |
| 403 | Akses ditolak. |
| 404 | Data tidak ditemukan. |
| 408 | Koneksi timeout. |
| 409 | Data bentrok / duplikat. |
| 500 | Terjadi kesalahan di server. |
| 503 | Server sedang sibuk. |
| ... | (dan kode lainnya) |

```dart
String message = ConnectionUtils().handleErrorStatus("404");
// Output: "Data tidak ditemukan."
```

---

## ⚠️ Dependencies

Library ini bergantung pada package berikut:
- `connectivity_plus`: Untuk cek status koneksi jaringan
- `dart:io`: Untuk `InternetAddress.lookup`

Pastikan dependencies ini ada di `pubspec.yaml`.
