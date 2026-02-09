# Quick Reference - Model Classes

## 🚀 Quick Start

```dart
import 'package:flutter_project/mvc_models/assignment.dart';
import 'package:flutter_project/mvc_models/audit_log.dart';
import 'package:flutter_project/mvc_models/execution.dart';
import 'package:flutter_project/mvc_models/info.dart';
import 'package:flutter_project/mvc_models/kesehatan.dart';
import 'package:flutter_project/mvc_models/petugas.dart';
import 'package:flutter_project/mvc_models/pohon.dart';
import 'package:flutter_project/mvc_models/reposisi.dart';
import 'package:flutter_project/mvc_models/riwayat.dart';
```

---

## 📊 Model Summary

| Model | Properties | Flag | Primary Key |
|-------|------------|------|-------------|
| Assignment | 9 | ❌ | id |
| AuditLog | 7 | ✅ | idAudit |
| TaskExecution | 9 | ✅ | id |
| Info | 5 | ❌ | kode |
| Kesehatan | 10 | ✅ | idKesehatan |
| Petugas | 5 | ❌ | akun |
| Pohon | 6 | ❌ | objectId |
| Reposisi | 10 | ✅ | idReposisi |
| Riwayat | 6 | ❌ | id |

---

## 1️⃣ Assignment

```dart
// Create
final assignment = Assignment(
  id: 'ASG-001',
  spkNumber: 'SPK/2024/001',
  taskName: 'Pemupukan',
  estate: 'Kebun Raya',
  division: 'Divisi 1',
  block: 'A1',
  rowNumber: '05',
  treeNumber: '123',
  petugas: 'PTG-001',
);

// From Map
final a = Assignment.fromMap(map);

// To Map
final map = assignment.toMap();

// Computed Properties
print(assignment.fullLocation);
print(assignment.location);
```

---

## 2️⃣ AuditLog

```dart
// Create
final auditLog = AuditLog(
  idAudit: 'AUD-${DateTime.now().millisecondsSinceEpoch}',
  userId: 'PTG-001',
  action: 'INSERT',
  detail: '{"table":"eksekusi","id":"EKS-001"}',
  logDate: DateTime.now().toString(),
  device: 'Android 9 - Samsung A10',
  flag: 0,
);

// From Map
final log = AuditLog.fromMap(map);

// To Map
final map = auditLog.toMap();
```

---

## 3️⃣ TaskExecution

```dart
// Create
final execution = TaskExecution(
  id: 'EKS-${DateTime.now().millisecondsSinceEpoch}',
  spkNumber: 'SPK/2024/001',
  taskName: 'Pemupukan',
  taskState: 'completed',
  petugas: 'PTG-001',
  taskDate: DateTime.now().toString().split(' ')[0],
  flag: 0,
  keterangan: 'Pemupukan NPK selesai',
  imagePath: '/storage/images/eks_001.jpg', // nullable
);

// From Map
final exec = TaskExecution.fromMap(map);

// To Map
final map = execution.toMap();
```

---

## 4️⃣ Info

```dart
// Create
final info = Info(
  kode: 'E001',
  istilah: 'DB_ERROR',
  namaError: 'Database Connection Error',
  keterangan: 'Gagal terhubung ke database lokal',
  jenis: 'error',
);

// From Map
final i = Info.fromMap(map);

// To Map
final map = info.toMap();
```

---

## 5️⃣ Kesehatan

```dart
// Create
final kesehatan = Kesehatan(
  idKesehatan: 'KES-${DateTime.now().millisecondsSinceEpoch}',
  idTanaman: 'POH-A1-05-123',
  statusAwal: '5', // SSB
  statusAkhir: '2', // SR
  kodeStatus: 'G2',
  jenisPohon: 'UTAMA',
  keterangan: 'Terserang hama',
  petugas: 'PTG-001',
  fromDate: DateTime.now().toString().split(' ')[0],
  flag: 0,
);

// Status Codes: 5=SSB, 4=SB, 3=SS, 2=SR, 1=S
// Jenis Pohon: UTAMA, SISIP
// Kode Status: G0, G1, G2, G3, G4

// From Map
final k = Kesehatan.fromMap(map);

// To Map
final map = kesehatan.toMap();
```

---

## 6️⃣ Petugas

```dart
// Create
final petugas = Petugas(
  akun: 'PTG-001',
  nama: 'Budi Santoso',
  kontak: '081234567890',
  peran: 'Mandor', // Mandor, Krani, Admin
  lastSync: DateTime.now().toString(),
);

// From Map
final p = Petugas.fromMap(map);

// To Map
final map = petugas.toMap();
```

---

