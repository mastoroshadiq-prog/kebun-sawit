# SQL Server Inventory

- Total schema: 2
- Total table: 34

## Schema: apk

### Table: audit_log
- PK: id_audit

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_audit | nvarchar | NO | NO |
| 2 | user_id | nvarchar | NO | NO |
| 3 | action | nvarchar | NO | NO |
| 4 | detail | nvarchar | YES | NO |
| 5 | log_date | datetime | NO | NO |
| 6 | device | nvarchar | YES | NO |

## Schema: dbo

### Table: atribut_pihak
- PK: id_atribut

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_atribut | nvarchar | NO | NO |
| 2 | kode_pihak | nvarchar | YES | NO |
| 3 | kode_atr | nvarchar | YES | NO |
| 4 | disp_atr | nvarchar | YES | NO |
| 5 | nilai | nvarchar | YES | NO |
| 6 | seq | int | YES | NO |
| 7 | kategori | nvarchar | YES | NO |

### Table: kebun_n_pokok
- PK: id_npokok

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_npokok | nvarchar | NO | NO |
| 2 | id_tanaman | nvarchar | NO | NO |
| 3 | id_tipe | nvarchar | NO | NO |
| 4 | n_baris | int | NO | NO |
| 5 | n_pokok | int | NO | NO |
| 6 | tgl_tanam | date | NO | NO |
| 7 | petugas | nvarchar | YES | NO |
| 8 | from_date | datetime | NO | NO |
| 9 | thru_date | datetime | YES | NO |
| 10 | catatan | nvarchar | YES | NO |
| 11 | kode | nvarchar | YES | NO |

### Table: kebun_observasi
- PK: id_observasi

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_observasi | nvarchar | NO | NO |
| 2 | id_tanaman | nvarchar | NO | NO |
| 3 | id_ancak | nvarchar | NO | NO |
| 4 | ndre | decimal | YES | NO |
| 5 | ndvi | decimal | YES | NO |
| 6 | evi | decimal | YES | NO |
| 7 | gndvi | decimal | YES | NO |
| 8 | tanggal | datetime | NO | NO |
| 9 | petugas | nvarchar | YES | NO |

### Table: kesehatan_pohon
- PK: id_kesehatan

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_kesehatan | nvarchar | NO | NO |
| 2 | id_tanaman | nvarchar | YES | NO |
| 3 | status_awal | int | NO | NO |
| 4 | status_akhir | int | NO | NO |
| 5 | kode_status | nvarchar | YES | NO |
| 6 | keterangan | nvarchar | YES | NO |
| 7 | petugas | nvarchar | YES | NO |
| 8 | from_date | datetime | NO | NO |
| 9 | thru_date | datetime | YES | NO |
| 10 | jenis | nvarchar | YES | NO |

### Table: master_ancak
- PK: id_ancak

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_ancak | nvarchar | NO | NO |
| 2 | kode_ancak | nvarchar | YES | NO |
| 3 | nama_ancak | nvarchar | YES | NO |
| 4 | kode_blok | varchar | NO | NO |
| 5 | n_awal | int | NO | NO |
| 6 | n_akhir | int | NO | NO |
| 7 | n_baris | int | NO | NO |
| 8 | keterangan | nvarchar | YES | NO |
| 9 | from_date | datetime | NO | NO |
| 10 | thru_date | datetime | YES | NO |
| 11 | petugas | nvarchar | YES | NO |

### Table: master_lahan
- PK: id_lahan

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_lahan | nvarchar | NO | NO |
| 2 | nama_lahan | nvarchar | NO | NO |
| 3 | kode_tipe | nvarchar | NO | NO |
| 4 | kode_induk | nvarchar | YES | NO |
| 5 | nilai | decimal | YES | NO |
| 6 | satuan | nvarchar | YES | NO |
| 8 | keterangan | varchar | YES | NO |

### Table: master_lahan_tipe
- PK: kode_tipe

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | kode_tipe | nvarchar | NO | NO |
| 2 | nama_tipe | nvarchar | NO | NO |
| 3 | deskripsi | nvarchar | YES | NO |

