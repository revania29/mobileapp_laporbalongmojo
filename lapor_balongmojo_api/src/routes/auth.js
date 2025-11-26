const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/database');


router.post('/register', async (req, res) => {

    const { nama_lengkap, email, password, no_telepon } = req.body;


    if (!nama_lengkap || !email || !password || !no_telepon) {
        return res.status(400).json({ message: 'Semua kolom wajib diisi!' });
    }

    try {

        const [existingUsers] = await db.execute(
            'SELECT * FROM users WHERE email = ? OR no_telepon = ?',
            [email, no_telepon]
        );

        if (existingUsers.length > 0) {
            return res.status(400).json({ message: 'Email atau No. Telepon sudah terdaftar!' });
        }


        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);


        await db.execute(
            `INSERT INTO users (nama_lengkap, email, password_hash, no_telepon, role, status_akun) 
             VALUES (?, ?, ?, ?, 'masyarakat', 'pending')`,
            [nama_lengkap, email, hashedPassword, no_telepon]
        );

        res.status(201).json({ message: 'Registrasi berhasil! Silakan login.' });

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Terjadi kesalahan server' });
    }
});


router.post('/login', async (req, res) => {
    const { email, password } = req.body;

    try {

        const [users] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);

        if (users.length === 0) {
            return res.status(400).json({ message: 'Email tidak ditemukan!' });
        }

        const user = users[0];


        const isMatch = await bcrypt.compare(password, user.password_hash);

        if (!isMatch) {
            return res.status(400).json({ message: 'Password salah!' });
        }


        const token = jwt.sign(
            { id: user.id, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: '7d' }
        );


        res.json({
            message: 'Login berhasil',
            token: token,
            user: {
                id: user.id,
                nama: user.nama_lengkap,
                email: user.email,
                role: user.role,
                status: user.status_akun
            }
        });

    } catch (error) {
        console.error(error);
        res.status(500).json({ message: 'Terjadi kesalahan server' });
    }
});

module.exports = router;