## 7️⃣ Pohon

```dart
// Create
const pohon = Pohon(
  blok: 'A1',
  nbaris: '05',
  npohon: '123',
  objectId: 'POH-A1-05-123',
  status: 'sehat',
  nflag: '0',
);

// From Map
final p = Pohon.fromMap(map);

// To Map
final map = pohon.toMap();

// Helper Functions
final grouped = groupByBaris(pohonList);
final grid = generateDataGrid(barisList, pohonList);
final hGrid = generateHorizontalGrid(barisList, pohonList);
final nGrid = generateNumberAlignedGrid(barisList, pohonList);
```

---

## 8️⃣ Reposisi

```dart
// Create
final reposisi = Reposisi(
  idReposisi: 'REP-${DateTime.now().millisecondsSinceEpoch}',
  idTanaman: 'POH-A1-05-123',
  pohonAwal: '123',
  barisAwal: '05',
  pohonTujuan: '124',
  barisTujuan: '06',
  keterangan: 'Pohon dipindahkan karena lahan rusak',
  tipeRiwayat: 'R', // L, R, N, K
  petugas: 'PTG-001',
  flag: 0,
);

// Tipe Riwayat: L=Left, R=Right, N=Normal, K=Kenthosan

// From Map
final r = Reposisi.fromMap(map);

// To Map
final map = reposisi.toMap();
```

---

## 9️⃣ Riwayat

```dart
// Create
final riwayat = Riwayat(
  id: 'SPK/2024/001',
  objectId: 'POH-A1-05-123',
  tanggal: DateTime.now().toString().split(' ')[0],
  jenis: 'Pemupukan', // Eradikasi, Pemupukan, Penyemprotan, Penyakit
  keterangan: 'Pemupukan NPK 15-15-15',
  status: 'SELESAI', // SELESAI, TUNDA, DELEGASI
);

// From Map
final r = Riwayat.fromMap(map);

// To Map
final map = riwayat.toMap();
```

---

## 💾 Database Operations

### Insert
```dart
await db.insert('tableName', model.toMap());
```

### Query All
```dart
final list = await db.query('tableName');
final models = list.map((m) => ModelClass.fromMap(m)).toList();
```

### Query with Where
```dart
final list = await db.query(
  'tableName',
  where: 'column = ?',
  whereArgs: [value],
);
```

### Update
```dart
await db.update(
  'tableName',
  model.toMap(),
  where: 'id = ?',
  whereArgs: [model.id],
);
```

### Delete
```dart
await db.delete(
  'tableName',
  where: 'id = ?',
  whereArgs: [id],
);
```

---

## 🔄 Flag Sync Operations

### Query Unsynced Data
```dart
final unsynced = await db.query(
  'tableName',
  where: 'flag = ?',
  whereArgs: [0],
);
```

### Update Flag After Sync
```dart
await db.update(
  'tableName',
  {'flag': 1},
  where: 'id = ?',
  whereArgs: [id],
);
```

### Delete Synced Data
```dart
await db.delete(
  'tableName',
  where: 'flag = ?',
  whereArgs: [1],
);
```

---

## 🎯 Common Patterns

### Generate Unique ID
```dart
final id = 'PREFIX-${DateTime.now().millisecondsSinceEpoch}';
```

### Get Current Date
```dart
final date = DateTime.now().toString().split(' ')[0]; // yyyy-mm-dd
```

### Get Current DateTime
```dart
final datetime = DateTime.now().toString(); // yyyy-mm-dd HH:mm:ss
```

### Null Check in fromMap
```dart
property: map['property'] ?? defaultValue,
```

---

## 📋 Table Mapping

| Model | Table | PK Column |
|-------|-------|-----------|
| Assignment | assignment | id |
| AuditLog | auditlog | id_audit |
| TaskExecution | eksekusi | id |
| Kesehatan | kesehatan | idKesehatan |
| Petugas | petugas | akun |
| Pohon | pohon | objectId |
| Reposisi | reposisi | idReposisi |
| Riwayat | riwayat | id |

---

## ⚠️ Important Notes

✅ **DO:**
- Use `fromMap()` when reading from database
- Use `toMap()` when writing to database
- Set flag = 0 for new data
- Set flag = 1 after successful sync
- Use const constructor for Pohon when possible

❌ **DON'T:**
- Don't modify properties after creation (immutable)
- Don't forget to handle nullable properties
- Don't use hardcoded IDs
- Don't forget to sync data periodically

---

## 🔗 Quick Links

- [Full Documentation](03_README_models)
- [Class Diagram](00_CLASS_DIAGRAM)
- [Database Documentation](../plantdb/README_db_helper.md)
