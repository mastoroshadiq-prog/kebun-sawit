# Dokumentasi Model Classes - Aplikasi Kebun Sawit

## 📋 Overview

Folder `mvc_models` berisi **9 model classes** yang merepresentasikan entitas data dalam aplikasi manajemen kebun sawit. Setiap model class memiliki:
- Properties yang sesuai dengan kolom database
- Method `toMap()` untuk konversi ke Map (untuk database)
- Factory method `fromMap()` untuk konversi dari Map (dari database)
- Computed properties atau helper methods (opsional)

---

## 📊 Daftar Model Classes

| No | Model Class | File | Properties | Flag Sync | Fungsi |
|----|-------------|------|------------|-----------|--------|
| 1 | `Assignment` | assignment.dart | 9 | ❌ | Penugasan petugas |
| 2 | `AuditLog` | audit_log.dart | 7 | ✅ | Audit trail aktivitas |
| 3 | `TaskExecution` | execution.dart | 9 | ✅ | Pelaksanaan tugas |
| 4 | `Info` | info.dart | 5 | ❌ | Informasi/kode error |
| 5 | `Kesehatan` | kesehatan.dart | 10 | ✅ | Status kesehatan pohon |
| 6 | `Petugas` | petugas.dart | 5 | ❌ | Data petugas lapangan |
| 7 | `Pohon` | pohon.dart | 6 + helpers | ❌ | Data pohon sawit |
| 8 | `Reposisi` | reposisi.dart | 10 | ✅ | Perpindahan pohon |
| 9 | `Riwayat` | riwayat.dart | 6 | ❌ | Riwayat aktivitas pohon |

---

## 1️⃣ Assignment Model

**File:** `assignment.dart`  
**Fungsi:** Merepresentasikan penugasan pekerjaan kepada petugas lapangan

### Properties

| Property | Type | Nullable | Keterangan |
|----------|------|----------|------------|
| `id` | String | ❌ | Primary key - ID penugasan |
| `spkNumber` | String | ❌ | Nomor SPK (Surat Perintah Kerja) |
| `taskName` | String | ❌ | Nama tugas yang ditugaskan |
| `estate` | String | ❌ | Nama estate/kebun |
| `division` | String | ❌ | Divisi dalam estate |
| `block` | String | ❌ | Blok yang ditugaskan |
| `rowNumber` | String | ❌ | Nomor baris pohon |
| `treeNumber` | String | ❌ | Nomor pohon |
| `petugas` | String | ❌ | ID petugas yang ditugaskan |

### Computed Properties

```dart
String get fullLocation => 'Estate $estate / Divisi $division / Blok $block / Baris $rowNumber / Pohon ke $treeNumber';
String get location => 'Estate $estate / Divisi $division / Blok $block';
```

### Contoh Penggunaan

```dart
// Membuat instance dari Map (dari database)
final assignment = Assignment.fromMap({
  'id': 'ASG-001',
  'spkNumber': 'SPK/2024/001',
  'taskName': 'Pemupukan',
  'estate': 'Kebun Raya',
  'division': 'Divisi 1',
  'block': 'A1',
  'rowNumber': '05',
  'treeNumber': '123',
  'petugas': 'PTG-001',
});

// Menggunakan computed property
print(assignment.fullLocation);
// Output: Estate Kebun Raya / Divisi Divisi 1 / Blok A1 / Baris 05 / Pohon ke 123

// Konversi ke Map (untuk disimpan ke database)
final map = assignment.toMap();
await db.insert('assignment', map);
```

---

## 2️⃣ AuditLog Model

**File:** `audit_log.dart`  
**Fungsi:** Merepresentasikan log audit untuk tracking aktivitas pengguna

### Properties

| Property | Type | Nullable | Keterangan |
|----------|------|----------|------------|
| `idAudit` | String | ❌ | Primary key - ID audit |
| `userId` | String | ❌ | ID user yang melakukan aksi |
| `action` | String | ❌ | Jenis aksi (INSERT/UPDATE/DELETE) |
| `detail` | String | ❌ | Detail aksi dalam format JSON |
| `logDate` | String | ❌ | Tanggal dan waktu aksi |
| `device` | String | ❌ | Informasi device |
| `flag` | int | ❌ | Flag sinkronisasi (0=belum, 1=sudah) |

