-- Auto-generated converted PostgreSQL VIEW DDL from SQL Server schema apk
CREATE SCHEMA IF NOT EXISTS apk;
-- Ordered by dependency when possible (within same schema)

-- Source view: apk.v_apk_assignment
CREATE OR REPLACE VIEW apk.v_apk_assignment AS
SELECT a.*, b.jml AS maks_row
FROM dbo.v_assignment a
LEFT JOIN dbo.vc_baris_blok b
ON b.blok = a.lokasi
;

-- Source view: apk.v_apk_pihak
CREATE OR REPLACE VIEW apk.v_apk_pihak AS
SELECT a.* FROM dbo.master_pihak a
;

-- Source view: apk.v_apk_pohon
CREATE OR REPLACE VIEW apk.v_apk_pohon AS
SELECT CAST(a.kode_blok AS TEXT) AS blok,
  a.baris_pohon AS nbaris,
  a.nomor_pohon AS npohon,
  a.id_pohon AS objectId,
  a.status,
  0 AS nflag
FROM dbo.v_pohon a
;

-- Source view: apk.v_n_baris
CREATE OR REPLACE VIEW apk.v_n_baris AS
SELECT DISTINCT a.mandor, a.nbaris,
a.lokasi, a.nbaris - 1 AS n_baris_i, 
a.nbaris AS n_baris_ii,  
(CASE 
	WHEN a.nbaris+1 = a.maks_row + 1 THEN 0 ELSE a.nbaris+1
END) AS n_baris_iii
FROM apk.v_apk_assignment a
;

-- Source view: apk.v_new_nbaris
CREATE OR REPLACE VIEW apk.v_new_nbaris AS
SELECT DISTINCT
    t.mandor,
    --t.nbaris,
    t.lokasi,
    u.new_nbaris
FROM
    apk.v_n_baris t
CROSS JOIN LATERAL
    (
        VALUES
            ('n_baris_i', t.n_baris_i),
            ('n_baris_ii', t.n_baris_ii),
            ('n_baris_iii', t.n_baris_iii)
    ) AS u (kolom_asal, new_nbaris)
;

-- Source view: apk.v_petugas_lahan
CREATE OR REPLACE VIEW apk.v_petugas_lahan AS
SELECT a.*, b.kode_induk AS divisi
FROM dbo.petugas_lahan a
LEFT JOIN dbo.master_lahan b
ON b.keterangan = a.kode_lahan
;

-- Source view: apk.v_apk_petugas
CREATE OR REPLACE VIEW apk.v_apk_petugas AS
SELECT b.*, a.kode_lahan AS blok, a.divisi
FROM apk.v_petugas_lahan a
LEFT JOIN dbo.master_pihak b
ON b.kode_unik = a.id_petugas
WHERE b.jenis_id='PWD'
;

-- Source view: apk.v_ref_code
CREATE OR REPLACE VIEW apk.v_ref_code AS
SELECT a.*, 'INFO' AS kategori FROM dbo.ref_code a
;

-- Source view: apk.v_spk_pohon
CREATE OR REPLACE VIEW apk.v_spk_pohon AS
SELECT a.id_pihak, a.nama, a.kode_unik AS mandor,
b.kode_lahan, c.*
FROM dbo.petugas_lahan b
LEFT JOIN dbo.master_pihak a
ON a.kode_unik = b.id_petugas
LEFT JOIN apk.v_apk_pohon c
ON c.blok = b.kode_lahan
WHERE a.tipe = 'MANDOR'
;

-- Source view: apk.v_pohon_terkini_
CREATE OR REPLACE VIEW apk.v_pohon_terkini_ AS
SELECT 
a.id_pihak,	a.nama,	a.mandor, a.kode_lahan,	a.blok,	a.nbaris AS baris_lama, a.npohon AS pohon_lama,	a.objectId,	a.status,
(CASE 
	WHEN b.id_tanaman IS NULL THEN a.blok ELSE b.blok
END) AS block,
(CASE 
	WHEN b.id_tanaman IS NULL THEN 0 ELSE 1
END) AS tanda,
(CASE 
	WHEN b.id_tanaman IS NULL THEN a.nbaris ELSE b.baris_tujuan
END) AS nbaris,
(CASE 
	WHEN b.id_tanaman IS NULL THEN a.npohon ELSE b.pohon_tujuan 
END) AS npohon,
(CASE
	WHEN b.id_tanaman IS NULL THEN a.nflag 
	ELSE   
	(CASE 
		WHEN b.tipe_riwayat='N' THEN 0
		WHEN b.tipe_riwayat='R' THEN 1
		WHEN b.tipe_riwayat='L' THEN 2
		WHEN b.tipe_riwayat='K' THEN 3
		WHEN b.tipe_riwayat='C' THEN 4
	END)
END) AS nflag
FROM apk.v_spk_pohon a
LEFT JOIN dbo.v_reposisi_terkini b
ON b.baris_awal = a.nbaris
AND b.pohon_awal = a.npohon 
AND b.petugas NOT IN ('simulasi')
and b.blok = a.blok
WHERE a.mandor NOT IN ('simulasi')
;

-- Source view: apk.v_pohon_terkini
CREATE OR REPLACE VIEW apk.v_pohon_terkini AS
SELECT t.id_pihak, t.nama, t.mandor, t.kode_lahan, t.blok, 
t.baris_lama, t.pohon_lama, t.objectId, t.status, t.block,
t.tanda, t.nbaris, t.npohon, t.nflag
FROM apk.v_pohon_terkini_ t
;

-- Source view: apk.v_simulasi_pohon
CREATE OR REPLACE VIEW apk.v_simulasi_pohon AS
SELECT 
a.id_pihak,	a.nama,	a.mandor, a.kode_lahan,	a.blok,	a.nbaris AS baris_lama, a.npohon AS pohon_lama,	a.objectId,	a.status,
(CASE 
	WHEN b.id_tanaman IS NULL THEN a.blok ELSE b.blok
END) AS block,
(CASE 
	WHEN b.id_tanaman IS NULL THEN 0 ELSE 1
END) AS tanda,
(CASE 
	WHEN b.id_tanaman IS NULL THEN a.nbaris ELSE b.baris_tujuan
END) AS nbaris,
(CASE 
	WHEN b.id_tanaman IS NULL THEN a.npohon ELSE b.pohon_tujuan 
END) AS npohon,
(CASE
	WHEN b.id_tanaman IS NULL THEN a.nflag 
	ELSE   
	(CASE 
		WHEN b.tipe_riwayat='N' THEN 0
		WHEN b.tipe_riwayat='R' THEN 1
		WHEN b.tipe_riwayat='L' THEN 2
		WHEN b.tipe_riwayat='K' THEN 3
		WHEN b.tipe_riwayat='C' THEN 4
	END)
END) AS nflag
FROM apk.v_spk_pohon a
LEFT JOIN dbo.vsim_reposisi_terkini b
ON b.baris_awal = a.nbaris
AND b.pohon_awal = a.npohon 
AND b.petugas IN ('simulasi')
AND b.blok = a.blok
WHERE a.mandor IN ('simulasi')
;

-- Source view: apk.v_spk_pohon_i
CREATE OR REPLACE VIEW apk.v_spk_pohon_i AS
SELECT a.*, b.*
FROM apk.v_new_nbaris a
LEFT JOIN apk.v_apk_pohon b
ON b.blok = a.lokasi AND b.nbaris = a.new_nbaris
WHERE a.new_nbaris > 0
;
