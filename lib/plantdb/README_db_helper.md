# Dokumentasi DBHelper - Database Helper untuk Aplikasi Kebun Sawit

## 📋 Overview

`DBHelper` adalah class singleton yang mengelola database SQLite lokal untuk aplikasi manajemen kebun sawit. Database ini menyimpan data master, data operasional, dan audit log untuk tracking aktivitas di lapangan.

**Database Name:** `plantdb.db`  
**Database Version:** 1  
**Pattern:** Singleton Pattern

---

## 🏗️ Struktur Database

Database terdiri dari **8 tabel** yang dikelompokkan menjadi:
- **Data Master** (3 tabel): `pohon`, `assignment`, `petugas`
- **Data Operasional** (4 tabel): `eksekusi`, `reposisi`, `kesehatan`, `riwayat`
- **Audit & Logging** (1 tabel): `auditlog`

---

## 📊 Schema Tabel

### 1. Tabel `pohon` - Data Pohon Sawit

Menyimpan informasi master pohon kelapa sawit di kebun.

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `blok` | TEXT | Kode blok kebun |
| `nbaris` | TEXT | Nomor baris pohon |
| `npohon` | TEXT | Nomor pohon |
| `objectId` | TEXT | **PRIMARY KEY** - ID unik pohon |
| `status` | TEXT | Status pohon (sehat/sakit/mati) |
| `nflag` | TEXT | Flag untuk sinkronisasi |

**Contoh Data:**
```dart
{
  'blok': 'A1',
  'nbaris': '05',
  'npohon': '123',
  'objectId': 'POH-A1-05-123',
  'status': 'sehat',
  'nflag': '0'
}
```

---

### 2. Tabel `assignment` - Penugasan Petugas

Menyimpan data penugasan pekerjaan kepada petugas lapangan.

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | TEXT | **PRIMARY KEY** - ID penugasan |
| `spkNumber` | TEXT | Nomor SPK (Surat Perintah Kerja) |
| `taskName` | TEXT | Nama tugas |
| `estate` | TEXT | Nama estate/kebun |
| `division` | TEXT | Divisi |
| `block` | TEXT | Blok yang ditugaskan |
| `rowNumber` | TEXT | Nomor baris |
| `treeNumber` | TEXT | Nomor pohon |
| `petugas` | TEXT | ID petugas yang ditugaskan |

**Contoh Data:**
```dart
{
  'id': 'ASG-001',
  'spkNumber': 'SPK/2024/001',
  'taskName': 'Pemupukan',
  'estate': 'Kebun Raya',
  'division': 'Divisi 1',
  'block': 'A1',
  'rowNumber': '05',
  'treeNumber': '123',
  'petugas': 'PTG-001'
}
```

---

### 3. Tabel `eksekusi` - Eksekusi Tugas

Menyimpan data pelaksanaan tugas oleh petugas.

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | TEXT | **PRIMARY KEY** - ID eksekusi |
| `spkNumber` | TEXT | Nomor SPK |
| `taskName` | TEXT | Nama tugas |
| `taskState` | TEXT | Status tugas (pending/completed/cancelled) |
| `petugas` | TEXT | ID petugas |
| `taskDate` | TEXT | Tanggal pelaksanaan |
| `keterangan` | TEXT | Catatan/keterangan |
| `imagePath` | TEXT | Path foto bukti pelaksanaan |
| `flag` | INTEGER | Flag sinkronisasi (0=belum, 1=sudah) |

**Contoh Data:**
```dart
{
  'id': 'EKS-001',
  'spkNumber': 'SPK/2024/001',
  'taskName': 'Pemupukan',
  'taskState': 'completed',
  'petugas': 'PTG-001',
  'taskDate': '2024-12-12',
  'keterangan': 'Pemupukan NPK selesai',
  'imagePath': '/storage/images/eks_001.jpg',
  'flag': 0
}
```

---

### 4. Tabel `riwayat` - Riwayat Pohon

