USE bpjs_kesehatan;

-- ==========================================
-- SCRIPT PEMBUATAN INDEKS (OPTIMASI)
-- ==========================================
CREATE INDEX idx_klaim_tgl_status ON klaim (tgl_pelayanan, status_klaim);
CREATE INDEX idx_klaim_jenis      ON klaim (jenis_pelayanan);
CREATE INDEX idx_peserta_segmen   ON peserta (segmen, status_peserta);
CREATE INDEX idx_faskes_provinsi  ON faskes (provinsi);

-- ==========================================
-- LOG EXPLAIN AKHIR (SETELAH INDEKS)
-- ==========================================
-- (Jalankan ulang kelima query dari File 2 dengan perintah EXPLAIN ANALYZE di sini)
-- Contoh untuk Query 1:
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