### Table: master_pihak
- PK: id_pihak

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_pihak | nvarchar | NO | NO |
| 2 | tipe | nvarchar | YES | NO |
| 3 | nama | nvarchar | YES | NO |
| 4 | kode_unik | nvarchar | YES | NO |
| 5 | id_induk | nvarchar | YES | NO |
| 6 | alias | nvarchar | YES | NO |
| 7 | id_unik | nvarchar | YES | NO |
| 8 | jenis_id | nvarchar | YES | NO |

### Table: master_standar_vegetasi
- PK: id_standar

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_standar | nvarchar | NO | NO |
| 2 | nama_indeks | nvarchar | NO | NO |
| 3 | kode_kelas | nvarchar | NO | NO |
| 4 | nama_kelas | nvarchar | NO | NO |
| 5 | deskripsi | nvarchar | YES | NO |
| 6 | indeks_min | decimal | NO | NO |
| 7 | indeks_max | decimal | NO | NO |
| 8 | saran_aksi | nvarchar | YES | NO |
| 9 | from_date | datetime | YES | NO |
| 10 | thru_date | datetime | YES | NO |

### Table: ops_eksekusi_tindakan
- PK: id_eksekusi_tindakan

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_eksekusi_tindakan | nvarchar | NO | NO |
| 2 | id_jadwal_tindakan | nvarchar | YES | NO |
| 3 | tanggal_eksekusi | date | NO | NO |
| 4 | hasil | nvarchar | YES | NO |
| 5 | petugas | nvarchar | YES | NO |
| 6 | catatan | nvarchar | YES | NO |
| 7 | created_at | datetime | NO | NO |
| 8 | updated_at | datetime | YES | NO |
| 9 | id_spk | nvarchar | YES | NO |

### Table: ops_fase_besar
- PK: id_fase_besar

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_fase_besar | nvarchar | NO | NO |
| 2 | nama_fase | nvarchar | NO | NO |
| 3 | umur_mulai | int | YES | NO |
| 4 | umur_selesai | int | YES | NO |
| 5 | deskripsi | nvarchar | YES | NO |
| 6 | created_at | datetime | NO | NO |
| 7 | updated_at | datetime | YES | NO |

### Table: ops_jadwal_tindakan
- PK: id_jadwal_tindakan

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_jadwal_tindakan | nvarchar | NO | NO |
| 2 | id_tanaman | nvarchar | YES | NO |
| 3 | id_sub_tindakan | nvarchar | YES | NO |
| 4 | frekuensi | nvarchar | NO | NO |
| 5 | interval_hari | int | YES | NO |
| 6 | tanggal_mulai | datetime | NO | NO |
| 7 | tanggal_selesai | date | YES | NO |
| 8 | created_at | datetime | NO | NO |
| 9 | updated_at | datetime | YES | NO |

### Table: ops_spk_tindakan
- PK: id_spk

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_spk | nvarchar | NO | NO |
| 2 | id_jadwal_tindakan | nvarchar | YES | NO |
| 3 | nomor_spk | nvarchar | NO | NO |
| 4 | tanggal_terbit | date | NO | NO |
| 5 | tanggal_mulai | date | NO | NO |
| 6 | tanggal_selesai | date | YES | NO |
| 7 | status | nvarchar | NO | NO |
| 8 | penanggung_jawab | nvarchar | YES | NO |
| 9 | mandor | nvarchar | YES | NO |
| 10 | lokasi | nvarchar | YES | NO |
| 11 | uraian_pekerjaan | nvarchar | YES | NO |
| 12 | catatan | nvarchar | YES | NO |
| 13 | created_at | datetime | NO | NO |
| 14 | updated_at | datetime | YES | NO |

### Table: ops_sub_tindakan
- PK: id_sub_tindakan

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_sub_tindakan | nvarchar | NO | NO |
| 2 | id_fase_besar | nvarchar | YES | NO |
| 3 | nama_sub | nvarchar | NO | NO |
| 4 | deskripsi | nvarchar | YES | NO |
| 5 | created_at | datetime | NO | NO |
| 6 | updated_at | datetime | YES | NO |

### Table: petugas_lahan
- PK: id_penugasan

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_penugasan | nvarchar | NO | NO |
| 2 | id_petugas | nvarchar | NO | NO |
| 3 | jenis_lahan | nvarchar | NO | NO |
| 4 | kode_lahan | nvarchar | NO | NO |
| 5 | tanggal_mulai | datetime | YES | NO |
| 6 | tanggal_selesai | date | YES | NO |