Menyimpan riwayat aktivitas pada pohon tertentu.

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | TEXT | **PRIMARY KEY** - ID riwayat |
| `objectId` | TEXT | ID pohon (foreign key ke tabel pohon) |
| `tanggal` | TEXT | Tanggal aktivitas |
| `jenis` | TEXT | Jenis aktivitas |
| `keterangan` | TEXT | Detail aktivitas |

**Contoh Data:**
```dart
{
  'id': 'RIW-001',
  'objectId': 'POH-A1-05-123',
  'tanggal': '2024-12-12',
  'jenis': 'Pemupukan',
  'keterangan': 'Pemupukan NPK 15-15-15'
}
```

---

### 5. Tabel `reposisi` - Reposisi Pohon

Menyimpan data perpindahan/reposisi pohon dari satu lokasi ke lokasi lain.

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `idReposisi` | TEXT | **PRIMARY KEY** - ID reposisi |
| `idTanaman` | TEXT | ID pohon yang direposisi |
| `pohonAwal` | TEXT | Nomor pohon awal |
| `barisAwal` | TEXT | Nomor baris awal |
| `pohonTujuan` | TEXT | Nomor pohon tujuan |
| `barisTujuan` | TEXT | Nomor baris tujuan |
| `keterangan` | TEXT | Alasan reposisi |
| `tipeRiwayat` | TEXT | Tipe riwayat |
| `petugas` | TEXT | ID petugas yang melakukan |
| `flag` | INTEGER | Flag sinkronisasi (0=belum, 1=sudah) |

**Contoh Data:**
```dart
{
  'idReposisi': 'REP-001',
  'idTanaman': 'POH-A1-05-123',
  'pohonAwal': '123',
  'barisAwal': '05',
  'pohonTujuan': '124',
  'barisTujuan': '06',
  'keterangan': 'Pohon dipindahkan karena lahan rusak',
  'tipeRiwayat': 'Reposisi',
  'petugas': 'PTG-001',
  'flag': 0
}
```

---

### 6. Tabel `kesehatan` - Status Kesehatan Pohon

Menyimpan perubahan status kesehatan pohon.

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `idKesehatan` | TEXT | **PRIMARY KEY** - ID kesehatan |
| `idTanaman` | TEXT | ID pohon |
| `statusAwal` | TEXT | Status awal |
| `statusAkhir` | TEXT | Status akhir |
| `kodeStatus` | TEXT | Kode status |
| `jenisPohon` | TEXT | Jenis pohon |
| `keterangan` | TEXT | Catatan perubahan |
| `petugas` | TEXT | ID petugas |
| `fromDate` | TEXT | Tanggal mulai status |
| `thruDate` | TEXT | Tanggal akhir status |
| `flag` | INTEGER | Flag sinkronisasi (0=belum, 1=sudah) |

**Contoh Data:**
```dart
{
  'idKesehatan': 'KES-001',
  'idTanaman': 'POH-A1-05-123',
  'statusAwal': 'sehat',
  'statusAkhir': 'sakit',
  'kodeStatus': 'S01',
  'jenisPohon': 'Kelapa Sawit',
  'keterangan': 'Terserang hama',
  'petugas': 'PTG-001',
  'fromDate': '2024-12-12',
  'thruDate': null,
  'flag': 0
}
```

---

### 7. Tabel `petugas` - Data Petugas

Menyimpan informasi petugas lapangan.

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `akun` | TEXT | **PRIMARY KEY** - Username/ID akun |
| `nama` | TEXT | Nama lengkap petugas |
| `kontak` | TEXT | Nomor kontak |
| `peran` | TEXT | Peran/jabatan |
| `lastSync` | TEXT | Waktu sinkronisasi terakhir |

**Contoh Data:**
```dart
{
  'akun': 'PTG-001',
  'nama': 'Budi Santoso',
  'kontak': '081234567890',
  'peran': 'Mandor',
  'lastSync': '2024-12-12 15:30:00'
}
```

---

### 8. Tabel `auditlog` - Audit Log

