-- =====================================================================
-- UTS Praktik Basis Data -- Pemodelan Fisik
-- Bagian A : tabel eksisting yang direferensikan (dari Modul 7)
-- Bagian B : tabel baru hasil penambahan proses bisnis (DDL UTS)
-- Bagian C : data contoh, uji constraint, dan query laporan
-- Seluruh data adalah data fiktif.
-- =====================================================================
CREATE DATABASE IF NOT EXISTS uts_intervensi DEFAULT CHARACTER SET utf8mb4;
USE uts_intervensi;
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS evaluasi_intervensi, intervensi, jenis_intervensi, rujukan, kunjungan,
                     jadwal_posyandu, balita, pengguna, posyandu;
SET FOREIGN_KEY_CHECKS = 1;
 
-- ---------------------------------------------------------------------
-- BAGIAN A : TABEL EKSISTING
-- ---------------------------------------------------------------------
CREATE TABLE posyandu (
  id_posyandu    VARCHAR(10)  NOT NULL,
  nama_posyandu  VARCHAR(100) NOT NULL,
  dusun          VARCHAR(50),
  desa           VARCHAR(50),
  kecamatan      VARCHAR(50),
  PRIMARY KEY (id_posyandu)
) ENGINE=InnoDB;
 
CREATE TABLE pengguna (
  id_pengguna    VARCHAR(10)  NOT NULL,
  id_posyandu    VARCHAR(10)  NOT NULL,
  nama           VARCHAR(100) NOT NULL,
  username       VARCHAR(50)  NOT NULL,
  password_hash  VARCHAR(255) NOT NULL,
  role           ENUM('Ketua Posyandu','Anggota BKB','Kader','Petugas Puskesmas') NOT NULL DEFAULT 'Kader',
  PRIMARY KEY (id_pengguna),
  UNIQUE (username),
  CONSTRAINT fk_pengguna_posyandu FOREIGN KEY (id_posyandu) REFERENCES posyandu (id_posyandu)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;
 
CREATE TABLE balita (
  id_balita      VARCHAR(10)  NOT NULL,
  id_posyandu    VARCHAR(10)  NOT NULL,
  id_pengguna    VARCHAR(10)  NOT NULL,
  nik            CHAR(16),
  nama           VARCHAR(100) NOT NULL,
  tgl_lahir      DATE         NOT NULL,
  jenis_kelamin  ENUM('L','P') NOT NULL,
  nama_ortu      VARCHAR(100) NOT NULL,
  no_wa_ortu     VARCHAR(20),
  PRIMARY KEY (id_balita),
  UNIQUE (nik),
  CONSTRAINT fk_balita_posyandu FOREIGN KEY (id_posyandu) REFERENCES posyandu (id_posyandu)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_balita_pengguna FOREIGN KEY (id_pengguna) REFERENCES pengguna (id_pengguna)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;
 
CREATE TABLE jadwal_posyandu (
  id_jadwal       VARCHAR(10)  NOT NULL,
  id_posyandu     VARCHAR(10)  NOT NULL,
  tanggal         DATE         NOT NULL,
  jam_mulai       TIME         NOT NULL,
  jenis_kegiatan  VARCHAR(100) NOT NULL,
  PRIMARY KEY (id_jadwal),
  UNIQUE (id_posyandu, tanggal),
  CONSTRAINT fk_jadwal_posyandu FOREIGN KEY (id_posyandu) REFERENCES posyandu (id_posyandu)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;
 
CREATE TABLE kunjungan (
  id_kunjungan    VARCHAR(10)  NOT NULL,
  id_balita       VARCHAR(10)  NOT NULL,
  id_jadwal       VARCHAR(10)  NOT NULL,
  id_pengguna     VARCHAR(10)  NOT NULL,
  berat_badan     DECIMAL(5,2) NOT NULL,
  tinggi_badan    DECIMAL(5,1) NOT NULL,
  lingkar_kepala  DECIMAL(4,1),
  vitamin_a       ENUM('Ya','Tidak') NOT NULL DEFAULT 'Tidak',
  obat_cacing     ENUM('Ya','Tidak') NOT NULL DEFAULT 'Tidak',
  status_gizi     ENUM('Gizi Baik','Berisiko Stunting','Stunting'),
  PRIMARY KEY (id_kunjungan),
  UNIQUE (id_balita, id_jadwal),
  CHECK (berat_badan > 0),
  CHECK (tinggi_badan > 0),
  CONSTRAINT fk_kunjungan_balita FOREIGN KEY (id_balita) REFERENCES balita (id_balita)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_kunjungan_jadwal FOREIGN KEY (id_jadwal) REFERENCES jadwal_posyandu (id_jadwal)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_kunjungan_pengguna FOREIGN KEY (id_pengguna) REFERENCES pengguna (id_pengguna)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;
 
CREATE TABLE rujukan (
  id_rujukan            VARCHAR(10)  NOT NULL,
  id_kunjungan          VARCHAR(10)  NOT NULL,
  tgl_rujukan           DATE         NOT NULL,
  puskesmas_tujuan      VARCHAR(100) NOT NULL,
  rekomendasi           VARCHAR(255),
  status_tindak_lanjut  ENUM('Dirujuk','Surat Terbit','Disampaikan ke Orang Tua','Selesai')
                        NOT NULL DEFAULT 'Dirujuk',
  PRIMARY KEY (id_rujukan),
  UNIQUE (id_kunjungan),
  CONSTRAINT fk_rujukan_kunjungan FOREIGN KEY (id_kunjungan) REFERENCES kunjungan (id_kunjungan)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;
 
-- ---------------------------------------------------------------------
-- BAGIAN B : TABEL BARU (penambahan proses bisnis intervensi gizi)
-- ---------------------------------------------------------------------
-- B1. Master jenis intervensi (tabel induk)
CREATE TABLE jenis_intervensi (
  id_jenis          VARCHAR(10)  NOT NULL,
  nama_intervensi   VARCHAR(100) NOT NULL,
  deskripsi         VARCHAR(255),
  PRIMARY KEY (id_jenis),
  UNIQUE (nama_intervensi)
) ENGINE=InnoDB;
 
-- B2. Intervensi gizi: satu rujukan dapat memiliki banyak intervensi
CREATE TABLE intervensi (
  id_intervensi  VARCHAR(10)  NOT NULL,
  id_rujukan     VARCHAR(10)  NOT NULL,
  id_jenis       VARCHAR(10)  NOT NULL,
  id_pengguna    VARCHAR(10)  NOT NULL,
  tgl_mulai      DATE         NOT NULL,
  tgl_selesai    DATE,
  status         ENUM('Direncanakan','Berjalan','Selesai','Dihentikan') NOT NULL DEFAULT 'Direncanakan',
  catatan        VARCHAR(255),
  PRIMARY KEY (id_intervensi),
  CONSTRAINT uq_intervensi_rujukan_jenis_mulai UNIQUE (id_rujukan, id_jenis, tgl_mulai),
  CONSTRAINT ck_intervensi_tanggal CHECK (tgl_selesai IS NULL OR tgl_selesai >= tgl_mulai),
  CONSTRAINT ck_intervensi_selesai CHECK (status <> 'Selesai' OR tgl_selesai IS NOT NULL),
  CONSTRAINT fk_intervensi_rujukan FOREIGN KEY (id_rujukan) REFERENCES rujukan (id_rujukan)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_intervensi_jenis FOREIGN KEY (id_jenis) REFERENCES jenis_intervensi (id_jenis)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_intervensi_pengguna FOREIGN KEY (id_pengguna) REFERENCES pengguna (id_pengguna)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;
 
-- B3. Evaluasi intervensi pada kunjungan (entitas asosiatif M:N intervensi dan kunjungan)
CREATE TABLE evaluasi_intervensi (
  id_intervensi   VARCHAR(10) NOT NULL,
  id_kunjungan    VARCHAR(10) NOT NULL,
  hasil_evaluasi  ENUM('Membaik','Tetap','Memburuk') NOT NULL,
  catatan         VARCHAR(255),
  PRIMARY KEY (id_intervensi, id_kunjungan),
  CONSTRAINT fk_evaluasi_intervensi FOREIGN KEY (id_intervensi) REFERENCES intervensi (id_intervensi)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_evaluasi_kunjungan FOREIGN KEY (id_kunjungan) REFERENCES kunjungan (id_kunjungan)
    ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;
 
-- Index untuk daftar intervensi yang masih berjalan
CREATE INDEX idx_intervensi_status ON intervensi (status);
 
-- ---------------------------------------------------------------------
-- BAGIAN C : DATA CONTOH DAN QUERY LAPORAN
-- ---------------------------------------------------------------------
INSERT INTO posyandu VALUES ('P01','Posyandu ILP Dukuh Mranggen','Mranggen','Joho','Dagangan');
INSERT INTO pengguna (id_pengguna,id_posyandu,nama,username,password_hash,role) VALUES
 ('U01','P01','Siti Aminah','siti.aminah','$2y$10$contohhashfiktif01','Ketua Posyandu'),
 ('U02','P01','Dewi Lestari','dewi.lestari','$2y$10$contohhashfiktif02','Kader'),
 ('U03','P01','Rina Puspita','rina.puskesmas','$2y$10$contohhashfiktif03','Petugas Puskesmas');
INSERT INTO balita VALUES
 ('B02','P01','U02','3519010101240002','Bunga Lestari','2024-03-10','P','Slamet Riyadi','081234560003'),
 ('B03','P01','U02','3519010101250003','Citra Maharani','2025-01-20','P','Agus Prasetyo','081234560005');
INSERT INTO jadwal_posyandu VALUES
 ('J01','P01','2026-08-05','08:00:00','Posyandu rutin'),
 ('J02','P01','2026-09-02','08:00:00','Posyandu rutin'),
 ('J03','P01','2026-10-07','08:00:00','Posyandu rutin');
INSERT INTO kunjungan VALUES
 ('K03','B02','J01','U02',10.20,78.5,46.0,'Ya','Tidak','Berisiko Stunting'),
 ('K04','B02','J02','U02',10.40,79.0,46.0,'Tidak','Ya','Berisiko Stunting'),
 ('K05','B02','J03','U02',10.70,79.8,46.2,'Tidak','Tidak','Berisiko Stunting'),
 ('K06','B03','J02','U02', 9.10,72.0,45.0,'Tidak','Ya','Berisiko Stunting'),
 ('K07','B03','J03','U02', 9.50,73.2,45.3,'Tidak','Tidak','Gizi Baik');
INSERT INTO rujukan VALUES
 ('R01','K04','2026-09-02','Puskesmas Dagangan','Pemberian makanan tambahan dan konseling gizi','Surat Terbit'),
 ('R02','K06','2026-09-02','Puskesmas Dagangan','Konseling gizi','Surat Terbit');
 
INSERT INTO jenis_intervensi VALUES
 ('JI01','Pemberian Makanan Tambahan (PMT)','Makanan tambahan bergizi selama periode tertentu'),
 ('JI02','Konseling gizi','Konsultasi pola makan dengan petugas gizi'),
 ('JI03','Kunjungan rumah','Pemantauan kondisi balita di rumah oleh petugas');
INSERT INTO intervensi VALUES
 ('I01','R01','JI01','U03','2026-09-10',NULL,'Berjalan','PMT selama 30 hari'),
 ('I02','R01','JI02','U03','2026-09-10',NULL,'Berjalan',NULL),
 ('I03','R02','JI02','U03','2026-09-10','2026-10-07','Selesai','Konseling sebanyak tiga kali');
INSERT INTO evaluasi_intervensi VALUES
 ('I01','K05','Membaik','Berat badan naik 0,3 kg'),
 ('I02','K05','Tetap',NULL),
 ('I03','K07','Membaik','Status gizi kembali baik');
 
-- Query laporan: jumlah intervensi per jenis dan status
SELECT ji.nama_intervensi, i.status, COUNT(*) AS jumlah
FROM intervensi i
JOIN jenis_intervensi ji ON ji.id_jenis = i.id_jenis
GROUP BY ji.nama_intervensi, i.status
ORDER BY ji.nama_intervensi;
 
-- Query laporan: hasil evaluasi intervensi per balita
SELECT b.nama AS balita, ji.nama_intervensi, j.tanggal AS tgl_evaluasi, e.hasil_evaluasi
FROM evaluasi_intervensi e
JOIN intervensi i        ON i.id_intervensi = e.id_intervensi
JOIN jenis_intervensi ji ON ji.id_jenis = i.id_jenis
JOIN kunjungan k         ON k.id_kunjungan = e.id_kunjungan
JOIN jadwal_posyandu j   ON j.id_jadwal = k.id_jadwal
JOIN balita b            ON b.id_balita = k.id_balita
ORDER BY b.nama, ji.nama_intervensi;
 
