# Dokumentasi DAO Classes - Data Access Objects

## 📋 Overview

Folder `mvc_dao` berisi **9 DAO (Data Access Object) classes** yang mengelola akses ke database SQLite. Setiap DAO class bertanggung jawab untuk operasi CRUD (Create, Read, Update, Delete) pada tabel tertentu.

**Pattern:** Data Access Object (DAO) Pattern  
**Database:** SQLite via `sqflite` package  
**Database Helper:** `DBHelper` (Singleton)

---

## 📊 Daftar DAO Classes

| No | DAO Class | File | Table | Model | Methods |
|----|-----------|------|-------|-------|---------|
| 1 | `AssignmentDao` | dao_assignment.dart | assignment | Assignment | 8 methods |
| 2 | `AuditLogDao` | dao_audit_log.dart | auditlog | AuditLog | 6 methods |
| 3 | `KesehatanDao` | dao_kesehatan.dart | kesehatan | Kesehatan | 9 methods |
| 4 | `PetugasDao` | dao_petugas.dart | petugas | Petugas | 5 methods |
| 5 | `PohonDao` | dao_pohon.dart | pohon | Pohon | 6 methods |
| 6 | `ReposisiDao` | dao_reposisi.dart | reposisi | Reposisi | 7 methods |
| 7 | `RiwayatDao` | dao_riwayat.dart | riwayat | Riwayat | 4 methods |
| 8 | `TaskExecutionDao` | dao_task_execution.dart | eksekusi | TaskExecution | 9 methods |
| 9 | `DaoManager` | dao_manager.dart | All tables | Generic | 20+ methods |

---

## 1️⃣ AssignmentDao

**File:** `dao_assignment.dart`  
**Table:** `assignment`  
**Model:** `Assignment`

### Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `insertAssignment()` | `Future<int>` | Insert single assignment |
| `insertListAssignment()` | `Future<int>` | Insert list (loop) |
| `insertAssignmentsBatch()` | `Future<int>` | Insert list (batch) |
| `getAllAssignment()` | `Future<List<Assignment>>` | Get all assignments |
| `getAssignmentById()` | `Future<Assignment?>` | Get by ID |
| `updateAssignment()` | `Future<int>` | Update assignment |
| `deleteAssignment()` | `Future<int>` | Delete by ID |
| `deleteAllAssignments()` | `Future<int>` | Delete all |

### Contoh Penggunaan

```dart
final dao = AssignmentDao();

// Insert single
await dao.insertAssignment(assignment);

// Insert batch (lebih efisien untuk banyak data)
await dao.insertAssignmentsBatch(assignmentList);

// Get all
final assignments = await dao.getAllAssignment();

// Get by ID
final assignment = await dao.getAssignmentById('ASG-001');

// Update
await dao.updateAssignment(updatedAssignment);

// Delete
await dao.deleteAssignment('ASG-001');

// Delete all
await dao.deleteAllAssignments();
```

---

## 2️⃣ AuditLogDao

**File:** `dao_audit_log.dart`  
**Table:** `auditlog`  
**Model:** `AuditLog`

### Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `insertAuditLog()` | `Future<int>` | Insert audit log |
| `getAllAuditLog()` | `Future<List<AuditLog>>` | Get all logs |
| `getAllByFlag()` | `Future<List<AuditLog>>` | Get unsynced logs (flag=0) |
| `updateFlag()` | `Future<void>` | Update flag to 1 |
| `createLog()` | `Future<void>` | Create log with auto device info |
| `getDeviceName()` | `Future<String>` | Get device name (Android/iOS) |

### Special Features

- **Auto Device Info**: Method `createLog()` otomatis mendapatkan device name
- **UUID Generation**: Menggunakan `Uuid().v4()` untuk generate ID
- **Platform Detection**: Deteksi Android/iOS untuk device info

### Contoh Penggunaan