### Contoh Penggunaan

```dart
// Membuat audit log baru
final auditLog = AuditLog(
  idAudit: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
  userId: 'PTG-001',
  action: 'INSERT',
  detail: '{"table":"eksekusi","id":"EKS-001"}',
  logDate: DateTime.now().toString(),
  device: 'Android 9 - Samsung A10',
  flag: 0,
);

// Simpan ke database
await db.insert('auditlog', auditLog.toMap());

// Update flag setelah sync
await db.update(
  'auditlog',
  {'flag': 1},
  where: 'id_audit = ?',
  whereArgs: [auditLog.idAudit],
);
```

---

## 3️⃣ TaskExecution Model

**File:** `execution.dart`  
**Fungsi:** Merepresentasikan pelaksanaan tugas oleh petugas

### Properties

| Property | Type | Nullable | Keterangan |
|----------|------|----------|------------|
| `id` | String | ❌ | Primary key - ID eksekusi |
| `spkNumber` | String | ❌ | Nomor SPK |
| `taskName` | String | ❌ | Nama tugas |
| `taskState` | String | ❌ | Status tugas (pending/completed/cancelled) |
| `petugas` | String | ❌ | ID petugas |
| `taskDate` | String | ❌ | Tanggal pelaksanaan |
| `flag` | int | ❌ | Flag sinkronisasi (0=belum, 1=sudah) |
| `keterangan` | String | ❌ | Catatan/keterangan |
| `imagePath` | String? | ✅ | Path foto bukti pelaksanaan (nullable) |

### Contoh Penggunaan

```dart
// Membuat task execution baru
final execution = TaskExecution(
  id: 'EKS-${DateTime.now().millisecondsSinceEpoch}',
  spkNumber: 'SPK/2024/001',
  taskName: 'Pemupukan',
  taskState: 'completed',
  petugas: 'PTG-001',
  taskDate: DateTime.now().toString().split(' ')[0],
  flag: 0,
  keterangan: 'Pemupukan NPK selesai',
  imagePath: '/storage/images/eks_001.jpg',
);

// Simpan ke database
await db.insert('eksekusi', execution.toMap());

// Query eksekusi yang belum sync
final unsyncedList = await db.query(
  'eksekusi',
  where: 'flag = ?',
  whereArgs: [0],
);
final executions = unsyncedList.map((m) => TaskExecution.fromMap(m)).toList();
```

---

## 4️⃣ Info Model

**File:** `info.dart`  
**Fungsi:** Merepresentasikan informasi atau kode error dalam sistem

### Properties

| Property | Type | Nullable | Keterangan |
|----------|------|----------|------------|
| `kode` | String | ❌ | Kode informasi/error |
| `istilah` | String | ❌ | Istilah atau nama singkat |
| `namaError` | String | ❌ | Nama error lengkap |
| `keterangan` | String | ❌ | Deskripsi detail |
| `jenis` | String | ❌ | Jenis informasi (error/warning/info) |

### Contoh Penggunaan

```dart
// Membuat info error
final info = Info(
  kode: 'E001',
  istilah: 'DB_ERROR',
  namaError: 'Database Connection Error',
  keterangan: 'Gagal terhubung ke database lokal',
  jenis: 'error',
);

// Membuat info warning
final warning = Info.fromMap({
  'kode': 'W001',
  'istilah': 'SYNC_WARNING',
  'namaError': 'Sync Pending',
  'keterangan': 'Ada data yang belum tersinkron',
  'jenis': 'warning',
});

// Konversi ke Map
final map = info.toMap();
```

---

## 5️⃣ Kesehatan Model

**File:** `kesehatan.dart`  
**Fungsi:** Merepresentasikan perubahan status kesehatan pohon

### Properties

| Property | Type | Nullable | Keterangan |
|----------|------|----------|------------|
| `idKesehatan` | String | ❌ | Primary key - ID kesehatan |
| `idTanaman` | String | ❌ | Referensi ke pohon.objectId |
| `statusAwal` | String | ❌ | Status awal (5,4,3,2,1 → SSB,SB,SS,SR,S) |
| `statusAkhir` | String | ❌ | Status akhir (5,4,3,2,1 → SSB,SB,SS,SR,S) |
| `kodeStatus` | String | ❌ | Kode status (G0, G1, G2, G3, G4) |
| `jenisPohon` | String | ❌ | Jenis pohon (UTAMA/SISIP) |
| `keterangan` | String | ❌ | Catatan perubahan |
| `petugas` | String | ❌ | ID petugas |
| `fromDate` | String | ❌ | Tanggal mulai status |
| `flag` | int | ❌ | Flag sinkronisasi (0=belum, 1=sudah) |

