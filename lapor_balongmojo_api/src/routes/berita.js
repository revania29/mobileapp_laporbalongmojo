const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { verifyToken, isPerangkat } = require('../middleware/auth');
const multer = require('multer');
const path = require('path');
const fs = require('fs');

// Import Helper FCM (HARI 22/23)
const { sendNotificationToTopic } = require('../utils/fcm'); 

// Setup Multer untuk Upload Gambar
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const uploadPath = 'public/uploads/';
        // Pastikan folder ada
        if (!fs.existsSync(uploadPath)){
            fs.mkdirSync(uploadPath, { recursive: true });
        }
        cb(null, uploadPath);
    },
    filename: (req, file, cb) => {
        cb(null, 'news-' + Date.now() + path.extname(file.originalname));
    }
});

const upload = multer({ 
    storage: storage,
    limits: { fileSize: 5 * 1024 * 1024 }, // Max 5MB
    fileFilter: (req, file, cb) => {
        const filetypes = /jpeg|jpg|png/;
        const mimetype = filetypes.test(file.mimetype);
        const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
        if (mimetype && extname) {
            return cb(null, true);
        }
        cb(new Error('Hanya diperbolehkan upload file gambar (jpg, jpeg, png)'));
    }
});

// --- ROUTES ---

// 1. GET SEMUA BERITA (Warga & Admin)
router.get('/', verifyToken, async (req, res) => {
    try {
        // Urutkan dari yang terbaru (DESC)
        const [rows] = await db.query('SELECT * FROM berita ORDER BY created_at DESC');
        res.json(rows);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Gagal mengambil data berita.' });
    }
});

// 2. POST BERITA BARU (Hanya Perangkat Desa) - UPDATE HARI 23
router.post('/', [verifyToken, isPerangkat, upload.single('image')], async (req, res) => {
    try {
        const { judul, isi, is_darurat } = req.body; // Ambil flag is_darurat
        const imagePath = req.file ? `/uploads/${req.file.filename}` : null;
        const userId = req.user.id; // Dari token

        if (!judul || !isi) {
            return res.status(400).json({ message: 'Judul dan Isi berita wajib diisi.' });
        }

        // Konversi is_darurat ke boolean/integer (karena dari form-data biasanya string)
        // Jika dicentang/dikirim 'true' atau '1', maka jadi 1. Default 0.
        const isEmergency = (is_darurat === 'true' || is_darurat === '1') ? 1 : 0;

        // Simpan ke Database
        const query = 'INSERT INTO berita (user_id, judul, isi, gambar_url, is_darurat) VALUES (?, ?, ?, ?, ?)';
        const [result] = await db.query(query, [userId, judul, isi, imagePath, isEmergency]);

        // --- LOGIKA NOTIFIKASI (HARI 23) ---
        if (isEmergency === 1) {
            console.log("🚨 Mendeteksi Berita Darurat! Mengirim Notifikasi...");
            
            // Panggil Helper FCM (Topik: 'emergency_alerts')
            // Isi pesan dipotong max 100 karakter agar tidak kepanjangan di notif
            await sendNotificationToTopic(
                'emergency_alerts', 
                `PERINGATAN DARURAT: ${judul}`, 
                isi.length > 100 ? isi.substring(0, 100) + '...' : isi,
                { 
                    beritaId: result.insertId.toString(),
                    tipe: 'darurat'
                }
            );
        }

        res.status(201).json({ 
            message: 'Berita berhasil dipublikasikan.',
            beritaId: result.insertId
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Gagal memposting berita.' });
    }
});

module.exports = router; 