```dart
final dao = AuditLogDao();

// Create log (simple)
await dao.createLog('INSERT', '{"table":"eksekusi","id":"EKS-001"}');

// Get unsynced logs
final unsyncedLogs = await dao.getAllByFlag();

// Update flag after sync
for (var log in unsyncedLogs) {
  await dao.updateFlag(log.idAudit);
}
```

---

## 3️⃣ KesehatanDao

**File:** `dao_kesehatan.dart`  
**Table:** `kesehatan`  
**Model:** `Kesehatan`

### Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `insertKesehatan()` | `Future<int>` | Insert single |
| `insertListKesehatan()` | `Future<int>` | Insert list (loop) |
| `insertKesehatanBatch()` | `Future<int>` | Insert list (batch) |
| `getAllKesehatan()` | `Future<List<Kesehatan>>` | Get all |
| `getAllByFlag()` | `Future<List<Kesehatan>>` | Get unsynced (flag=0) |
| `getKesehatanById()` | `Future<Kesehatan?>` | Get by ID |
| `updateKesehatan()` | `Future<int>` | Update |
| `updateFlag()` | `Future<void>` | Update flag to 1 |
| `deleteKesehatan()` | `Future<int>` | Delete by ID |
| `deleteAllAssignments()` | `Future<int>` | Delete all |

### Contoh Penggunaan

```dart
final dao = KesehatanDao();

// Insert batch
await dao.insertKesehatanBatch(kesehatanList);

// Get unsynced
final unsynced = await dao.getAllByFlag();

// Update flag
await dao.updateFlag('KES-001');
```

---

## 4️⃣ PetugasDao

**File:** `dao_petugas.dart`  
**Table:** `petugas`  
**Model:** `Petugas`

### Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `insertPetugas()` | `Future<int>` | Insert/update petugas |
| `getAllPetugas()` | `Future<List<Petugas>>` | Get all |
| `getByAkun()` | `Future<Petugas?>` | Get by akun (PK) |
| `getPetugas()` | `Future<Petugas?>` | Get first petugas |
| `updateLastSync()` | `Future<int>` | Update last sync time |
| `deleteAllWorkers()` | `Future<int>` | Delete all |

### Contoh Penggunaan

```dart
final dao = PetugasDao();

// Insert/update
await dao.insertPetugas(petugas);

// Get current petugas
final petugas = await dao.getPetugas();

// Update last sync
await dao.updateLastSync('PTG-001', DateTime.now().toString());
```

---

## 5️⃣ PohonDao

**File:** `dao_pohon.dart`  
**Table:** `pohon`  
**Model:** `Pohon`

### Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `insertPohon()` | `Future<int>` | Insert single |
| `insertPohonBatch()` | `Future<int>` | Insert list (batch) |
| `getAllPohon()` | `Future<List<Pohon>>` | Get all |
| `getPohonById()` | `Future<Pohon?>` | Get by objectId |
| `updatePohon()` | `Future<int>` | Update |
| `deletePohon()` | `Future<int>` | Delete by objectId |
| `deleteAllPohon()` | `Future<int>` | Delete all |

### Contoh Penggunaan

```dart
final dao = PohonDao();

// Insert batch (efisien untuk banyak data)
await dao.insertPohonBatch(pohonList);

// Get all
final pohonList = await dao.getAllPohon();

// Get by ID
final pohon = await dao.getPohonById('POH-A1-05-123');
```

---

## 6️⃣ ReposisiDao

**File:** `dao_reposisi.dart`  
**Table:** `reposisi`  
**Model:** `Reposisi`

### Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `insertReposisi()` | `Future<int>` | Insert reposisi |
| `getAllReposisi()` | `Future<List<Reposisi>>` | Get all |
| `getAllByFlag()` | `Future<List<Reposisi>>` | Get unsynced (flag=0) |
| `getByIdReposisi()` | `Future<Reposisi?>` | Get by ID |
| `getByIdTanaman()` | `Future<List<Reposisi>>` | Get by pohon ID |
| `updateReposisi()` | `Future<int>` | Update |
| `updateFlag()` | `Future<void>` | Update flag to 1 |
| `deleteAll()` | `Future<int>` | Delete all |