### Kode Status Kesehatan

| Kode | Status | Keterangan |
|------|--------|------------|
| 5 | SSB | Sangat Sangat Baik |
| 4 | SB | Sangat Baik |
| 3 | SS | Sedang Sehat |
| 2 | SR | Sedang Rusak |
| 1 | S | Sakit |

### Contoh Penggunaan

```dart
// Membuat record kesehatan
final kesehatan = Kesehatan(
  idKesehatan: 'KES-${DateTime.now().millisecondsSinceEpoch}',
  idTanaman: 'POH-A1-05-123',
  statusAwal: '5', // SSB
  statusAkhir: '2', // SR
  kodeStatus: 'G2',
  jenisPohon: 'UTAMA',
  keterangan: 'Terserang hama penggerek batang',
  petugas: 'PTG-001',
  fromDate: DateTime.now().toString().split(' ')[0],
  flag: 0,
);

// Simpan ke database
await db.insert('kesehatan', kesehatan.toMap());

// Query riwayat kesehatan pohon
final riwayatKesehatan = await db.query(
  'kesehatan',
  where: 'idTanaman = ?',
  whereArgs: ['POH-A1-05-123'],
  orderBy: 'fromDate DESC',
);
```

---

## 6️⃣ Petugas Model

**File:** `petugas.dart`  
**Fungsi:** Merepresentasikan data petugas lapangan

### Properties

| Property | Type | Nullable | Keterangan |
|----------|------|----------|------------|
| `akun` | String | ❌ | Primary key - Username/ID akun |
| `nama` | String | ❌ | Nama lengkap petugas |
| `kontak` | String | ❌ | Nomor telepon atau email |
| `peran` | String | ❌ | Peran/jabatan (Mandor/Krani/Admin) |
| `lastSync` | String | ❌ | Waktu sinkronisasi terakhir (yyyy-mm-dd HH:mm:ss) |

### Contoh Penggunaan

```dart
// Membuat petugas baru
final petugas = Petugas(
  akun: 'PTG-001',
  nama: 'Budi Santoso',
  kontak: '081234567890',
  peran: 'Mandor',
  lastSync: DateTime.now().toString(),
);

// Simpan ke database
await db.insert('petugas', petugas.toMap());

// Query petugas berdasarkan peran
final mandorList = await db.query(
  'petugas',
  where: 'peran = ?',
  whereArgs: ['Mandor'],
);
final petugasList = mandorList.map((m) => Petugas.fromMap(m)).toList();

// Update last sync
await db.update(
  'petugas',
  {'lastSync': DateTime.now().toString()},
  where: 'akun = ?',
  whereArgs: ['PTG-001'],
);
```

---

## 7️⃣ Pohon Model

**File:** `pohon.dart`  
**Fungsi:** Merepresentasikan data pohon kelapa sawit dengan helper functions untuk grid visualization

### Properties

| Property | Type | Nullable | Keterangan |
|----------|------|----------|------------|
| `blok` | String | ❌ | Kode blok kebun |
| `nbaris` | String | ❌ | Nomor baris pohon |
| `npohon` | String | ❌ | Nomor pohon |
| `objectId` | String | ❌ | Primary key - ID unik pohon |
| `status` | String | ❌ | Status pohon (sehat/sakit/mati) |
| `nflag` | String | ❌ | Flag untuk sinkronisasi |

### Helper Functions

Model `Pohon` dilengkapi dengan **4 helper functions** untuk visualisasi grid pohon:

1. **`groupByBaris()`** - Mengelompokkan pohon berdasarkan baris
2. **`generateDataGrid()`** - Membuat grid data untuk visualisasi
3. **`generateHorizontalGrid()`** - Membuat grid horizontal
4. **`generateNumberAlignedGrid()`** - Membuat grid dengan alignment nomor

### Contoh Penggunaan

