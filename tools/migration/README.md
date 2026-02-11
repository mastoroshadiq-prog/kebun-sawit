# SQL Server -> Supabase Migration (Python)

Script utama: `tools/migration/sqlserver_to_supabase.py`

## 1) Prasyarat

- Python 3.10+
- ODBC driver SQL Server (contoh: ODBC Driver 17 for SQL Server)
- Akses database SQL Server sumber
- Akses koneksi Postgres Supabase (DB password, host, port)

Install dependency:

```bash
pip install pyodbc psycopg2-binary
```

## 2) Konfigurasi

1. Copy file contoh:

```bash
copy tools\migration\config.example.json tools\migration\config.json
```

2. Isi kredensial di `tools/migration/config.json`:
- `sqlserver.username`
- `sqlserver.password`
- `supabase_postgres.username`
- `supabase_postgres.password`

3. Opsi simple (disarankan): aktifkan auto mapping tabel dengan `auto_tables.enabled = true`.

Dengan auto mode, Anda tidak perlu isi `tables[]` manual.
Script akan:
- membaca daftar tabel SQL Server,
- mencocokkan tabel target yang sudah ada di Supabase,
- mengambil irisan kolom yang sama,
- melakukan infer mapping sederhana untuk kolom wajib yang beda nama (contoh pola `nama_sub` -> `nama_sub_tindakan`),
- lalu migrasi data otomatis per tabel.

Jika ada kolom target `NOT NULL` tanpa default yang tidak bisa dipetakan, tabel akan di-skip agar tidak gagal di tengah jalan.

## 3) Menjalankan migrasi

```bash
python tools/migration/sqlserver_to_supabase.py --config tools/migration/config.json --batch-size 1000
```

Migrasi view SQL Server juga bisa dijalankan:

```bash
python tools/migration/sqlserver_to_supabase.py --config tools/migration/config.json --migrate-views
```

Atau hanya view saja (tanpa data tabel):

```bash
python tools/migration/sqlserver_to_supabase.py --config tools/migration/config.json --views-only --migrate-views
```

Secara default script akan menggunakan checkpoint file:
- `tools/migration/migration_checkpoint.json`

Checkpoint menyimpan status tiap tabel:
- `running`
- `success`
- `failed`

Jika proses terputus, jalankan command yang sama untuk melanjutkan (resume).

## 4) Alur cepat dengan checkpoint (disarankan)

### A. Initial run (pertama kali)

```bash
python tools/migration/sqlserver_to_supabase.py --config tools/migration/config.json --batch-size 1000 --reset-checkpoint
```

Keterangan:
- `--reset-checkpoint` mengosongkan status lama agar mulai bersih.

### B. Resume setelah terputus/error

```bash
python tools/migration/sqlserver_to_supabase.py --config tools/migration/config.json --batch-size 1000
```

Keterangan:
- Tabel yang sudah `success` akan di-skip otomatis.
- Tabel `failed` / `running` akan dicoba lagi.

### C. Retry tabel gagal saja

Gunakan command resume yang sama (poin B). Karena tabel sukses otomatis di-skip, yang tersisa hanya tabel yang belum sukses.

### D. Ulang total dari nol (full rerun)

```bash
python tools/migration/sqlserver_to_supabase.py --config tools/migration/config.json --batch-size 1000 --reset-checkpoint --no-resume
```

Keterangan:
- `--no-resume` memaksa semua tabel diproses ulang tanpa melihat status `success` di checkpoint.

### E. Lokasi checkpoint custom (opsional)

```bash
python tools/migration/sqlserver_to_supabase.py --config tools/migration/config.json --checkpoint tools/migration/my_checkpoint.json
```

Jika ingin mode manual per tabel, set:
- `auto_tables.enabled = false`
- isi `tables[]` seperti contoh.

## 5) Catatan penting

- Jalankan ke environment staging dulu.
- Jika nama kolom berbeda antara source/target, gunakan `column_mapping`.
- Untuk full replace per tabel, set `truncate_first: true` pada tabel terkait.
- Script ini fokus migrasi data per tabel, bukan konversi otomatis seluruh DDL SQL Server ke PostgreSQL.
- Untuk VIEW, script membuat `CREATE OR REPLACE VIEW` di schema target.
- Translasi otomatis VIEW bersifat basic (contoh: `[col]` -> `"col"`, `ISNULL()` -> `COALESCE()`, `GETDATE()` -> `NOW()`).
- Referensi 3-level SQL Server (`database.schema.object`) otomatis dipangkas ke 2-level (`schema.object`) untuk menghindari error `cross-database references are not implemented` di Postgres.
- Script juga menghapus wrapper seperti `SET ANSI_NULLS`, `SET QUOTED_IDENTIFIER`, `GO`, serta header `CREATE/ALTER VIEW ... AS` sebelum membuat view di Supabase.
- Ditambahkan translasi dasar `CONVERT(NVARCHAR(...), expr)` -> `CAST(expr AS TEXT)`.
- Ditambahkan translasi dasar `CROSS APPLY` -> `CROSS JOIN LATERAL` dan `OUTER APPLY` -> `LEFT JOIN LATERAL`.
- Dependency precheck view aktif secara default (`views.strict_dependency_check=true`) agar error missing relation terdeteksi lebih dini dengan log yang lebih jelas.
- Script menghasilkan report dependency yang belum tersedia di `views.missing_dependency_report` (default: `tools/migration/view_missing_dependencies.json`).
- Untuk kasus mismatch kolom/ekspresi spesifik view, bisa gunakan `views.sql_replacements` (string replace sebelum eksekusi CREATE VIEW).
- Jika definisi VIEW sangat SQL Server-specific, mungkin tetap perlu penyesuaian manual di Supabase.
- Handling NULL ke kolom `NOT NULL` bertipe text/varchar/char:
  - Script otomatis mengisi `NULL` menjadi string kosong `''` untuk mencegah `NotNullViolation`.
  - Jika ingin nilai khusus per kolom, pakai `null_replacements` di konfigurasi tabel.
- Handling duplicate key (`UniqueViolation`):
  - Default mode adalah `conflict_mode: "ignore"` (pakai `ON CONFLICT (PK) DO NOTHING`).
  - Ini aman untuk skenario resume/retry saat sebagian data sudah masuk.

Contoh:

```json
{
  "source_schema": "dbo",
  "source_table": "ops_sub_tindakan",
  "target_schema": "dbo",
  "target_table": "ops_sub_tindakan",
  "conflict_mode": "ignore",
  "null_replacements": {
    "nama_sub_tindakan": "-"
  }
}
```