### Contoh Penggunaan

```dart
final dao = ReposisiDao();

// Insert
await dao.insertReposisi(reposisi);

// Get by pohon
final riwayatReposisi = await dao.getByIdTanaman('POH-A1-05-123');

// Get unsynced
final unsynced = await dao.getAllByFlag();

// Update flag
await dao.updateFlag('REP-001');
```

---

## 7️⃣ RiwayatDao

**File:** `dao_riwayat.dart`  
**Table:** `riwayat`  
**Model:** `Riwayat`

### Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `insertRiwayat()` | `Future<int>` | Insert riwayat |
| `getAllRiwayat()` | `Future<List<Riwayat>>` | Get all |
| `getRiwayatByObjectId()` | `Future<List<Riwayat>>` | Get by pohon ID |
| `updateRiwayat()` | `Future<int>` | Update |
| `deleteRiwayat()` | `Future<int>` | Delete by ID |

### Contoh Penggunaan

```dart
final dao = RiwayatDao();

// Insert
await dao.insertRiwayat(riwayat);

// Get riwayat pohon
final riwayatPohon = await dao.getRiwayatByObjectId('POH-A1-05-123');

// Update
await dao.updateRiwayat(updatedRiwayat);
```

---

## 8️⃣ TaskExecutionDao

**File:** `dao_task_execution.dart`  
**Table:** `eksekusi`  
**Model:** `TaskExecution`

### Methods

| Method | Return Type | Description |
|--------|-------------|-------------|
| `insertTaskExec()` | `Future<int>` | Insert single |
| `insertListTaskExec()` | `Future<int>` | Insert list (loop) |
| `inserttaskExecBatch()` | `Future<int>` | Insert list (batch) |
| `getAllTaskExec()` | `Future<List<TaskExecution>>` | Get all |
| `getAllTaskExecByFlag()` | `Future<List<TaskExecution>>` | Get unsynced (flag=0) |
| `getTaskExecById()` | `Future<TaskExecution?>` | Get by ID |
| `updateAssignment()` | `Future<int>` | Update (typo: should be updateTaskExec) |
| `updateFlag()` | `Future<void>` | Update flag to 1 |
| `deleteTaskExec()` | `Future<int>` | Delete by ID |
| `deleteAllTaskExec()` | `Future<int>` | Delete all |

### Contoh Penggunaan

```dart
final dao = TaskExecutionDao();

// Insert batch
await dao.inserttaskExecBatch(taskExecList);

// Get unsynced
final unsynced = await dao.getAllTaskExecByFlag();

// Update flag
await dao.updateFlag('EKS-001');
```

---

## 9️⃣ DaoManager

**File:** `dao_manager.dart`  
**Table:** All tables (generic)  
**Pattern:** Singleton + Generic DAO

### Methods (20+ methods)

#### Table Information
- `getAllTableNames()` - Get all table names
- `tableExists()` - Check if table exists
- `getTableSchema()` - Get table structure
- `countRecords()` - Count rows in table

#### Query Operations
- `queryTable()` - Query all data
- `queryTableWhere()` - Query with WHERE
- `queryTablePaginated()` - Query with pagination
- `rawQuery()` - Execute raw SQL query

#### CRUD Operations
- `insertRecord()` - Insert data
- `updateRecord()` - Update by ID
- `updateRecordWhere()` - Update with WHERE
- `deleteRecord()` - Delete by ID
- `deleteRecordWhere()` - Delete with WHERE
- `deleteAllRecords()` - Delete all from table

#### Advanced Operations
- `batch()` - Batch operations
- `transaction()` - Transaction
- `rawExecute()` - Execute raw SQL

### Contoh Penggunaan