```dart
// Membuat pohon baru
final pohon = Pohon(
  blok: 'A1',
  nbaris: '05',
  npohon: '123',
  objectId: 'POH-A1-05-123',
  status: 'sehat',
  nflag: '0',
);

// Simpan ke database
await db.insert('pohon', pohon.toMap());

// Query pohon di blok tertentu
final pohonList = await db.query(
  'pohon',
  where: 'blok = ?',
  whereArgs: ['A1'],
);
final pohons = pohonList.map((m) => Pohon.fromMap(m)).toList();

// Gunakan helper function untuk grouping
final grouped = groupByBaris(pohons);
print(grouped['05']); // List pohon di baris 05

// Generate grid untuk visualisasi
final barisList = ['01', '02', '03', '04', '05'];
final grid = generateNumberAlignedGrid(barisList, pohons);
```

---

## 8️⃣ Reposisi Model

**File:** `reposisi.dart`  
**Fungsi:** Merepresentasikan perpindahan/reposisi pohon dari satu lokasi ke lokasi lain

### Properties

| Property | Type | Nullable | Keterangan |
|----------|------|----------|------------|
| `idReposisi` | String | ❌ | Primary key - ID reposisi |
| `idTanaman` | String | ❌ | Referensi ke pohon.objectId |
| `pohonAwal` | String | ❌ | Nomor pohon sebelum reposisi |
| `barisAwal` | String | ❌ | Nomor baris sebelum reposisi |
| `pohonTujuan` | String | ❌ | Nomor pohon setelah reposisi |
| `barisTujuan` | String | ❌ | Nomor baris setelah reposisi |
| `keterangan` | String | ❌ | Catatan/alasan reposisi |
| `tipeRiwayat` | String | ❌ | Tipe (L/R/N/K: Left/Right/Normal/Kenthosan) |
| `petugas` | String | ❌ | ID petugas |
| `flag` | int | ❌ | Flag sinkronisasi (0=belum, 1=sudah) |

### Tipe Riwayat

| Kode | Tipe | Keterangan |
|------|------|------------|
| L | Left | Reposisi ke kiri |
| R | Right | Reposisi ke kanan |
| N | Normal | Reposisi normal |
| K | Kenthosan | Reposisi kenthosan |

### Contoh Penggunaan

```dart
// Membuat reposisi pohon
final reposisi = Reposisi(
  idReposisi: 'REP-${DateTime.now().millisecondsSinceEpoch}',
  idTanaman: 'POH-A1-05-123',
  pohonAwal: '123',
  barisAwal: '05',
  pohonTujuan: '124',
  barisTujuan: '06',
  keterangan: 'Pohon dipindahkan karena lahan rusak',
  tipeRiwayat: 'R', // Right
  petugas: 'PTG-001',
  flag: 0,
);

// Simpan ke database
await db.insert('reposisi', reposisi.toMap());

// Query riwayat reposisi pohon
final riwayatReposisi = await db.query(
  'reposisi',
  where: 'idTanaman = ?',
  whereArgs: ['POH-A1-05-123'],
);
```

---

## 9️⃣ Riwayat Model

**File:** `riwayat.dart`  
**Fungsi:** Merepresentasikan riwayat aktivitas pada pohon tertentu

### Properties

| Property | Type | Nullable | Keterangan |
|----------|------|----------|------------|
| `id` | String | ❌ | Primary key - Nomor SPK |
| `objectId` | String | ❌ | Referensi ke pohon.objectId |
| `tanggal` | String | ❌ | Tanggal aktivitas (yyyy-mm-dd) |
| `jenis` | String | ❌ | Jenis aktivitas |
| `keterangan` | String | ❌ | Catatan detail aktivitas |
| `status` | String | ❌ | Status (SELESAI/TUNDA/DELEGASI) |

### Jenis Aktivitas

- Eradikasi
- Pemupukan
- Penyemprotan
- Penyakit
- Perawatan
- Pemanenan

### Contoh Penggunaan

