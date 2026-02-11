-- Auto-generated stubs for missing base tables used by view dependencies
-- Review before running in production

CREATE SCHEMA IF NOT EXISTS dbo;
CREATE TABLE IF NOT EXISTS dbo.petugas_lahan (
  id_penugasan TEXT NOT NULL,
  id_petugas TEXT NOT NULL,
  jenis_lahan TEXT NOT NULL,
  kode_lahan TEXT NOT NULL,
  tanggal_mulai TIMESTAMP,
  tanggal_selesai DATE
);

CREATE SCHEMA IF NOT EXISTS dbo;
CREATE TABLE IF NOT EXISTS dbo.ref_code (
  kode NUMERIC(38,0) NOT NULL,
  istilah TEXT NOT NULL,
  nama_error TEXT NOT NULL,
  keterangan TEXT,
  jenis TEXT
);

CREATE SCHEMA IF NOT EXISTS dbo;
CREATE TABLE IF NOT EXISTS dbo.reposisi_pohon (
  id_reposisi TEXT NOT NULL,
  id_tanaman TEXT,
  pohon_awal INTEGER NOT NULL,
  baris_awal INTEGER NOT NULL,
  pohon_tujuan INTEGER NOT NULL,
  baris_tujuan INTEGER NOT NULL,
  keterangan TEXT,
  petugas TEXT,
  from_date TIMESTAMP NOT NULL,
  thru_date TIMESTAMP,
  tipe_riwayat TEXT,
  blok TEXT
);

CREATE SCHEMA IF NOT EXISTS dbo;
CREATE TABLE IF NOT EXISTS dbo.stand_per_row (
  id_spr TEXT NOT NULL,
  blok TEXT,
  nbaris INTEGER NOT NULL,
  spr_awal INTEGER NOT NULL,
  spr_akhir INTEGER NOT NULL,
  keterangan TEXT,
  petugas TEXT,
  from_date TIMESTAMP NOT NULL,
  thru_date TIMESTAMP
);