Menyimpan log aktivitas pengguna untuk audit trail.

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id_audit` | TEXT | **PRIMARY KEY** - ID audit |
| `user_id` | TEXT | ID user yang melakukan aksi |
| `action` | TEXT | Jenis aksi (INSERT/UPDATE/DELETE) |
| `detail` | TEXT | Detail aksi dalam format JSON |
| `log_date` | TEXT | Tanggal dan waktu aksi |
| `device` | TEXT | Informasi device |
| `flag` | INTEGER | Flag sinkronisasi (0=belum, 1=sudah) |

**Contoh Data:**
```dart
{
  'id_audit': 'AUD-001',
  'user_id': 'PTG-001',
  'action': 'INSERT',
  'detail': '{"table":"eksekusi","id":"EKS-001"}',
  'log_date': '2024-12-12 15:30:00',
  'device': 'Android 9 - Samsung A10',
  'flag': 0
}
```

---

## 🔧 Method & Fungsi

### 1. Singleton Pattern

```dart
static final DBHelper _instance = DBHelper._internal();
factory DBHelper() => _instance;
DBHelper._internal();
```

**Penjelasan:** Memastikan hanya ada satu instance DBHelper di seluruh aplikasi.

---

### 2. `get database` - Mendapatkan Instance Database

```dart
Future<Database> get database async {
  if (_database != null) return _database!;
  _database = await _initDB();
  return _database!;
}
```

**Return:** `Future<Database>`  
**Fungsi:** Mengembalikan instance database, jika belum ada maka akan diinisialisasi terlebih dahulu.

**Contoh Penggunaan:**
```dart
final db = await DBHelper().database;
```

---

### 3. `_initDB()` - Inisialisasi Database

```dart
Future<Database> _initDB() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'plantdb.db');
  
  return await openDatabase(
    path,
    version: 1,
    onCreate: _onCreate,
  );
}
```

**Return:** `Future<Database>`  
**Fungsi:** Membuat atau membuka database `plantdb.db` dengan versi 1.

---

### 4. `inisiasiDB()` - Inisialisasi Manual Database

```dart
Future<Database> inisiasiDB() async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, 'plantdb.db');
  return await openDatabase(
    path,
    version: 1,
    onCreate: _onCreate,
  );
}
```

**Return:** `Future<Database>`  
**Fungsi:** Alternatif method untuk inisialisasi database secara manual.

**Contoh Penggunaan:**
```dart
final db = await DBHelper().inisiasiDB();
```

---

### 5. `_onCreate()` - Membuat Tabel

```dart
Future _onCreate(Database db, int version) async {
  // Membuat 8 tabel
}
```

**Parameter:**
- `db`: Instance database
- `version`: Versi database

**Fungsi:** Dipanggil saat database pertama kali dibuat. Membuat semua tabel yang diperlukan.

---

### 6. `cleanDatabaseAfterLogin()` - Bersihkan Database Setelah Login

```dart
Future<void> cleanDatabaseAfterLogin() async {
  final db = await database;
  await _cleanDataMaster(db);
  await _cleanDataOperasionalFlag1(db);
}
```

**Return:** `Future<void>`  
**Fungsi:** Membersihkan database setelah login untuk memastikan data fresh dari server.

**Contoh Penggunaan:**
```dart
await DBHelper().cleanDatabaseAfterLogin();
```

---

### 7. `_cleanDataMaster()` - Hapus Data Master

```dart
Future<void> _cleanDataMaster(Database db) async {
  final List<String> masterTables = [
    'petugas',
    'pohon',
    'assignment',
  ];
  
  for (final table in masterTables) {
    await db.delete(table);
  }
}
```

**Fungsi:** Menghapus semua data dari tabel master (petugas, pohon, assignment).

---

### 8. `_cleanDataOperasionalFlag1()` - Hapus Data Operasional yang Sudah Tersinkron

```dart
Future<void> _cleanDataOperasionalFlag1(Database db) async {
  final List<String> trxTables = [
    'eksekusi',
    'kesehatan',
    'reposisi',
    'auditlog',
  ];
  
  for (final table in trxTables) {
    await db.delete(
      table,
      where: 'flag = ?',
      whereArgs: [1],
    );
  }
}
```

**Fungsi:** Menghapus data operasional yang sudah tersinkron (flag = 1) dari tabel eksekusi, kesehatan, reposisi, dan auditlog.

---

## 📝 Cara Penggunaan

### Inisialisasi Database

```dart
import 'package:flutter_project/plantdb/db_helper.dart';