```dart
// Membuat riwayat aktivitas
final riwayat = Riwayat(
  id: 'SPK/2024/001',
  objectId: 'POH-A1-05-123',
  tanggal: DateTime.now().toString().split(' ')[0],
  jenis: 'Pemupukan',
  keterangan: 'Pemupukan NPK 15-15-15 sebanyak 2kg',
  status: 'SELESAI',
);

// Simpan ke database
await db.insert('riwayat', riwayat.toMap());

// Query riwayat pohon
final riwayatPohon = await db.query(
  'riwayat',
  where: 'objectId = ?',
  whereArgs: ['POH-A1-05-123'],
  orderBy: 'tanggal DESC',
);
final riwayatList = riwayatPohon.map((m) => Riwayat.fromMap(m)).toList();

// Filter berdasarkan jenis
final pemupukan = riwayatList.where((r) => r.jenis == 'Pemupukan').toList();
```

---

## 🔗 Relasi Antar Model

```
Petugas (akun)
    ↓
├── Assignment (petugas)
├── TaskExecution (petugas)
├── Kesehatan (petugas)
├── Reposisi (petugas)
└── AuditLog (userId)

Pohon (objectId)
    ↓
├── Riwayat (objectId)
├── Kesehatan (idTanaman)
└── Reposisi (idTanaman)

Assignment (spkNumber)
    ↓
TaskExecution (spkNumber)
```

---

## 🎯 Pattern & Best Practices

### 1. Null Safety
Semua model menggunakan null safety dengan default values di `fromMap()`:

```dart
factory Assignment.fromMap(Map<String, dynamic> map) {
  return Assignment(
    id: map['id'] ?? '',  // Default empty string
    // ...
  );
}
```

### 2. Immutability
Semua properties menggunakan `final` untuk immutability:

```dart
class Pohon {
  final String blok;
  final String nbaris;
  // ...
}
```

### 3. Const Constructor
Model `Pohon` menggunakan `const` constructor untuk optimization:

```dart
const Pohon({
  required this.blok,
  // ...
});
```

### 4. Computed Properties
Model `Assignment` memiliki computed properties untuk kemudahan:

```dart
String get fullLocation => 'Estate $estate / Divisi $division / Blok $block / Baris $rowNumber / Pohon ke $treeNumber';
```

### 5. Helper Functions
Model `Pohon` memiliki helper functions di luar class untuk grid operations.

---

## 📝 Cara Penggunaan Umum

### Insert ke Database

```dart
final model = Assignment(/* ... */);
await db.insert('assignment', model.toMap());
```

### Query dari Database

```dart
final list = await db.query('assignment');
final assignments = list.map((m) => Assignment.fromMap(m)).toList();
```

### Update di Database

```dart
final updatedModel = Assignment(/* ... */);
await db.update(
  'assignment',
  updatedModel.toMap(),
  where: 'id = ?',
  whereArgs: [updatedModel.id],
);
```

### Delete dari Database

```dart
await db.delete(
  'assignment',
  where: 'id = ?',
  whereArgs: [assignmentId],
);
```

---

## 🔄 Model dengan Flag Sinkronisasi

4 model menggunakan flag untuk tracking sync status:

| Model | Flag Property | Default Value |
|-------|---------------|---------------|
| `TaskExecution` | `flag` (int) | 0 |
| `Kesehatan` | `flag` (int) | 0 |
| `Reposisi` | `flag` (int) | 0 |
| `AuditLog` | `flag` (int) | 0 |

**Flag Values:**
- `0` = Belum tersinkron ke server
- `1` = Sudah tersinkron ke server

---

## 📚 Dependencies

Model classes ini bekerja dengan:
- **Database**: `sqflite` untuk SQLite operations
- **Path**: `path` package untuk path operations
- **Dart Core**: Built-in Dart types (String, int, Map, List)

---

## ⚠️ Catatan Penting

1. **Naming Convention**: Nama properties di model menggunakan camelCase, sedangkan di database menggunakan snake_case (untuk beberapa model seperti `AuditLog`)

2. **Type Safety**: Semua properties memiliki type yang jelas (String, int, String?)

3. **Nullable Properties**: Hanya `imagePath` di `TaskExecution` yang nullable

4. **Primary Keys**: Semua model memiliki primary key yang jelas (id, objectId, akun, dll)

5. **Foreign Keys**: Relasi antar model dijaga di application layer, bukan database constraint

---

## 📞 Support

Untuk pertanyaan atau issue terkait model classes, silakan hubungi tim development.

**Last Updated:** 2024-12-12  
**Total Models:** 9 classes  
**Minimum Android SDK:** 28 (Android 9 - Pie)
