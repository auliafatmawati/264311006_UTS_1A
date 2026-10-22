-- SOAL 1 :  Data Definition & Relasi

-- Tabel Induk 1
CREATE TABLE balita (
  id_balita      VARCHAR(10)   NOT NULL,
  nik            CHAR(16),
  nama           VARCHAR(100)  NOT NULL,
  tgl_lahir      DATE          NOT NULL,
  jenis_kelamin  ENUM('L','P') NOT NULL,
  nama_ortu      VARCHAR(100)  NOT NULL,
  no_wa_ortu     VARCHAR(20),
  PRIMARY KEY (id_balita),
  UNIQUE (nik)
) ENGINE=InnoDB;

-- Tabel Induk 2
CREATE TABLE jadwal_posyandu (
  id_jadwal       VARCHAR(10)  NOT NULL,
  tanggal         DATE         NOT NULL,
  jam_mulai       TIME         NOT NULL,
  jenis_kegiatan  VARCHAR(100) NOT NULL,
  PRIMARY KEY (id_jadwal)
) ENGINE=InnoDB;

-- Tabel Transaksi: FOREIGN KEY ke kedua tabel induk
CREATE TABLE kunjungan (
  id_kunjungan    VARCHAR(10)  NOT NULL,
  id_balita       VARCHAR(10)  NOT NULL,
  id_jadwal       VARCHAR(10)  NOT NULL,
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
  CONSTRAINT fk_kunjungan_balita FOREIGN KEY (id_balita)
    REFERENCES balita (id_balita) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_kunjungan_jadwal FOREIGN KEY (id_jadwal)
    REFERENCES jadwal_posyandu (id_jadwal) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

