const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { verifyToken, isPerangkat, isMasyarakat } = require('../middleware/auth');
const { kirimNotifikasiLaporanBaru } = require('../utils/fcm_helper'); 

router.post('/', [verifyToken, isMasyarakat], async (req, res) => {
  try {
    const { judul, deskripsi, foto_url } = req.body; 
    const user_id = req.user.id; 

    await db.execute(
      'INSERT INTO laporan (user_id, judul, deskripsi, foto_url, status) VALUES (?, ?, ?, ?, ?)',
      [user_id, judul, deskripsi, foto_url, 'belum terdaftar'] 
    );

    const [userRows] = await db.execute('SELECT nama_lengkap FROM users WHERE id = ?', [user_id]);
    const namaPelapor = userRows.length > 0 ? userRows[0].nama_lengkap : 'Warga';

    const [perangkatRows] = await db.execute(
      "SELECT fcm_token FROM users WHERE role = 'perangkat' AND fcm_token IS NOT NULL"
    );

    if (perangkatRows.length > 0) {
      const listToken = perangkatRows.map(row => row.fcm_token);
      console.log(`📢 Mengirim notifikasi ke ${listToken.length} perangkat desa...`);
      kirimNotifikasiLaporanBaru(judul, namaPelapor, listToken).catch(err => console.log("Gagal kirim notif:", err));
    } else {
      console.log("⚠️ Tidak ada token perangkat desa yang ditemukan.");
    }

    res.status(201).json({ message: 'Laporan berhasil dibuat dan notifikasi dikirim.' });

  } catch (err) {
    console.error("Error posting laporan:", err);
    res.status(500).json({ message: err.message });
  }
});

router.get('/', verifyToken, async (req, res) => {
  try {
    const { id, role } = req.user;
    let query = '';
    let params = [];

    if (role === 'perangkat' || role === 'admin') {
      query = `
        SELECT l.*, u.nama_lengkap AS pelapor, u.no_telepon 
        FROM laporan l 
        LEFT JOIN users u ON l.user_id = u.id 
        ORDER BY l.created_at DESC
      `;
    } else {

      query = `
        SELECT l.*, u.nama_lengkap AS pelapor, u.no_telepon 
        FROM laporan l 
        LEFT JOIN users u ON l.user_id = u.id 
        WHERE l.user_id = ? 
        ORDER BY l.created_at DESC
      `;
      params.push(id);
    }

    const [laporan] = await db.execute(query, params);
    res.json(laporan);

  } catch (err) {
    console.error("Error getting laporan:", err);
    res.status(500).json({ message: err.message });
  }
});

router.put('/:id', [verifyToken, isPerangkat], async (req, res) => {
  try {
    const { status } = req.body;
    const { id } = req.params;

    const validStatus = ['belum terdaftar', 'terverifikasi', 'diproses', 'selesai', 'tolak', 'ditolak'];
    
    if (!validStatus.includes(status)) {
      console.log(`❌ Backend menolak status: '${status}'. Yang diterima: ${validStatus.join(', ')}`);
      return res.status(400).json({ message: 'Status tidak valid.' });
    }

    await db.execute(
      'UPDATE laporan SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?',
      [status, id]
    );

    res.json({ message: 'Status laporan berhasil diperbarui.' });
  } catch (err) {
    console.error("Error update status:", err);
    res.status(500).json({ message: err.message });
  }
});

router.delete('/:id', [verifyToken, isPerangkat], async (req, res) => {
  try {
    const { id } = req.params;

    const [existing] = await db.execute('SELECT * FROM laporan WHERE id = ?', [id]);
    if (existing.length === 0) {
      return res.status(404).json({ message: 'Laporan tidak ditemukan.' });
    }

    await db.execute('DELETE FROM laporan WHERE id = ?', [id]);

    res.json({ message: 'Laporan berhasil dihapus.' });
  } catch (err) {
    console.error("Error deleting laporan:", err);
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;