-- =====================================================================
-- SQL Server (PLANTDB) -> Supabase PostgreSQL
-- Auto-generated baseline script (manual run in Supabase SQL Editor)
-- NOTE:
-- 1) Fokus untuk menyiapkan struktur tabel (DDL baseline).
-- 2) Tipe data disesuaikan dari SQL Server -> PostgreSQL.
-- 3) PK utama disiapkan. FK/Index lanjutan bisa ditambah bertahap setelah validasi.
-- =====================================================================

create schema if not exists apk;
create schema if not exists dbo;

-- =========================
-- Schema: apk
-- =========================

create table if not exists apk.audit_log (
  id_audit text primary key,
  user_id text not null,
  action text not null,
  detail text null,
  log_date timestamp not null,
  device text null
);

-- =========================
-- Schema: dbo (baseline aplikasi inti + master penting)
-- =========================

create table if not exists dbo.master_pihak (
  id_pihak text primary key,
  tipe text null,
  nama text null,
  kode_unik text null,
  id_induk text null,
  alias text null,
  id_unik text null,
  jenis_id text null
);

create table if not exists dbo.master_lahan_tipe (
  kode_tipe text primary key,
  nama_tipe text not null,
  deskripsi text null
);

create table if not exists dbo.master_lahan (
  id_lahan text primary key,
  nama_lahan text not null,
  kode_tipe text not null,
  kode_induk text null,
  nilai numeric null,
  satuan text null,
  keterangan text null
);

create table if not exists dbo.master_ancak (
  id_ancak text primary key,
  kode_ancak text null,
  nama_ancak text null,
  kode_blok text not null,
  n_awal integer not null,
  n_akhir integer not null,
  n_baris integer not null,
  keterangan text null,
  from_date timestamp not null,
  thru_date timestamp null,
  petugas text null
);

create table if not exists dbo.kebun_n_pokok (
  id_npokok text primary key,
  id_tanaman text not null,
  id_tipe text not null,
  n_baris integer not null,
  n_pokok integer not null,
  tgl_tanam date not null,
  petugas text null,
  from_date timestamp not null,
  thru_date timestamp null,
  catatan text null,
  kode text null
);

create table if not exists dbo.kesehatan_pohon (
  id_kesehatan text primary key,
  id_tanaman text null,
  status_awal integer not null,
  status_akhir integer not null,
  kode_status text null,
  keterangan text null,
  petugas text null,
  from_date timestamp not null,
  thru_date timestamp null,
  jenis text null
);

create table if not exists dbo.kebun_observasi (
  id_observasi text primary key,
  id_tanaman text not null,
  id_ancak text not null,
  ndre numeric null,
  ndvi numeric null,
  evi numeric null,
  gndvi numeric null,
  tanggal timestamp not null,
  petugas text null
);

create table if not exists dbo.master_standar_vegetasi (
  id_standar text primary key,
  nama_indeks text not null,
  kode_kelas text not null,
  nama_kelas text not null,
  deskripsi text null,
  indeks_min numeric not null,
  indeks_max numeric not null,
  saran_aksi text null,
  from_date timestamp null,
  thru_date timestamp null
);

create table if not exists dbo.atribut_pihak (
  id_atribut text primary key,
  kode_pihak text null,
  kode_atr text null,
  disp_atr text null,
  nilai text null,
  seq integer null,
  kategori text null
);

-- =========================
-- Ops (Tindakan / SPK)
-- =========================

create table if not exists dbo.ops_fase_besar (
  id_fase_besar text primary key,
  nama_fase text not null,
  umur_mulai integer null,
  umur_selesai integer null,
  deskripsi text null,
  created_at timestamp not null,
  updated_at timestamp null
);

create table if not exists dbo.ops_sub_tindakan (
  id_sub_tindakan text primary key,
  id_fase_besar text null,
  nama_sub_tindakan text not null,
  kode_sub_tindakan text null,
  deskripsi text null,
  created_at timestamp not null,
  updated_at timestamp null
);

create table if not exists dbo.ops_jadwal_tindakan (
  id_jadwal_tindakan text primary key,
  id_tanaman text null,
  id_sub_tindakan text null,
  frekuensi text not null,
  interval_hari integer null,
  tanggal_mulai timestamp not null,
  tanggal_selesai date null,
  created_at timestamp not null,
  updated_at timestamp null
);

create table if not exists dbo.ops_spk_tindakan (
  id_spk text primary key,
  id_jadwal_tindakan text null,
  nomor_spk text not null,
  tanggal_terbit date not null,
  tanggal_mulai date not null,
  tanggal_selesai date null,
  status text not null,
  penanggung_jawab text null,
  mandor text null,
  lokasi text null,
  uraian_pekerjaan text null,
  catatan text null,
  created_at timestamp not null,
  updated_at timestamp null
);

create table if not exists dbo.ops_eksekusi_tindakan (
  id_eksekusi_tindakan text primary key,
  id_jadwal_tindakan text null,
  tanggal_eksekusi date not null,
  hasil text null,
  petugas text null,
  catatan text null,
  created_at timestamp not null,
  updated_at timestamp null,
  id_spk text null
);

-- =====================================================================
-- TODO tahap berikutnya:
-- - Tambahkan FK sesuai relasi bisnis final.
-- - Tambahkan index query-critical.
-- - Generate tabel sisanya (34 total dari inventory) jika ingin full 1:1.
-- =====================================================================

