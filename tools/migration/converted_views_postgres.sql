-- Auto-generated converted PostgreSQL VIEW DDL from SQL Server schema dbo
CREATE SCHEMA IF NOT EXISTS dbo;

-- Ordered by dependency when possible (dbo view-to-view refs)

-- Source view: dbo.v_assignment
CREATE OR REPLACE VIEW dbo.v_assignment AS
SELECT a.id_spk AS id_task, a.nomor_spk, a.lokasi, 
b.id_tanaman, c.nama_sub_tindakan AS nama_task, 
x.n_baris AS nbaris, d.id_lahan AS blok, d.kode_induk AS divisi, 
e.kode_induk AS estate, a.mandor, x.n_pokok
FROM dbo.ops_spk_tindakan a
LEFT JOIN dbo.ops_jadwal_tindakan b
ON b.id_jadwal_tindakan = a.id_jadwal_tindakan 
LEFT JOIN dbo.ops_sub_tindakan c
ON c.id_sub_tindakan = b.id_sub_tindakan
LEFT JOIN dbo.kebun_n_pokok x
ON x.id_tanaman = b.id_tanaman
LEFT JOIN dbo.master_lahan d 
ON d.keterangan = a.lokasi 
LEFT JOIN dbo.master_lahan e
ON e.id_lahan = d.kode_induk 
WHERE a.status ='DISETUJUI'
;

-- Source view: dbo.v_baris_blok
CREATE OR REPLACE VIEW dbo.v_baris_blok AS
SELECT DISTINCT a.catatan AS blok, a.n_baris
FROM dbo.kebun_n_pokok a
GROUP BY a.catatan , a.n_baris
;

-- Source view: dbo.v_max_reposisi
CREATE OR REPLACE VIEW dbo.v_max_reposisi AS
SELECT
    x.pohon_tujuan,
    x.baris_tujuan,
    MAX(x.from_date) AS tgl_update_terbaru
FROM dbo.reposisi_pohon x
WHERE x.thru_date IS NULL AND x.petugas NOT IN ('simulasi')
GROUP BY x.pohon_tujuan,x.baris_tujuan
;

-- Source view: dbo.v_max_spr
CREATE OR REPLACE VIEW dbo.v_max_spr AS
SELECT
    x.blok,x.spr_awal,
    MAX(x.from_date) AS tgl_update_terbaru
FROM dbo.stand_per_row x
WHERE x.thru_date IS NULL
GROUP BY x.blok,x.spr_awal
;

-- Source view: dbo.v_pohon
CREATE OR REPLACE VIEW dbo.v_pohon AS
SELECT 
	p.id_tanaman AS id_pohon, p.n_baris AS baris_pohon, p.n_pokok AS nomor_pohon, 
	p.catatan AS kode_blok, a.kode_ancak, p.kode, 
	(CASE 
		WHEN p.kode='S' THEN 0 -- SEHAT
		WHEN p.kode='SR' THEN 1 -- STRES RINGAN
		WHEN p.kode='SS' THEN 2 -- STRES SEDANG
		WHEN p.kode='SB' THEN 3 -- STRES BERAT
		WHEN p.kode='SSB' THEN 4 -- STRES SANGAT BERAT
	END) AS status
FROM dbo.kebun_n_pokok p
JOIN dbo.master_ancak a
ON p.n_baris BETWEEN a.n_awal AND a.n_akhir
WHERE p.thru_date IS NULL
;

-- Source view: dbo.v_pohon_tambahan
CREATE OR REPLACE VIEW dbo.v_pohon_tambahan AS
SELECT b.id_pihak, b.nama, b.kode_unik AS mandor, 
a.blok AS kode_lahan, a.blok, a.baris_awal AS baris_lama, a.pohon_awal AS pohon_lama,
a.id_tanaman AS objectId, 1 AS status, a.blok AS block, 1 AS tanda, 
a.baris_tujuan AS nbaris, a.pohon_tujuan AS npohon,
(CASE 
	WHEN a.tipe_riwayat='N' THEN 0
	WHEN a.tipe_riwayat='R' THEN 1
	WHEN a.tipe_riwayat='L' THEN 2
	WHEN a.tipe_riwayat='K' THEN 3
	WHEN a.tipe_riwayat='C' THEN 4
END) AS nflag
FROM dbo.reposisi_pohon a
LEFT JOIN dbo.master_pihak b
ON b.kode_unik = a.petugas 
WHERE a.id_tanaman LIKE 'V-%'
AND a.tipe_riwayat IN ('C', 'N')
AND a.pohon_awal = a.pohon_tujuan 
AND a.baris_awal = a.baris_tujuan 
AND a.petugas NOT IN ('simulasi')
;

-- Source view: dbo.v_pohon_terkini
CREATE OR REPLACE VIEW dbo.v_pohon_terkini AS
SELECT p.kode_ancak, p.kode_blok, p.id_pohon, p.kode, p.status,
(CASE 
	WHEN r.id_reposisi IS NULL THEN p.nomor_pohon ELSE r.pohon_awal
END) AS nomor_pohon,
(CASE 
	WHEN r.id_reposisi IS NULL THEN p.baris_pohon ELSE r.baris_awal
END) AS baris_pohon,
(CASE 
	WHEN r.id_reposisi IS NULL THEN 0 ELSE 1
END) AS p_flag,
(CASE 
	WHEN r.id_reposisi IS NULL THEN p.nomor_pohon ELSE r.pohon_tujuan 
END) AS nomor_terkini,
(CASE 
	WHEN r.id_reposisi IS NULL THEN p.baris_pohon ELSE r.baris_tujuan 
END) AS baris_terkini,
(CASE 
	WHEN r.id_reposisi IS NULL THEN 'N' ELSE r.tipe_riwayat 
END) AS kondisi
FROM dbo.v_pohon p
LEFT JOIN dbo.reposisi_pohon r
ON r.id_tanaman = p.id_pohon AND r.thru_date IS NULL
;