// Mendapatkan instance database
final dbHelper = DBHelper();
final db = await dbHelper.database;
```

### Insert Data

```dart
// Insert data pohon
await db.insert('pohon', {
  'blok': 'A1',
  'nbaris': '05',
  'npohon': '123',
  'objectId': 'POH-A1-05-123',
  'status': 'sehat',
  'nflag': '0',
});
```

### Query Data

```dart
// Ambil semua pohon di blok A1
final List<Map<String, dynamic>> pohonList = await db.query(
  'pohon',
  where: 'blok = ?',
  whereArgs: ['A1'],
);
```

### Update Data

```dart
// Update status pohon
await db.update(
  'pohon',
  {'status': 'sakit'},
  where: 'objectId = ?',
  whereArgs: ['POH-A1-05-123'],
);
```

### Delete Data

```dart
// Hapus pohon
await db.delete(
  'pohon',
  where: 'objectId = ?',
  whereArgs: ['POH-A1-05-123'],
);
```

### Clean Database After Login

```dart
// Bersihkan database setelah login
await DBHelper().cleanDatabaseAfterLogin();
```

---

## 🔄 Flag Sinkronisasi

Beberapa tabel menggunakan kolom `flag` untuk tracking status sinkronisasi:

| Flag | Keterangan |
|------|------------|
| `0` | Data belum tersinkron ke server |
| `1` | Data sudah tersinkron ke server |

**Tabel dengan Flag:**
- `eksekusi`
- `reposisi`
- `kesehatan`
- `auditlog`

---

## 🎯 Best Practices

1. **Gunakan Singleton Pattern**: Selalu gunakan `DBHelper()` untuk mendapatkan instance, jangan buat instance baru.

2. **Handle Null Safety**: Database bisa null, pastikan menggunakan null check atau await.

3. **Transaction untuk Multiple Operations**: Gunakan transaction untuk operasi multiple insert/update/delete.

```dart
await db.transaction((txn) async {
  await txn.insert('pohon', data1);
  await txn.insert('pohon', data2);
});
```

4. **Clean Database After Login**: Selalu panggil `cleanDatabaseAfterLogin()` setelah user login untuk memastikan data fresh.

5. **Set Flag Setelah Sync**: Jangan lupa set `flag = 1` setelah data berhasil tersinkron ke server.

---

## ⚠️ Catatan Penting

1. **Database Path**: Database disimpan di path default SQLite (`getDatabasesPath()`).

2. **Database Version**: Saat ini versi 1, jika ada perubahan schema, increment version dan implement `onUpgrade`.

3. **Delete Database**: Ada kode `deleteDatabase(path)` yang di-comment, gunakan hanya untuk development/testing.

4. **Primary Key**: Semua tabel menggunakan TEXT sebagai primary key, pastikan ID unik.

5. **No Foreign Key Constraint**: Database ini tidak menggunakan foreign key constraint, pastikan referential integrity di application layer.

---

## 📚 Dependencies

```yaml
dependencies:
  sqflite: ^2.0.0+4
  path: ^1.9.0
```

---

## 🔗 Relasi Antar Tabel

```
petugas (akun)
    ↓
assignment (petugas)
    ↓
eksekusi (petugas, spkNumber)

pohon (objectId)
    ↓
├── riwayat (objectId)
├── reposisi (idTanaman)
└── kesehatan (idTanaman)

auditlog (user_id) → petugas (akun)
```

---

## 📞 Support

Untuk pertanyaan atau issue terkait database, silakan hubungi tim development.

**Last Updated:** 2024-12-12  
**Database Version:** 1  
**Minimum Android SDK:** 28 (Android 9 - Pie)
