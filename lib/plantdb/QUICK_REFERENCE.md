# Quick Reference - DBHelper

## 🚀 Inisialisasi

```dart
final dbHelper = DBHelper();
final db = await dbHelper.database;
```

## 📊 8 Tabel Database

| Tabel | Primary Key | Fungsi | Flag Sync |
|-------|-------------|--------|-----------|
| `pohon` | objectId | Master pohon sawit | ❌ |
| `assignment` | id | Penugasan petugas | ❌ |
| `eksekusi` | id | Pelaksanaan tugas | ✅ |
| `riwayat` | id | Riwayat pohon | ❌ |
| `reposisi` | idReposisi | Perpindahan pohon | ✅ |
| `kesehatan` | idKesehatan | Status kesehatan | ✅ |
| `petugas` | akun | Data petugas | ❌ |
| `auditlog` | id_audit | Audit trail | ✅ |

## 💾 CRUD Operations

### Insert
```dart
await db.insert('pohon', {
  'objectId': 'POH-001',
  'blok': 'A1',
  'nbaris': '05',
  'npohon': '123',
  'status': 'sehat',
  'nflag': '0',
});
```

### Query
```dart
// Semua data
final all = await db.query('pohon');

// Dengan kondisi
final filtered = await db.query(
  'pohon',
  where: 'blok = ?',
  whereArgs: ['A1'],
);

// Raw query
final result = await db.rawQuery(
  'SELECT * FROM pohon WHERE status = ?',
  ['sehat'],
);
```

### Update
```dart
await db.update(
  'pohon',
  {'status': 'sakit'},
  where: 'objectId = ?',
  whereArgs: ['POH-001'],
);
```

### Delete
```dart
await db.delete(
  'pohon',
  where: 'objectId = ?',
  whereArgs: ['POH-001'],
);
```

## 🔄 Sinkronisasi

### Clean Database After Login
```dart
await DBHelper().cleanDatabaseAfterLogin();
```

### Update Flag Setelah Sync
```dart
await db.update(
  'eksekusi',
  {'flag': 1},
  where: 'id = ?',
  whereArgs: ['EKS-001'],
);
```

### Query Data Belum Sync
```dart
final unsyncedData = await db.query(
  'eksekusi',
  where: 'flag = ?',
  whereArgs: [0],
);
```

## 🔗 Join Query Example

```dart
// Join pohon dengan kesehatan
final result = await db.rawQuery('''
  SELECT p.*, k.statusAkhir, k.keterangan
  FROM pohon p
  LEFT JOIN kesehatan k ON p.objectId = k.idTanaman
  WHERE p.blok = ?
''', ['A1']);
```

## 📝 Transaction Example

```dart
await db.transaction((txn) async {
  // Insert eksekusi
  await txn.insert('eksekusi', eksekusiData);
  
  // Insert riwayat
  await txn.insert('riwayat', riwayatData);
  
  // Update pohon
  await txn.update('pohon', {'status': 'selesai'},
    where: 'objectId = ?',
    whereArgs: [pohonId],
  );
});
```

## 🎯 Common Queries

### Pohon di Blok Tertentu
```dart
final pohon = await db.query('pohon',
  where: 'blok = ?',
  whereArgs: ['A1'],
);
```

### Assignment Petugas
```dart
final tasks = await db.query('assignment',
  where: 'petugas = ?',
  whereArgs: ['PTG-001'],
);
```

### Eksekusi Belum Sync
```dart
final pending = await db.query('eksekusi',
  where: 'flag = ?',
  whereArgs: [0],
);
```

### Riwayat Pohon
```dart
final history = await db.query('riwayat',
  where: 'objectId = ?',
  whereArgs: ['POH-001'],
  orderBy: 'tanggal DESC',
);
```

### Audit Log User
```dart
final logs = await db.query('auditlog',
  where: 'user_id = ?',
  whereArgs: ['PTG-001'],
  orderBy: 'log_date DESC',
  limit: 50,
);
```

## ⚠️ Best Practices

✅ **DO:**
- Gunakan prepared statements (whereArgs)
- Gunakan transaction untuk multiple operations
- Set flag = 1 setelah sync berhasil
- Clean database after login
- Handle exceptions dengan try-catch

❌ **DON'T:**
- Jangan gunakan string concatenation untuk query
- Jangan lupa set flag setelah sync
- Jangan buat instance DBHelper baru (gunakan singleton)
- Jangan hardcode ID, gunakan UUID

## 🔐 Flag Values

| Flag | Status | Action |
|------|--------|--------|
| 0 | Belum sync | Kirim ke server |
| 1 | Sudah sync | Bisa dihapus saat clean |

## 📞 Quick Links

- [Dokumentasi Lengkap](README_db_helper.md)
- [ERD Diagram](ERD_plantdb.md)
