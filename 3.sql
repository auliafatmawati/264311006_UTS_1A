-- SOAL 3 : Query Kompleks & Agregasi Laporan
SELECT b.nama,                                        
       COUNT(k.id_kunjungan)       AS total_kunjungan, 
       ROUND(AVG(k.berat_badan),2) AS rata_berat_badan
FROM balita b
JOIN kunjungan k        ON k.id_balita = b.id_balita    
JOIN jadwal_posyandu j  ON j.id_jadwal = k.id_jadwal     
WHERE j.tanggal BETWEEN '2026-08-01' AND '2026-09-30'      
GROUP BY b.nama;   
