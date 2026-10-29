USE bpjs_kesehatan;

-- ==========================================
-- UJI OVERHEAD DML (TANPA INDEKS)
-- ==========================================
-- (Jalankan sebelum menjalankan script Index di File 3)
-- Waktu eksekusi dicatat (misal: 0.8s)

START TRANSACTION;
INSERT INTO peserta (id_peserta, no_kartu, nik, nama, jenis_kelamin, tgl_lahir, segmen, kelas_rawat, status_peserta, id_faskes_tk1)
WITH RECURSIVE seq (n) AS (
    SELECT 100001 UNION ALL SELECT n + 1 FROM seq WHERE n < 110000
)
SELECT n, LPAD(n, 13, '0'), CONCAT('3578', LPAD(n, 12, '0')), CONCAT('User', n), 'L', '1990-01-01', 'PBPU', '3', 'Aktif', 1
FROM seq;
COMMIT;

-- Update massal
START TRANSACTION;
UPDATE peserta SET nama = CONCAT(nama, ' Updated') WHERE id_peserta BETWEEN 100001 AND 110000;
COMMIT;

-- Delete massal
START TRANSACTION;
DELETE FROM peserta WHERE id_peserta BETWEEN 100001 AND 110000;
COMMIT;


-- ==========================================
-- UJI OVERHEAD DML (DENGAN INDEKS)
-- ==========================================
-- (Jalankan SETELAH script Index di File 3 dijalankan)
-- Waktu eksekusi dicatat (misal: 1.3s) untuk melihat selisih trade-off

START TRANSACTION;
INSERT INTO peserta (id_peserta, no_kartu, nik, nama, jenis_kelamin, tgl_lahir, segmen, kelas_rawat, status_peserta, id_faskes_tk1)
WITH RECURSIVE seq (n) AS (
    SELECT 100001 UNION ALL SELECT n + 1 FROM seq WHERE n < 110000
)
SELECT n, LPAD(n, 13, '0'), CONCAT('3578', LPAD(n, 12, '0')), CONCAT('User', n), 'L', '1990-01-01', 'PBPU', '3', 'Aktif', 1
FROM seq;
COMMIT;

-- Update massal
START TRANSACTION;
UPDATE peserta SET nama = CONCAT(nama, ' Updated') WHERE id_peserta BETWEEN 100001 AND 110000;
COMMIT;

-- Delete massal
START TRANSACTION;
DELETE FROM peserta WHERE id_peserta BETWEEN 100001 AND 110000;
COMMIT;