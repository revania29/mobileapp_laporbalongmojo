const express = require('express');
const router = express.Router();
const db = require('../config/database');
const multer = require('multer');
const path = require('path');
const { verifyToken, isPerangkat } = require('../middleware/auth'); 

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'public/uploads');
    },
    filename: (req, file, cb) => {
        cb(null, Date.now() + path.extname(file.originalname));
    }
});

const upload = multer({ 
    storage: storage,
    limits: { fileSize: 5 * 1024 * 1024 },
    fileFilter: (req, file, cb) => {
        const filetypes = /jpeg|jpg|png/;
        const mimetype = filetypes.test(file.mimetype);
        const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
        if (mimetype && extname) {
            return cb(null, true);
        }
        cb(new Error('Hanya boleh upload gambar (jpg/jpeg/png)!'));
    }
});

router.post('/', verifyToken, upload.single('image'), async (req, res) => {
    try {
        const { judul, deskripsi } = req.body;
        const userId = req.user.id; 
        
        const fotoUrl = req.file ? `/uploads/${req.file.filename}` : null;

        if (!judul || !deskripsi) {
            return res.status(400).json({ message: 'Judul dan Deskripsi wajib diisi!' });
        }

        await db.query(
            `INSERT INTO laporan (user_id, judul, deskripsi, foto_url) VALUES (?, ?, ?, ?)`,
            [userId, judul, deskripsi, fotoUrl]
        );

        res.status(201).json({ message: 'Laporan berhasil dikirim!' });

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Gagal mengirim laporan', error: error.message });
    }
});

router.get('/', verifyToken, async (req, res) => {
    try {
        const userId = req.user.id;

        const [rows] = await db.query(
            `SELECT * FROM laporan WHERE user_id = ? ORDER BY created_at DESC`,
            [userId]
        );

        res.json(rows);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Gagal mengambil data laporan' });
    }
});

router.get('/admin/all', [verifyToken, isPerangkat], async (req, res) => {
    try {
        const query = `
            SELECT l.*, u.nama_lengkap as pelapor, u.no_telepon 
            FROM laporan l 
            JOIN users u ON l.user_id = u.id 
            ORDER BY l.created_at DESC
        `;
        
        const [rows] = await db.query(query);
        res.json(rows);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Gagal memuat semua laporan.' });
    }
});


router.put('/:id', [verifyToken, isPerangkat], async (req, res) => {
    try {
        const laporanId = req.params.id;
        const { status } = req.body; 

        const validStatuses = ['menunggu', 'proses', 'selesai', 'ditolak'];
        if (!validStatuses.includes(status)) {
            return res.status(400).json({ message: 'Status tidak valid!' });
        }

        const [result] = await db.query(
            'UPDATE laporan SET status = ? WHERE id = ?',
            [status, laporanId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Laporan tidak ditemukan.' });
        }

        res.json({ message: `Status berhasil diubah menjadi ${status}` });

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Gagal update status laporan.' });
    }
});

router.get('/stats', [verifyToken, isPerangkat], async (req, res) => {
    try {
        const query = `
            SELECT 
                SUM(CASE WHEN status = 'menunggu' THEN 1 ELSE 0 END) as menunggu,
                SUM(CASE WHEN status = 'proses' THEN 1 ELSE 0 END) as proses,
                SUM(CASE WHEN status = 'selesai' THEN 1 ELSE 0 END) as selesai
            FROM laporan
        `;
        const [rows] = await db.query(query);
        res.json(rows[0]);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Gagal mengambil statistik.' });
    }
});

module.exports = router;