### Table: pihak_peran
- PK: kode_pihak, tipe_peran

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | kode_pihak | nvarchar | NO | NO |
| 2 | tipe_peran | nvarchar | NO | NO |
| 3 | from_date | datetime | YES | NO |
| 4 | from_by | nvarchar | YES | NO |
| 5 | thru_date | datetime | YES | NO |
| 6 | thru_by | nvarchar | YES | NO |

### Table: pihak_posisi
- PK: id_posisi

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_posisi | nvarchar | NO | NO |
| 2 | kode_org | nvarchar | YES | NO |
| 3 | kode_tipe | nvarchar | YES | NO |
| 4 | gaji | nvarchar | YES | NO |
| 5 | exempt | nvarchar | YES | NO |
| 6 | fulltime | nvarchar | YES | NO |
| 7 | temporary | nvarchar | YES | NO |
| 8 | est_from | datetime | YES | NO |
| 9 | est_thru | datetime | YES | NO |
| 10 | act_from | datetime | YES | NO |
| 11 | act_thru | datetime | YES | NO |
| 12 | id_bdg | nvarchar | YES | NO |
| 13 | bdg_item | nvarchar | YES | NO |
| 14 | bdg_rev_seq | numeric | YES | NO |

### Table: pihak_relasi
- PK: id_relasi

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_relasi | nvarchar | NO | NO |
| 2 | pihak_i | nvarchar | NO | NO |
| 3 | peran_i | nvarchar | NO | NO |
| 4 | pihak_ii | nvarchar | NO | NO |
| 5 | peran_ii | nvarchar | NO | NO |
| 6 | kode_relasi | nvarchar | NO | NO |
| 7 | status_relasi | varchar | NO | NO |
| 8 | keterangan | nvarchar | YES | NO |
| 9 | grup | nvarchar | YES | NO |
| 10 | from_date | datetime | YES | NO |
| 11 | from_by | nvarchar | YES | NO |
| 12 | thru_date | datetime | YES | NO |
| 13 | thru_by | nvarchar | YES | NO |

### Table: pihak_tipe_peran
- PK: kode_tipe

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | kode_tipe | nvarchar | NO | NO |
| 2 | keterangan | nvarchar | YES | NO |
| 3 | id_pemilik | nvarchar | YES | NO |
| 4 | kategori | nvarchar | YES | NO |
| 5 | seq | int | YES | NO |
| 6 | tipe_pihak | nvarchar | YES | NO |

### Table: pihak_tipe_posisi
- PK: kode_tipe

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | kode_tipe | nvarchar | NO | NO |
| 2 | keterangan | ntext | YES | NO |
| 3 | titel | ntext | YES | NO |
| 4 | kode_pemilik | nvarchar | YES | NO |
| 5 | tunjangan | numeric | YES | NO |

### Table: posisi_histori
- PK: id_histori

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_histori | nvarchar | NO | NO |
| 2 | id_poisisi | nvarchar | YES | NO |
| 3 | kode_pihak | nvarchar | YES | NO |
| 4 | from_date | datetime | YES | NO |
| 5 | thru_date | datetime | YES | NO |
| 6 | ph_komen | ntext | YES | NO |

### Table: posisi_struktur
- PK: id_struktur

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_struktur | nvarchar | NO | NO |
| 2 | id_posisi | nvarchar | YES | NO |
| 3 | posisi_tujuan | nvarchar | YES | NO |
| 4 | from_date | datetime | YES | NO |
| 5 | thru_date | datetime | YES | NO |
| 6 | ps_komen | ntext | YES | NO |
| 7 | primary_flag | nvarchar | YES | NO |

### Table: posisi_tupoksi
- PK: id_ptupoksi

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_ptupoksi | nvarchar | NO | NO |
| 2 | id_posisi | nvarchar | YES | NO |
| 3 | kode_tupoksi | nvarchar | YES | NO |
| 4 | from_date | datetime | YES | NO |
| 5 | thru_date | datetime | YES | NO |
| 6 | ptu_komen | ntext | YES | NO |

### Table: ref_code
- PK: kode

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | kode | numeric | NO | NO |
| 2 | istilah | nvarchar | NO | NO |
| 3 | nama_error | nvarchar | NO | NO |
| 4 | keterangan | nvarchar | YES | NO |
| 5 | jenis | nvarchar | YES | NO |

