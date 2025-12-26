const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });
const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin'); // ✅ 1. Import Firebase Admin

// ✅ 2. Import Service Account Key
// Pastikan file 'serviceAccountKey.json' ada di root folder api (sejajar dengan package.json)
// Jika error, cek path ini apakah sudah sesuai lokasi file Anda
const serviceAccount = require('../serviceAccountKey.json'); 

// ✅ 3. Inisialisasi Firebase (WAJIB ADA!)
try {
  if (!admin.apps.length) { // Cek biar tidak double init saat restart nodemon
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount)
    });
    console.log("🔥 Firebase Admin SDK berhasil diinisialisasi!");
  }
} catch (error) {
  console.error("❌ Gagal inisialisasi Firebase:", error);
}

const db = require('./config/database');
const app = express();

app.use(cors());
app.use(express.json());
app.use('/uploads', express.static('public/uploads'));

// --- ROUTES ---
const authRoutes = require('./routes/auth');
const laporanRoutes = require('./routes/laporan');
const beritaRoutes = require('./routes/berita');
const adminRoutes = require('./routes/admin');
const uploadRoutes = require('./routes/upload');
const statsRoutes = require('./routes/stats');
const profileRoutes = require('./routes/profile');

app.use('/auth', authRoutes);
app.use('/laporan', laporanRoutes);
app.use('/berita', beritaRoutes);
app.use('/admin', adminRoutes);
app.use('/upload', uploadRoutes);
app.use('/stats', statsRoutes);
app.use('/profile', profileRoutes);

app.get('/', (req, res) => {
  res.send('API Lapor Balongmojo berjalan...');
});

const PORT = process.env.PORT || 3000;

// Logika Koneksi Database dengan Retry
async function startServer() {
  try {
    await db.execute('SELECT 1');
    console.log("✅ Database MySQL BERHASIL terhubung!");
    app.listen(PORT, () => {
      console.log(`🚀 Server berjalan di port ${PORT}`);
    });
  } catch (err) {
    console.log("⏳ Database belum siap. Menunggu 5 detik...");
    setTimeout(startServer, 5000);
  }
}

startServer();