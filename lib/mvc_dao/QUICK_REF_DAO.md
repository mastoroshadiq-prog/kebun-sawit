# Quick Reference - DAO Classes

## 🚀 Quick Start

```dart
import 'package:flutter_project/mvc_dao/dao_assignment.dart';
import 'package:flutter_project/mvc_dao/dao_audit_log.dart';
import 'package:flutter_project/mvc_dao/dao_kesehatan.dart';
import 'package:flutter_project/mvc_dao/dao_petugas.dart';
import 'package:flutter_project/mvc_dao/dao_pohon.dart';
import 'package:flutter_project/mvc_dao/dao_reposisi.dart';
import 'package:flutter_project/mvc_dao/dao_riwayat.dart';
import 'package:flutter_project/mvc_dao/dao_task_execution.dart';
import 'package:flutter_project/mvc_dao/dao_manager.dart';
```

---

## 📊 DAO Summary

| DAO | Table | Model | Flag | Methods |
|-----|-------|-------|------|---------|
| AssignmentDao | assignment | Assignment | ❌ | 8 |
| AuditLogDao | auditlog | AuditLog | ✅ | 6 |
| KesehatanDao | kesehatan | Kesehatan | ✅ | 9 |
| PetugasDao | petugas | Petugas | ❌ | 5 |
| PohonDao | pohon | Pohon | ❌ | 6 |
| ReposisiDao | reposisi | Reposisi | ✅ | 7 |
| RiwayatDao | riwayat | Riwayat | ❌ | 4 |
| TaskExecutionDao | eksekusi | TaskExecution | ✅ | 9 |
| DaoManager | All | Generic | - | 20+ |

---

## 💾 CRUD Operations

### Insert Single
```dart
final dao = PohonDao();
await dao.insertPohon(pohon);
```

### Insert Batch (Efficient)
```dart
await dao.insertPohonBatch(pohonList);
```

### Get All
```dart
final list = await dao.getAllPohon();
```

### Get By ID
```dart
final pohon = await dao.getPohonById('POH-001');
```

### Update
```dart
await dao.updatePohon(updatedPohon);
```

### Delete
```dart
await dao.deletePohon('POH-001');
```

### Delete All
```dart
await dao.deleteAllPohon();
```

---

## 🔄 Flag Sync Operations

### Get Unsynced Data
```dart
final unsynced = await dao.getAllByFlag(); // flag = 0
```

### Update Flag After Sync
```dart
await dao.updateFlag(id); // set flag = 1
```

### Sync Pattern
```dart
// 1. Get unsynced
final unsynced = await dao.getAllByFlag();

// 2. Sync to server
for (var item in unsynced) {
  await api.sync(item);
  
  // 3. Update flag
  await dao.updateFlag(item.id);
}
```

---

## 🎯 Common Patterns

### Batch Insert (Best Performance)
```dart
// ✅ GOOD - Batch
await dao.insertPohonBatch(pohonList);

// ❌ BAD - Loop
for (var pohon in pohonList) {
  await dao.insertPohon(pohon);
}
```

### Upsert (Insert or Update)
```dart
// ConflictAlgorithm.replace = upsert
await dao.insertPohon(pohon); // auto insert or update
```

### Transaction
```dart
final db = await DBHelper().database;
await db.transaction((txn) async {
  await txn.insert('pohon', pohon1.toMap());
  await txn.insert('pohon', pohon2.toMap());
});
```

---

## 📝 Specific DAO Examples

### AssignmentDao
```dart
final dao = AssignmentDao();

// Batch insert
await dao.insertAssignmentsBatch(assignments);

// Get by ID
final assignment = await dao.getAssignmentById('ASG-001');
```

### AuditLogDao
```dart
final dao = AuditLogDao();

// Create log (auto device info)
await dao.createLog('INSERT', '{"table":"pohon"}');

// Get unsynced
final logs = await dao.getAllByFlag();
```

### PetugasDao
```dart
final dao = PetugasDao();

// Get current petugas
final petugas = await dao.getPetugas();

// Update last sync
await dao.updateLastSync(
  'PTG-001',
  DateTime.now().toString(),
);
```

### RiwayatDao
```dart
final dao = RiwayatDao();

// Get riwayat by pohon
final riwayat = await dao.getRiwayatByObjectId('POH-001');
```

### DaoManager
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
);
```

---

## 🔧 Error Handling

```dart
try {
  await dao.insertPohon(pohon);
} catch (e) {
  print('Error: $e');
  // Handle error
}
```

---

## ⚡ Performance Tips

| Tip | Description |
|-----|-------------|
| **Batch Insert** | Use batch for > 10 records |
| **Transaction** | Use for multiple operations |
| **Pagination** | Use limit/offset for large data |
| **Index** | Ensure PK/FK are indexed |

---

## 📋 Method Naming Conventions

| Pattern | Example | Description |
|---------|---------|-------------|
| `insert*()` | `insertPohon()` | Insert single |
| `insert*Batch()` | `insertPohonBatch()` | Insert batch |
| `getAll*()` | `getAllPohon()` | Get all records |
| `get*ById()` | `getPohonById()` | Get by primary key |
| `getAllByFlag()` | `getAllByFlag()` | Get unsynced (flag=0) |
| `update*()` | `updatePohon()` | Update record |
| `updateFlag()` | `updateFlag()` | Set flag = 1 |
| `delete*()` | `deletePohon()` | Delete by ID |
| `deleteAll*()` | `deleteAllPohon()` | Delete all |

---

## 🔗 Quick Links

- [Full Documentation](README_DAO)
- [Database Documentation](../plantdb/README_db_helper.md)
- [Models Documentation](../mvc_models/03_README_models)

---

## ⚠️ Important Notes

✅ **DO:**
- Use batch for bulk operations
- Update flag after successful sync
- Use try-catch for error handling
- Use ConflictAlgorithm.replace for upsert

❌ **DON'T:**
- Don't use loop for many inserts
- Don't forget to update flag
- Don't hardcode table names
- Don't forget null checks
