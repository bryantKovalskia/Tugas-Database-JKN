DROP DATABASE IF EXISTS bpjs_kesehatan;
CREATE DATABASE bpjs_kesehatan CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bpjs_kesehatan;

CREATE TABLE faskes (
    id_faskes     INT          NOT NULL PRIMARY KEY,
    kode_faskes   VARCHAR(12)  NOT NULL UNIQUE,
    nama_faskes   VARCHAR(80)  NOT NULL,
    jenis_faskes  VARCHAR(30)  NOT NULL,          
    tingkat       VARCHAR(5)   NOT NULL,          
    provinsi      VARCHAR(40)  NOT NULL,
    kota          VARCHAR(40)  NOT NULL
) ENGINE=InnoDB;

CREATE TABLE diagnosa (
    id_diagnosa    INT          NOT NULL PRIMARY KEY,
    kode_icd10     VARCHAR(10)  NOT NULL UNIQUE,
    nama_diagnosa  VARCHAR(80)  NOT NULL,
    kategori       VARCHAR(30)  NOT NULL
) ENGINE=InnoDB;

CREATE TABLE peserta (
    id_peserta      INT          NOT NULL PRIMARY KEY,
    no_kartu        CHAR(13)     NOT NULL UNIQUE,     
    nik             CHAR(16)     NOT NULL,
    nama            VARCHAR(60)  NOT NULL,
    jenis_kelamin   CHAR(1)      NOT NULL,            
    tgl_lahir       DATE         NOT NULL,
    segmen          VARCHAR(10)  NOT NULL,            
    kelas_rawat     CHAR(1)      NOT NULL,            
    status_peserta  VARCHAR(10)  NOT NULL,            
    id_faskes_tk1   INT          NOT NULL,            
    CONSTRAINT fk_peserta_faskes FOREIGN KEY (id_faskes_tk1) REFERENCES faskes (id_faskes)
) ENGINE=InnoDB;

CREATE TABLE klaim (
    id_klaim          INT           NOT NULL PRIMARY KEY,
    no_sep            VARCHAR(20)   NOT NULL UNIQUE,   
    id_peserta        INT           NOT NULL,
    id_faskes         INT           NOT NULL,
    id_diagnosa       INT           NOT NULL,
    jenis_pelayanan   CHAR(4)       NOT NULL,          
    tgl_pelayanan     DATE          NOT NULL,
    lama_rawat        TINYINT       NOT NULL DEFAULT 0,
    biaya_diajukan    DECIMAL(15,2) NOT NULL DEFAULT 0,
    biaya_disetujui   DECIMAL(15,2) NULL,
    status_klaim      VARCHAR(12)   NOT NULL,          
    CONSTRAINT fk_klaim_peserta  FOREIGN KEY (id_peserta)  REFERENCES peserta  (id_peserta),
    CONSTRAINT fk_klaim_faskes   FOREIGN KEY (id_faskes)   REFERENCES faskes   (id_faskes),
    CONSTRAINT fk_klaim_diagnosa FOREIGN KEY (id_diagnosa) REFERENCES diagnosa (id_diagnosa)
) ENGINE=InnoDB;


SET SESSION cte_max_recursion_depth = 500000;   
SET SQL_SAFE_UPDATES = 0;                       


INSERT INTO diagnosa (id_diagnosa, kode_icd10, nama_diagnosa, kategori) VALUES
( 1, 'A09',   'Gastroenteritis dan kolitis infeksius', 'Infeksi'),
( 2, 'A91',   'Demam berdarah dengue',                 'Infeksi'),
( 3, 'A15',   'Tuberkulosis paru',                     'Infeksi'),
( 4, 'J06.9', 'Infeksi saluran napas atas akut (ISPA)','Pernapasan'),
( 5, 'J18.9', 'Pneumonia',                             'Pernapasan'),
( 6, 'J45.9', 'Asma',                                  'Pernapasan'),
( 7, 'I10',   'Hipertensi esensial',                   'Kardiovaskular'),
( 8, 'I50.9', 'Gagal jantung',                         'Kardiovaskular'),
( 9, 'I63.9', 'Stroke infark',                         'Kardiovaskular'),
(10, 'E11.9', 'Diabetes melitus tipe 2',               'Endokrin'),
(11, 'E78.5', 'Dislipidemia',                          'Endokrin'),
(12, 'N18.5', 'Penyakit ginjal kronik stadium 5',      'Ginjal'),
(13, 'N39.0', 'Infeksi saluran kemih',                 'Ginjal'),
(14, 'K29.7', 'Gastritis',                             'Pencernaan'),
(15, 'K35.8', 'Apendisitis akut',                      'Pencernaan'),
(16, 'O80',   'Persalinan normal',                     'Obstetri'),
(17, 'O82',   'Persalinan sectio caesarea',            'Obstetri'),
(18, 'M54.5', 'Nyeri punggung bawah',                  'Muskuloskeletal'),
(19, 'S06.0', 'Cedera kepala ringan',                  'Cedera'),
(20, 'C50.9', 'Kanker payudara',                       'Onkologi');