-- Source view: dbo.v_reposisi_terkini
CREATE OR REPLACE VIEW dbo.v_reposisi_terkini AS
SELECT DISTINCT 
a.tgl_update_terbaru,
x.id_tanaman, x.pohon_awal, x.baris_awal, x.pohon_tujuan,
x.baris_tujuan, x.keterangan, x.petugas, x.from_date, x.thru_date, x.tipe_riwayat, x.blok
FROM dbo.v_max_reposisi a
LEFT JOIN dbo.reposisi_pohon x
ON x.from_date = a.tgl_update_terbaru
AND x.pohon_tujuan = a.pohon_tujuan
AND x.baris_tujuan = a.baris_tujuan
AND x.thru_date IS NULL
;

-- Source view: dbo.v_spr_tgl_terkini
CREATE OR REPLACE VIEW dbo.v_spr_tgl_terkini AS
SELECT x.tgl_update_terbaru, b.*
FROM dbo.v_max_spr x
LEFT JOIN dbo.stand_per_row b
ON b.from_date = x.tgl_update_terbaru
;

-- Source view: dbo.vc_baris_blok
CREATE OR REPLACE VIEW dbo.vc_baris_blok AS
SELECT a.blok, COUNT(a.blok) AS jml
FROM dbo.v_baris_blok a
GROUP BY a.blok
;

-- Source view: dbo.vc_spr
CREATE OR REPLACE VIEW dbo.vc_spr AS
SELECT COUNT(a.n_baris) AS jml, a.n_baris, a.catatan AS blok
FROM dbo.kebun_n_pokok a
GROUP BY a.n_baris, a.catatan
;

-- Source view: dbo.v_spr_terkini
CREATE OR REPLACE VIEW dbo.v_spr_terkini AS
SELECT gen_random_uuid() AS id_spr, a.blok, a.n_baris AS nbaris, 
(CASE
	WHEN b.nbaris IS NULL THEN a.jml ELSE b.spr_awal
END) AS spr_awal,
(CASE
	WHEN b.nbaris IS NULL THEN a.jml ELSE b.spr_akhir
END) AS spr_akhir
FROM dbo.vc_spr a
LEFT JOIN dbo.v_spr_tgl_terkini b
ON b.blok = a.blok
AND b.nbaris = a.n_baris
AND b.thru_date IS NULL
;

-- Source view: dbo.vsim_max_reposisi
CREATE OR REPLACE VIEW dbo.vsim_max_reposisi AS
SELECT
    x.pohon_tujuan,
    x.baris_tujuan,
    MAX(x.from_date) AS tgl_update_terbaru
FROM dbo.reposisi_pohon x
WHERE x.thru_date IS NULL AND x.petugas IN ('simulasi')
GROUP BY x.pohon_tujuan,x.baris_tujuan
;

-- Source view: dbo.vsim_pohon_tambahan
CREATE OR REPLACE VIEW dbo.vsim_pohon_tambahan AS
SELECT b.id_pihak, b.nama, b.kode_unik AS mandor, 
a.blok AS kode_lahan, a.blok, a.baris_awal AS baris_lama, a.pohon_awal AS pohon_lama,
a.id_tanaman AS objectId, 1 AS status, a.blok AS block, 1 AS tanda, 
a.baris_tujuan AS nbaris, a.pohon_tujuan AS npohon,
(CASE 
	WHEN a.tipe_riwayat='N' THEN 0
	WHEN a.tipe_riwayat='R' THEN 1
	WHEN a.tipe_riwayat='L' THEN 2
	WHEN a.tipe_riwayat='K' THEN 3
	WHEN a.tipe_riwayat='C' THEN 4
END) AS nflag
FROM dbo.reposisi_pohon a
LEFT JOIN dbo.master_pihak b
ON b.kode_unik = a.petugas 
WHERE a.id_tanaman LIKE 'V-%'
AND a.tipe_riwayat IN ('C', 'N')
AND a.pohon_awal = a.pohon_tujuan 
AND a.baris_awal = a.baris_tujuan 
AND a.petugas IN ('simulasi')
;

-- Source view: dbo.vsim_reposisi_terkini
CREATE OR REPLACE VIEW dbo.vsim_reposisi_terkini AS
SELECT DISTINCT 
a.tgl_update_terbaru,
x.id_tanaman, x.pohon_awal, x.baris_awal, x.pohon_tujuan,
x.baris_tujuan, x.keterangan, x.petugas, x.from_date, x.thru_date, x.tipe_riwayat, x.blok
FROM dbo.vsim_max_reposisi a
LEFT JOIN dbo.reposisi_pohon x
ON x.from_date = a.tgl_update_terbaru
AND x.pohon_tujuan = a.pohon_tujuan
AND x.baris_tujuan = a.baris_tujuan
AND x.thru_date IS NULL
;
