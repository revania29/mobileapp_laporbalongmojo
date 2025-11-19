const express = require('express');
const cors = require('cors');
const db = require('./config/database');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Test Route (Cek server nyala)
app.get('/', (req, res) => {
    res.send('API Lapor Balongmojo Siap!');
});

// Cek Koneksi Database saat server start
app.listen(PORT, async () => {
    try {
        await db.query('SELECT 1');
        console.log(`✅ Server berjalan di port ${PORT}`);
        console.log('✅ Koneksi Database Berhasil!');
    } catch (error) {
        console.error('❌ Gagal konek ke database:', error.message);
    }
});