INSERT INTO faskes (id_faskes, kode_faskes, nama_faskes, jenis_faskes, tingkat, provinsi, kota)
WITH RECURSIVE seq (n) AS (
    SELECT 1 UNION ALL SELECT n + 1 FROM seq WHERE n < 400
)
SELECT n,
       CONCAT('FKTP', LPAD(n, 6, '0')),
       CONCAT(ELT(j, 'Puskesmas', 'Klinik Pratama', 'Dokter Praktik'), ' ',
              ELT(w, 'Surabaya','Bandung','Semarang','Jakarta Selatan','Medan','Makassar','Denpasar','Balikpapan'),
              ' ', LPAD(n, 3, '0')),
       ELT(j, 'Puskesmas', 'Klinik Pratama', 'Dokter Praktik'),
       'FKTP',
       ELT(w, 'Jawa Timur','Jawa Barat','Jawa Tengah','DKI Jakarta','Sumatera Utara','Sulawesi Selatan','Bali','Kalimantan Timur'),
       ELT(w, 'Surabaya','Bandung','Semarang','Jakarta Selatan','Medan','Makassar','Denpasar','Balikpapan')
FROM (SELECT n, MOD(n, 3) + 1 AS j, MOD(n, 8) + 1 AS w FROM seq) s;

INSERT INTO faskes (id_faskes, kode_faskes, nama_faskes, jenis_faskes, tingkat, provinsi, kota)
WITH RECURSIVE seq (n) AS (
    SELECT 401 UNION ALL SELECT n + 1 FROM seq WHERE n < 500
)
SELECT n,
       CONCAT('FKRT', LPAD(n, 6, '0')),
       CONCAT(ELT(j, 'RS Tipe C', 'RS Tipe B', 'RS Tipe A'), ' ',
              ELT(w, 'Surabaya','Bandung','Semarang','Jakarta Selatan','Medan','Makassar','Denpasar','Balikpapan'),
              ' ', LPAD(n, 3, '0')),
       ELT(j, 'RS Tipe C', 'RS Tipe B', 'RS Tipe A'),
       'FKRTL',
       ELT(w, 'Jawa Timur','Jawa Barat','Jawa Tengah','DKI Jakarta','Sumatera Utara','Sulawesi Selatan','Bali','Kalimantan Timur'),
       ELT(w, 'Surabaya','Bandung','Semarang','Jakarta Selatan','Medan','Makassar','Denpasar','Balikpapan')
FROM (SELECT n, MOD(n, 3) + 1 AS j, MOD(n, 8) + 1 AS w FROM seq) s;


INSERT INTO peserta (id_peserta, no_kartu, nik, nama, jenis_kelamin, tgl_lahir,
                     segmen, kelas_rawat, status_peserta, id_faskes_tk1)
WITH RECURSIVE seq (n) AS (
    SELECT 1 UNION ALL SELECT n + 1 FROM seq WHERE n < 100000
)
SELECT n,
       LPAD(n, 13, '0'),
       CONCAT('3578', LPAD(n, 12, '0')),
       CONCAT(
         ELT(1 + FLOOR(RAND() * 20), 'Budi','Siti','Agus','Dewi','Slamet','Sri','Joko','Ratna','Bambang','Wati',
                                     'Andi','Rina','Hendra','Lestari','Eko','Putri','Dedi','Ayu','Rudi','Fitri'),
         ' ',
         ELT(1 + FLOOR(RAND() * 20), 'Santoso','Wijaya','Pratama','Saputra','Hidayat','Kusuma','Setiawan','Rahayu','Nugroho','Wibowo',
                                     'Susanto','Purnomo','Utami','Hartono','Siregar','Lubis','Nasution','Harahap','Gunawan','Permana')
       ),
       ELT(1 + FLOOR(RAND() * 2), 'L', 'P'),
       DATE_ADD('1950-01-01', INTERVAL FLOOR(RAND() * 25000) DAY),           
       
       ELT(1 + FLOOR(RAND() * 10), 'PBI APBN','PBI APBN','PBI APBN','PBI APBN','PBI APBD',
                                   'PPU','PPU','PPU','PBPU','BP'),
       ELT(1 + FLOOR(RAND() * 3), '1', '2', '3'),
       ELT(1 + FLOOR(RAND() * 10), 'Aktif','Aktif','Aktif','Aktif','Aktif','Aktif','Aktif','Aktif','Aktif','Nonaktif'),
       1 + FLOOR(RAND() * 400)                                               
