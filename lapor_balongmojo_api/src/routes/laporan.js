const express = require('express');
const router = express.Router();
const db = require('../config/database');
const multer = require('multer');
const path = require('path');
const { verifyToken } = require('../middleware/auth');

// --- KONFIGURASI MULTER (UPLOAD) ---
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

// --- 1. POST LAPORAN (BUAT LAPORAN BARU) ---
// Endpoint: POST /laporan
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

// --- 2. GET LAPORAN (LIHAT RIWAYAT SAYA) ---
// Endpoint: GET /laporan
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

module.exports = router;