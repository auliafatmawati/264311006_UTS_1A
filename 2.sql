-- SOAL 2 : Operasi CRUD Dasar

-- 1.[CREATE] 
-- Memasukkan data di TABLE balita
INSERT INTO balita (id_balita, nik, nama, tgl_lahir, jenis_kelamin, nama_ortu, no_wa_ortu) VALUES
 ('B01','3519010101250001','Ananda Putra','2025-07-15','L','Budi Santoso','081234560001'),
 ('B02','3519010101240002','Bunga Lestari','2024-03-10','P','Slamet Riyadi','081234560003'),
 ('B03','3519010101250003','Citra Maharani','2025-01-20','P','Agus Prasetyo','081234560005');

-- Memasukkan data di TABLE jadwal_posyandu
INSERT INTO jadwal_posyandu (id_jadwal, tanggal, jam_mulai, jenis_kegiatan) VALUES
 ('J01','2026-08-05','08:00:00','Posyandu rutin, penimbangan, Vitamin A'),
 ('J02','2026-09-02','08:00:00','Posyandu rutin, penimbangan, obat cacing'),
 ('J03','2026-10-07','08:00:00','Posyandu rutin, penimbangan');

-- Memasukkan data di TABLE kunjungan
INSERT INTO kunjungan (id_kunjungan, id_balita, id_jadwal, berat_badan, tinggi_badan, lingkar_kepala, vitamin_a, obat_cacing, status_gizi) VALUES
 ('K01','B01','J01', 9.40, 70.2, 45.0, 'Ya',    'Tidak', 'Gizi Baik'),
 ('K02','B01','J02', 9.70, 71.0, 45.5, 'Tidak', 'Ya',    'Gizi Baik'),
 ('K03','B02','J01',10.20, 78.5, 46.0, 'Ya',    'Tidak', 'Berisiko Stunting'),
 ('K04','B02','J02',10.40, 79.0, 46.0, 'Tidak', 'Ya',    'Berisiko Stunting');

-- 2.[READ]
SELECT * FROM balita;

-- 3.[UPDATE]
UPDATE kunjungan SET berat_badan = 10.60 WHERE id_kunjungan = 'K03';

-- 4.[DELETE]
DELETE FROM kunjungan WHERE id_kunjungan = 'K04';
