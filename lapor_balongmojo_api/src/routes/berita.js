const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { verifyToken, isPerangkat } = require('../middleware/auth');

// ✅ Import Helper Notifikasi
const { kirimNotifikasiDarurat } = require('../utils/fcm_helper'); 

// ==================================================
// 1. BUAT BERITA BARU (LOGIKA DARURAT DISINI)
// ==================================================
router.post('/', [verifyToken, isPerangkat], async (req, res) => {
  try {
    // Ambil data dari inputan admin
    const { judul, isi, gambar_url, is_peringatan_darurat } = req.body;
    const author_id = req.user.id;

    // 1. Simpan ke Database
    const [result] = await db.execute(
      'INSERT INTO berita (judul, isi, gambar_url, author_id, is_peringatan_darurat) VALUES (?, ?, ?, ?, ?)',
      [judul, isi, gambar_url, author_id, is_peringatan_darurat]
    );

    // ✅ 2. LOGIKA DARURAT (Ini yang sempat hilang)
    // Jika admin mencentang "Peringatan Darurat" (true)
    if (is_peringatan_darurat === true || is_peringatan_darurat === 1 || is_peringatan_darurat === 'true') {
      console.log("🚨 Mendeteksi Berita Darurat! Mengirim notifikasi ke SEMUA warga...");
      
      // Panggil fungsi notifikasi massal (Broadcast)
      await kirimNotifikasiDarurat(judul, isi);
    }

    res.status(201).json({ message: 'Berita berhasil dibuat', id: result.insertId });
  } catch (err) {
    console.error("Error post berita:", err);
    res.status(500).json({ message: err.message });
  }
});

// ==================================================
// 2. UPDATE BERITA (LOGIKA UBAH STATUS DARURAT)
// ==================================================
router.put('/:id', [verifyToken, isPerangkat], async (req, res) => {
  try {
    const { judul, isi, gambar_url, is_peringatan_darurat } = req.body;
    
    // Update Database
    await db.execute(
      'UPDATE berita SET judul=?, isi=?, gambar_url=?, is_peringatan_darurat=? WHERE id=?',
      [judul, isi, gambar_url, is_peringatan_darurat, req.params.id]
    );

    // ✅ Jika di-update MENJADI darurat, kirim notifikasi juga
    if (is_peringatan_darurat === true || is_peringatan_darurat === 1) {
       console.log("🚨 Berita di-update jadi Darurat! Kirim notifikasi...");
       await kirimNotifikasiDarurat(judul, isi || "Status berita diubah menjadi darurat.");
    }

    res.json({ message: 'Berita berhasil diupdate' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// ==================================================
// 3. GET BERITA & DELETE (Standar)
// ==================================================
router.get('/', async (req, res) => {
  try {
    // Join dengan tabel users untuk dapat nama pembuat berita
    const [rows] = await db.execute(`
      SELECT b.*, u.nama_lengkap as author_name 
      FROM berita b 
      JOIN users u ON b.author_id = u.id 
      ORDER BY b.created_at DESC
    `);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

router.delete('/:id', [verifyToken, isPerangkat], async (req, res) => {
  try {
    await db.execute('DELETE FROM berita WHERE id = ?', [req.params.id]);
    res.json({ message: 'Berita berhasil dihapus' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;