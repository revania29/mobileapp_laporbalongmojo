const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { verifyToken, isPerangkat } = require('../middleware/auth');

// 1. GET USER PENDING
router.get('/pending', [verifyToken, isPerangkat], async (req, res) => {
    try {
        const [rows] = await db.query("SELECT id, nama_lengkap, email, no_telepon, created_at FROM users WHERE status_akun = 'pending' AND role = 'masyarakat'");
        res.json(rows);
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Gagal mengambil data user pending.' });
    }
});

// 2. VERIFIKASI USER
router.put('/:id/verify', [verifyToken, isPerangkat], async (req, res) => {
    try {
        const userId = req.params.id;
        const { action } = req.body;

        if (!['verified', 'rejected'].includes(action)) {
            return res.status(400).json({ message: 'Action harus verified atau rejected' });
        }

        await db.query("UPDATE users SET status_akun = ? WHERE id = ?", [action, userId]);
        
        res.json({ message: `User berhasil di-${action}` });
    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Gagal memverifikasi user.' });
    }
});

module.exports = router;