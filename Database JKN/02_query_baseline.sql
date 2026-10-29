USE bpjs_kesehatan;

-- QUERY 1 : 3 faskes dengan klaim "Layak" terbesar di setiap provinsi (tahun 2025)
EXPLAIN ANALYZE
WITH total_faskes AS (
    SELECT f.id_faskes, f.nama_faskes, f.jenis_faskes, f.provinsi,
           COUNT(*) AS jumlah_klaim, SUM(k.biaya_disetujui) AS total_biaya_disetujui
    FROM klaim k
    JOIN faskes f ON f.id_faskes = k.id_faskes
    WHERE k.status_klaim = 'Layak' AND k.tgl_pelayanan BETWEEN '2025-01-01' AND '2025-12-31'
    GROUP BY f.id_faskes, f.nama_faskes, f.jenis_faskes, f.provinsi
)
SELECT * FROM (
    SELECT t.*, RANK() OVER (PARTITION BY t.provinsi ORDER BY t.total_biaya_disetujui DESC) AS peringkat
    FROM total_faskes t
) ranked
WHERE peringkat <= 3
ORDER BY provinsi, peringkat;

-- QUERY 2 : Tren bulanan kunjungan & biaya per jenis pelayanan di Jawa Timur (2025)
EXPLAIN ANALYZE
SELECT DATE_FORMAT(k.tgl_pelayanan, '%Y-%m') AS bulan, k.jenis_pelayanan,
       COUNT(*) AS jumlah_kunjungan, COUNT(DISTINCT k.id_peserta) AS peserta_unik,
       SUM(k.biaya_diajukan) AS total_diajukan, SUM(k.biaya_disetujui) AS total_disetujui,
       ROUND(AVG(k.biaya_diajukan), 0) AS rata_rata_biaya
FROM klaim k
JOIN faskes f ON f.id_faskes = k.id_faskes
WHERE k.tgl_pelayanan >= '2025-01-01' AND k.tgl_pelayanan < '2026-01-01' AND f.provinsi = 'Jawa Timur'
GROUP BY bulan, k.jenis_pelayanan
ORDER BY bulan, k.jenis_pelayanan;

-- QUERY 3 : 3 diagnosa rawat inap terbanyak pada tiap segmen kepesertaan
EXPLAIN ANALYZE
WITH diagnosa_segmen AS (
    SELECT p.segmen, d.kode_icd10, d.nama_diagnosa, d.kategori,
           COUNT(*) AS jumlah_kasus, SUM(k.biaya_diajukan) AS total_biaya
    FROM klaim k
    JOIN peserta p ON p.id_peserta = k.id_peserta
    JOIN diagnosa d ON d.id_diagnosa = k.id_diagnosa
    WHERE k.status_klaim = 'Layak' AND k.jenis_pelayanan IN ('RITP', 'RITL')
    GROUP BY p.segmen, d.kode_icd10, d.nama_diagnosa, d.kategori
)
SELECT * FROM (
    SELECT ds.*, ROW_NUMBER() OVER (PARTITION BY ds.segmen ORDER BY ds.jumlah_kasus DESC) AS urutan
    FROM diagnosa_segmen ds
) t
WHERE urutan <= 3
ORDER BY segmen, urutan;

-- QUERY 4 : Rata-rata biaya penyakit kronis berdasarkan kelompok umur & JK
EXPLAIN ANALYZE
SELECT d.kategori,
       CASE
           WHEN TIMESTAMPDIFF(YEAR, p.tgl_lahir, k.tgl_pelayanan) < 18 THEN '0-17 th'
           WHEN TIMESTAMPDIFF(YEAR, p.tgl_lahir, k.tgl_pelayanan) < 40 THEN '18-39 th'
           WHEN TIMESTAMPDIFF(YEAR, p.tgl_lahir, k.tgl_pelayanan) < 60 THEN '40-59 th'
           ELSE '60+ th'
       END AS kelompok_umur,
       p.jenis_kelamin, COUNT(*) AS jumlah_kunjungan,
       ROUND(AVG(k.biaya_diajukan), 0) AS rata_rata_biaya, MAX(k.biaya_diajukan) AS biaya_tertinggi
FROM klaim k
JOIN peserta p ON p.id_peserta = k.id_peserta
JOIN diagnosa d ON d.id_diagnosa = k.id_diagnosa
WHERE p.status_peserta = 'Aktif' AND d.kategori IN ('Kardiovaskular', 'Endokrin')
GROUP BY d.kategori, kelompok_umur, p.jenis_kelamin
HAVING COUNT(*) > 100
ORDER BY d.kategori, kelompok_umur, p.jenis_kelamin;

-- QUERY 5 : Peserta aktif dengan rawat inap berulang (>= 2 kali) tahun 2025
EXPLAIN ANALYZE
SELECT p.no_kartu, p.nama, p.segmen, f.nama_faskes AS faskes_tingkat_1,
       COUNT(*) AS jumlah_rawat_inap, SUM(k.lama_rawat) AS total_hari_rawat, SUM(k.biaya_diajukan) AS total_biaya
FROM peserta p
JOIN klaim k ON k.id_peserta = p.id_peserta
JOIN faskes f ON f.id_faskes = p.id_faskes_tk1
WHERE p.status_peserta = 'Aktif' AND k.jenis_pelayanan IN ('RITP', 'RITL') AND k.tgl_pelayanan BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY p.id_peserta, p.no_kartu, p.nama, p.segmen, f.nama_faskes
HAVING COUNT(*) >= 2
ORDER BY total_biaya DESC LIMIT 20;