FROM seq;


UPDATE peserta SET kelas_rawat = '3' WHERE segmen IN ('PBI APBN', 'PBI APBD');


INSERT INTO klaim (id_klaim, no_sep, id_peserta, id_faskes, id_diagnosa,
                   jenis_pelayanan, tgl_pelayanan, status_klaim)
WITH RECURSIVE seq (n) AS (
    SELECT 1 UNION ALL SELECT n + 1 FROM seq WHERE n < 250000
)
SELECT n,
       CONCAT('SEP', LPAD(n, 9, '0')),
       1 + FLOOR(RAND() * 100000),
       1 + FLOOR(RAND() * 400),                                              
       1 + FLOOR(RAND() * 20),
       ELT(1 + FLOOR(RAND() * 10), 'RJTP','RJTP','RJTP','RJTP','RJTP','RJTP','RJTP','RJTP','RJTP','RITP'),
       DATE_ADD('2024-01-01', INTERVAL FLOOR(RAND() * 1000) DAY),            
       ELT(1 + FLOOR(RAND() * 10), 'Layak','Layak','Layak','Layak','Layak','Layak','Layak','Layak','Pending','Tidak Layak')
FROM seq;

INSERT INTO klaim (id_klaim, no_sep, id_peserta, id_faskes, id_diagnosa,
                   jenis_pelayanan, tgl_pelayanan, status_klaim)
WITH RECURSIVE seq (n) AS (
    SELECT 250001 UNION ALL SELECT n + 1 FROM seq WHERE n < 350000
)
SELECT n,
       CONCAT('SEP', LPAD(n, 9, '0')),
       1 + FLOOR(RAND() * 100000),
       401 + FLOOR(RAND() * 100),                                            
       1 + FLOOR(RAND() * 20),
       ELT(1 + FLOOR(RAND() * 10), 'RJTL','RJTL','RJTL','RJTL','RJTL','RJTL','RJTL','RITL','RITL','RITL'),
       DATE_ADD('2024-01-01', INTERVAL FLOOR(RAND() * 1000) DAY),
       ELT(1 + FLOOR(RAND() * 10), 'Layak','Layak','Layak','Layak','Layak','Layak','Layak','Layak','Pending','Tidak Layak')
FROM seq;


UPDATE klaim
SET lama_rawat = CASE WHEN jenis_pelayanan IN ('RITP','RITL') THEN 1 + FLOOR(RAND() * 10) ELSE 0 END,
    biaya_diajukan = CASE jenis_pelayanan
        WHEN 'RJTP' THEN 50000   + ROUND(RAND() * 150000, -3)
        WHEN 'RITP' THEN lama_rawat * (300000  + ROUND(RAND() * 200000,  -3))
        WHEN 'RJTL' THEN 150000  + ROUND(RAND() * 1350000, -3)
        ELSE             lama_rawat * (1000000 + ROUND(RAND() * 3000000, -3))
    END,
    biaya_disetujui = CASE status_klaim
        WHEN 'Layak'   THEN biaya_diajukan
        WHEN 'Pending' THEN NULL
        ELSE 0
    END
WHERE id_klaim > 0;


CREATE INDEX idx_klaim_tgl_status ON klaim (tgl_pelayanan, status_klaim);
CREATE INDEX idx_klaim_jenis      ON klaim (jenis_pelayanan);
CREATE INDEX idx_peserta_segmen   ON peserta (segmen, status_peserta);
CREATE INDEX idx_faskes_provinsi  ON faskes (provinsi);

ANALYZE TABLE faskes, diagnosa, peserta, klaim;


SELECT 'faskes'   AS tabel, COUNT(*) AS jumlah_baris FROM faskes
UNION ALL SELECT 'diagnosa', COUNT(*) FROM diagnosa
UNION ALL SELECT 'peserta',  COUNT(*) FROM peserta
UNION ALL SELECT 'klaim',    COUNT(*) FROM klaim
UNION ALL SELECT 'TOTAL', (SELECT COUNT(*) FROM faskes) + (SELECT COUNT(*) FROM diagnosa)
                        + (SELECT COUNT(*) FROM peserta) + (SELECT COUNT(*) FROM klaim);
