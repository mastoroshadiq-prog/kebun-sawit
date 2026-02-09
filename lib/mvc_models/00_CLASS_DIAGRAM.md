# Class Diagram - Model Classes

## 📊 Class Structure Diagram

```mermaid
classDiagram
    class Assignment {
        +String id
        +String spkNumber
        +String taskName
        +String estate
        +String division
        +String block
        +String rowNumber
        +String treeNumber
        +String petugas
        +toMap() Map~String, dynamic~
        +fromMap(Map) Assignment
        +fullLocation String
        +location String
    }
    
    class AuditLog {
        +String idAudit
        +String userId
        +String action
        +String detail
        +String logDate
        +String device
        +int flag
        +toMap() Map~String, dynamic~
        +fromMap(Map) AuditLog
    }
    
    class TaskExecution {
        +String id
        +String spkNumber
        +String taskName
        +String taskState
        +String petugas
        +String taskDate
        +int flag
        +String keterangan
        +String? imagePath
        +toMap() Map~String, dynamic~
        +fromMap(Map) TaskExecution
    }
    
    class Info {
        +String kode
        +String istilah
        +String namaError
        +String keterangan
        +String jenis
        +toMap() Map~String, dynamic~
        +fromMap(Map) Info
    }
    
    class Kesehatan {
        +String idKesehatan
        +String idTanaman
        +String statusAwal
        +String statusAkhir
        +String kodeStatus
        +String jenisPohon
        +String keterangan
        +String petugas
        +String fromDate
        +int flag
        +toMap() Map~String, dynamic~
        +fromMap(Map) Kesehatan
    }
    
    class Petugas {
        +String akun
        +String nama
        +String kontak
        +String peran
        +String lastSync
        +toMap() Map~String, dynamic~
        +fromMap(Map) Petugas
    }
    
    class Pohon {
        +String blok
        +String nbaris
        +String npohon
        +String objectId
        +String status
        +String nflag
        +toMap() Map~String, dynamic~
        +fromMap(Map) Pohon
    }
    
    class Reposisi {
        +String idReposisi
        +String idTanaman
        +String pohonAwal
        +String barisAwal
        +String pohonTujuan
        +String barisTujuan
        +String keterangan
        +String tipeRiwayat
        +String petugas
        +int flag
        +toMap() Map~String, dynamic~
        +fromMap(Map) Reposisi
    }
    
    class Riwayat {
        +String id
        +String objectId
        +String tanggal
        +String jenis
        +String keterangan
        +String status
        +toMap() Map~String, dynamic~
        +fromMap(Map) Riwayat
    }
    
    %% Relasi
    Petugas "1" --> "*" Assignment : ditugaskan
    Petugas "1" --> "*" TaskExecution : melakukan
    Petugas "1" --> "*" Kesehatan : mencatat
    Petugas "1" --> "*" Reposisi : melakukan
    Petugas "1" --> "*" AuditLog : membuat
    
    Pohon "1" --> "*" Riwayat : memiliki
    Pohon "1" --> "*" Kesehatan : status
    Pohon "1" --> "*" Reposisi : direposisi
    
    Assignment "1" --> "*" TaskExecution : dikerjakan
```

## 📋 Penjelasan Relasi

### Petugas → Assignment (One to Many)
- Satu petugas dapat memiliki banyak assignment
- Property: `Assignment.petugas` → `Petugas.akun`

### Petugas → TaskExecution (One to Many)
- Satu petugas dapat melakukan banyak eksekusi tugas
- Property: `TaskExecution.petugas` → `Petugas.akun`

### Petugas → Kesehatan (One to Many)
- Satu petugas dapat mencatat banyak status kesehatan
- Property: `Kesehatan.petugas` → `Petugas.akun`

### Petugas → Reposisi (One to Many)
- Satu petugas dapat melakukan banyak reposisi
- Property: `Reposisi.petugas` → `Petugas.akun`

### Petugas → AuditLog (One to Many)
- Satu petugas dapat membuat banyak audit log
- Property: `AuditLog.userId` → `Petugas.akun`

### Pohon → Riwayat (One to Many)
- Satu pohon dapat memiliki banyak riwayat
- Property: `Riwayat.objectId` → `Pohon.objectId`

### Pohon → Kesehatan (One to Many)
- Satu pohon dapat memiliki banyak catatan kesehatan
- Property: `Kesehatan.idTanaman` → `Pohon.objectId`

