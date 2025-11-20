const express = require('express');
const cors = require('cors');
const db = require('./config/database');
const authRoutes = require('./routes/auth');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use('/auth', authRoutes);

app.get('/', (req, res) => {
    res.send('API Lapor Balongmojo Siap!');
});

app.listen(PORT, async () => {
    try {
        await db.query('SELECT 1');
        console.log(`Server berjalan di port ${PORT}`);
        console.log('Koneksi Database Berhasil!');
    } catch (error) {
        console.error('Gagal konek ke database:', error.message);
    }
});