```dart
final manager = DaoManager();

// Get all tables
final tables = await manager.getAllTableNames();

// Count records
final count = await manager.countRecords('pohon');

// Query with pagination
final data = await manager.queryTablePaginated(
  'pohon',
  limit: 20,
  offset: 0,
  orderBy: 'blok ASC',
);

// Batch operations
await manager.batch([
  DatabaseOperation(
    table: 'pohon',
    type: OperationType.insert,
    data: pohon1.toMap(),
  ),
  DatabaseOperation(
    table: 'pohon',
    type: OperationType.insert,
    data: pohon2.toMap(),
  ),
]);
```

---

## 🎯 Common Patterns

### 1. Batch Insert (Efisien untuk Banyak Data)

```dart
// ❌ TIDAK EFISIEN (loop)
for (var item in items) {
  await dao.insert(item);
}

// ✅ EFISIEN (batch)
await dao.insertBatch(items);
```

### 2. Flag Sync Pattern

```dart
// Get unsynced data
final unsynced = await dao.getAllByFlag();

// Sync to server
for (var item in unsynced) {
  await api.sync(item);
  // Update flag after success
  await dao.updateFlag(item.id);
}
```

### 3. ConflictAlgorithm.replace

Semua DAO menggunakan `ConflictAlgorithm.replace`:
- Jika data sudah ada (PK sama) → UPDATE
- Jika data belum ada → INSERT

```dart
await db.insert(
  'table',
  data.toMap(),
  conflictAlgorithm: ConflictAlgorithm.replace,
);
```

---

## 📋 Import Statements

Semua DAO menggunakan **relative imports**:

```dart
import '../plantdb/db_helper.dart';        // Database helper
import '../mvc_models/model_name.dart';    // Model class
import 'package:sqflite/sqflite.dart';     // SQLite package
```

---

## 🔄 DAO dengan Flag Sinkronisasi

4 DAO memiliki method `getAllByFlag()` dan `updateFlag()`:

| DAO | Table | Flag Column |
|-----|-------|-------------|
| AuditLogDao | auditlog | flag |
| KesehatanDao | kesehatan | flag |
| ReposisiDao | reposisi | flag |
| TaskExecutionDao | eksekusi | flag |

---

## ⚠️ Best Practices

### ✅ DO:
- Gunakan **batch insert** untuk banyak data
- Gunakan `ConflictAlgorithm.replace` untuk upsert
- Update flag setelah sync berhasil
- Gunakan transaction untuk multiple operations
- Handle null dengan `?` operator

### ❌ DON'T:
- Jangan gunakan loop untuk insert banyak data
- Jangan lupa update flag setelah sync
- Jangan hardcode table names (gunakan constant)
- Jangan lupa handle error dengan try-catch

---

## 🔧 Error Handling

```dart
try {
  await dao.insertPohon(pohon);
} catch (e) {
  print('Error inserting pohon: $e');
  // Handle error
}
```

---

## 📊 Performance Tips

1. **Batch Operations**: Gunakan batch untuk insert/update banyak data
2. **Indexing**: Pastikan primary key dan foreign key ter-index
3. **Pagination**: Gunakan limit/offset untuk data besar
4. **Transaction**: Gunakan transaction untuk operasi multiple
5. **Close Connection**: Database connection di-manage oleh DBHelper (singleton)

---

## 🔗 Relasi dengan Components Lain

```
DAO Layer
    ↓
DBHelper (Singleton)
    ↓
SQLite Database (plantdb.db)

DAO Layer
    ↑
Service Layer (mvc_services)
    ↑
UI Layer (screens)
```

---

## 📞 Support

Untuk pertanyaan atau issue terkait DAO classes, silakan hubungi tim development.

**Last Updated:** 2024-12-12  
**Total DAO Classes:** 9 classes  
**Database:** SQLite (plantdb.db)  
**Minimum Android SDK:** 28 (Android 9 - Pie)