### Pohon → Reposisi (One to Many)
- Satu pohon dapat direposisi berkali-kali
- Property: `Reposisi.idTanaman` → `Pohon.objectId`

### Assignment → TaskExecution (One to Many)
- Satu assignment dapat memiliki banyak eksekusi
- Property: `TaskExecution.spkNumber` → `Assignment.spkNumber`

---

## 🎯 Kategori Model

### Data Master (3 models)
```mermaid
graph LR
    A[Petugas] --> B[Assignment]
    A --> C[Pohon]
```

### Data Operasional (4 models)
```mermaid
graph LR
    A[TaskExecution] --> B[Kesehatan]
    B --> C[Reposisi]
    C --> D[Riwayat]
```

### Supporting Data (2 models)
```mermaid
graph LR
    A[AuditLog] --> B[Info]
```

---

## 🔄 Model dengan Flag Sinkronisasi

```mermaid
graph TD
    A[Models dengan Flag] --> B[TaskExecution]
    A --> C[Kesehatan]
    A --> D[Reposisi]
    A --> E[AuditLog]
    
    B --> F[flag: 0 = Belum Sync]
    B --> G[flag: 1 = Sudah Sync]
    C --> F
    C --> G
    D --> F
    D --> G
    E --> F
    E --> G
```

---

## 📊 Properties Count

| Model | Total Properties | Required | Nullable | Flag |
|-------|------------------|----------|----------|------|
| Assignment | 9 | 9 | 0 | ❌ |
| AuditLog | 7 | 7 | 0 | ✅ |
| TaskExecution | 9 | 8 | 1 | ✅ |
| Info | 5 | 5 | 0 | ❌ |
| Kesehatan | 10 | 10 | 0 | ✅ |
| Petugas | 5 | 5 | 0 | ❌ |
| Pohon | 6 | 6 | 0 | ❌ |
| Reposisi | 10 | 10 | 0 | ✅ |
| Riwayat | 6 | 6 | 0 | ❌ |

---

## 🏗️ Inheritance & Composition

Semua model classes **tidak menggunakan inheritance** (flat structure). Setiap model adalah independent class dengan:
- Properties sendiri
- Method `toMap()` untuk serialization
- Factory method `fromMap()` untuk deserialization

---

## 🔗 Database Table Mapping

| Model Class | Database Table | Primary Key |
|-------------|----------------|-------------|
| Assignment | assignment | id |
| AuditLog | auditlog | id_audit |
| TaskExecution | eksekusi | id |
| Info | - | - |
| Kesehatan | kesehatan | idKesehatan |
| Petugas | petugas | akun |
| Pohon | pohon | objectId |
| Reposisi | reposisi | idReposisi |
| Riwayat | riwayat | id |

**Note:** Model `Info` tidak memiliki tabel database dedicated (digunakan untuk error handling/info display)

---

## 📝 Common Methods

Semua model (kecuali helper functions di Pohon) memiliki 2 method standar:

### 1. toMap()
Konversi object ke Map untuk disimpan ke database

```dart
Map<String, dynamic> toMap() {
  return {
    'property1': value1,
    'property2': value2,
    // ...
  };
}
```

### 2. fromMap()
Factory method untuk membuat object dari Map (dari database)

```dart
factory ModelName.fromMap(Map<String, dynamic> map) {
  return ModelName(
    property1: map['property1'] ?? defaultValue,
    property2: map['property2'] ?? defaultValue,
    // ...
  );
}
```

---

## 🎨 Special Features

### Assignment
- Computed property `fullLocation`
- Computed property `location`

### Pohon
- Helper function `groupByBaris()`
- Helper function `generateDataGrid()`
- Helper function `generateHorizontalGrid()`
- Helper function `generateNumberAlignedGrid()`
- Const constructor untuk optimization

### TaskExecution
- Nullable property `imagePath`

---

## ⚠️ Important Notes

1. **No Foreign Key Constraints**: Relasi dijaga di application layer
2. **Immutability**: Semua properties menggunakan `final`
3. **Null Safety**: Default values di `fromMap()` untuk handle null
4. **Type Safety**: Semua properties memiliki type yang jelas
5. **Naming Convention**: camelCase di Dart, snake_case di database (untuk beberapa model)
