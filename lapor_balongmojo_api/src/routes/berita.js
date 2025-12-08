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
        cb(null, 'news-' + Date.now() + path.extname(file.originalname));
    }
});

const upload = multer({ 
    storage: storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // 5MB
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

router.get('/', verifyToken, async (req, res) => {
    try {
        // Urutkan dari yang terbaru (DESC)
        const [rows] = await db.query('SELECT * FROM berita ORDER BY created_at DESC');
        res.json(rows);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Gagal mengambil berita' });
    }
});

router.post('/', [verifyToken, isPerangkat], upload.single('image'), async (req, res) => {
    try {
        const { judul, isi } = req.body;
        const gambarUrl = req.file ? `/uploads/${req.file.filename}` : null;

        if (!judul || !isi) {
            return res.status(400).json({ message: 'Judul dan Isi Berita wajib diisi!' });
        }

        await db.query(
            `INSERT INTO berita (judul, isi, gambar_url) VALUES (?, ?, ?)`,
            [judul, isi, gambarUrl]
        );

        res.status(201).json({ message: 'Berita berhasil dipublikasikan!' });

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Gagal memposting berita', error: error.message });
    }
});

module.exports = router;