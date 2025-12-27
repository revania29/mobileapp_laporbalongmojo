const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/database'); 

router.post('/register/masyarakat', async (req, res) => {
  try {
    const { nama_lengkap, email, no_telepon, password } = req.body;

    if (!nama_lengkap || !email || !password) {
      return res.status(400).json({ message: 'Nama, Email, dan Password wajib diisi.' });
    }

    const [existing] = await db.execute(
      'SELECT id FROM users WHERE email = ? OR no_telepon = ?',
      [email, no_telepon]
    );
    
    if (existing.length > 0) {
      return res.status(400).json({ message: 'Email atau No Telepon sudah terdaftar.' });
    }

    const salt = await bcrypt.genSalt(10);
    const password_hash = await bcrypt.hash(password, salt);

    await db.execute(
      'INSERT INTO users (nama_lengkap, email, no_telepon, password_hash, role, is_verified) VALUES (?, ?, ?, ?, ?, ?)',
      [nama_lengkap, email, no_telepon, password_hash, 'masyarakat', false] 
    );

    res.status(201).json({ message: 'Registrasi berhasil. Menunggu verifikasi admin.' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});


router.post('/login', async (req, res) => {
  try {
    const { email, password, fcm_token } = req.body;

    const [users] = await db.execute('SELECT * FROM users WHERE email = ?', [email]);
    if (users.length === 0) {
      return res.status(401).json({ message: 'Email atau password salah.' });
    }

    const user = users[0];

    if (user.role === 'masyarakat' && !user.is_verified) {
      return res.status(403).json({ message: 'Akun belum diverifikasi oleh admin.' });
    }

    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ message: 'Email atau password salah.' });
    }

    if (fcm_token) {
      await db.execute('UPDATE users SET fcm_token = ? WHERE id = ?', [fcm_token, user.id]);
    }

    const token = jwt.sign(
      { id: user.id, role: user.role },
      process.env.JWT_SECRET || 'secret_key_anda',
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
        no_telepon: user.no_telepon
      }
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;