const express = require('express');
const cors = require('cors');
const db = require('./config/database');
const path = require('path');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const laporanRoutes = require('./routes/laporan');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use('/uploads', express.static(path.join(__dirname, '../public/uploads')));

// Routes
app.use('/auth', authRoutes);
app.use('/laporan', laporanRoutes);

app.get('/', (req, res) => {
    res.send('API Lapor Balongmojo Siap!');
});

app.listen(PORT, async () => {
    try {
        await db.query('SELECT 1');
        console.log(`✅ Server berjalan di port ${PORT}`);
        console.log('✅ Koneksi Database Berhasil!');
    } catch (error) {
        console.error('❌ Gagal konek ke database:', error.message);
    }
});