### Table: reposisi_pohon
- PK: id_reposisi

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_reposisi | nvarchar | NO | NO |
| 2 | id_tanaman | nvarchar | YES | NO |
| 3 | pohon_awal | int | NO | NO |
| 4 | baris_awal | int | NO | NO |
| 5 | pohon_tujuan | int | NO | NO |
| 6 | baris_tujuan | int | NO | NO |
| 7 | keterangan | nvarchar | YES | NO |
| 8 | petugas | nvarchar | YES | NO |
| 9 | from_date | datetime | NO | NO |
| 10 | thru_date | datetime | YES | NO |
| 11 | tipe_riwayat | nvarchar | YES | NO |
| 12 | blok | nvarchar | YES | NO |

### Table: sop_referensi
- PK: id_sop

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_sop | varchar | NO | NO |
| 2 | id_tipe_sop | varchar | YES | NO |
| 3 | nama_sop | varchar | NO | NO |
| 4 | deskripsi | text | YES | NO |
| 5 | created_at | datetime | NO | NO |
| 6 | updated_at | datetime | YES | NO |

### Table: sop_referensi_versi
- PK: id_sop_referensi_versi

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_sop_referensi_versi | varchar | NO | NO |
| 2 | id_sop | varchar | YES | NO |
| 3 | versi | varchar | NO | NO |
| 4 | from_date | date | NO | NO |
| 5 | thru_date | date | YES | NO |
| 6 | dok_url | varchar | YES | NO |
| 7 | catatan | text | YES | NO |
| 8 | created_at | datetime | NO | NO |
| 9 | updated_at | datetime | YES | NO |

### Table: sop_tipe
- PK: id_tipe_sop

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_tipe_sop | varchar | NO | NO |
| 2 | nama_tipe_sop | varchar | NO | NO |
| 3 | deskripsi | text | YES | NO |
| 4 | created_at | datetime | NO | NO |
| 5 | updated_at | datetime | YES | NO |

### Table: sop_tipe_versi
- PK: id_tipe_sop_versi

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_tipe_sop_versi | varchar | NO | NO |
| 2 | id_tipe_sop | varchar | YES | NO |
| 3 | versi | varchar | NO | NO |
| 4 | tgl_versi | date | NO | NO |
| 5 | from_date | date | NO | NO |
| 6 | thru_date | date | YES | NO |
| 7 | dok_url | varchar | YES | NO |
| 8 | catatan | text | YES | NO |
| 9 | created_at | datetime | NO | NO |
| 10 | updated_at | datetime | YES | NO |

### Table: stand_per_row
- PK: id_spr

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_spr | nvarchar | NO | NO |
| 2 | blok | nvarchar | YES | NO |
| 3 | nbaris | int | NO | NO |
| 4 | spr_awal | int | NO | NO |
| 5 | spr_akhir | int | NO | NO |
| 6 | keterangan | nvarchar | YES | NO |
| 7 | petugas | nvarchar | YES | NO |
| 8 | from_date | datetime | NO | NO |
| 9 | thru_date | datetime | YES | NO |

### Table: task_execution
- PK: execid

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | execid | nvarchar | NO | NO |
| 2 | spk_number | nvarchar | NO | NO |
| 3 | task_name | nvarchar | NO | NO |
| 4 | task_state | nvarchar | NO | NO |
| 5 | petugas | nvarchar | NO | NO |
| 6 | task_date | datetime | NO | NO |
| 7 | keterangan | nvarchar | YES | NO |
| 8 | img_file | text | YES | NO |

### Table: tupoksi_tipe
- PK: kode_tipe

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | kode_tipe | nvarchar | NO | NO |
| 2 | keterangan | ntext | YES | NO |

### Table: tupoksi_valid
- PK: id_tvalid

| # | Column | Type | Nullable | Identity |
|---|--------|------|----------|----------|
| 1 | id_tvalid | nvarchar | NO | NO |
| 2 | koed_posisi | nvarchar | YES | NO |
| 3 | kode_tupoksi | nvarchar | YES | NO |
| 4 | from_date | datetime | YES | NO |
| 5 | thru_date | datetime | YES | NO |
| 6 | tval_komen | ntext | YES | NO |
