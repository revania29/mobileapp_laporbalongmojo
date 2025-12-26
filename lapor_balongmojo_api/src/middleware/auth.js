const jwt = require('jsonwebtoken');

// Mengecek apakah token valid
exports.verifyToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'Akses ditolak, token tidak ditemukan.' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret_key_anda');
    req.user = decoded; // Berisi id dan role
    next();
  } catch (err) {
    return res.status(403).json({ message: 'Token tidak valid atau kadaluwarsa.' });
  }
};

// Khusus Perangkat / Admin
exports.isPerangkat = (req, res, next) => {
  if (req.user.role === 'perangkat' || req.user.role === 'admin') {
    next();
  } else {
    return res.status(403).json({ message: 'Akses ditolak, hanya untuk perangkat desa.' });
  }
};

// Khusus Masyarakat
exports.isMasyarakat = (req, res, next) => {
  if (req.user.role === 'masyarakat') {
    next();
  } else {
    return res.status(403).json({ message: 'Akses ditolak, hanya untuk masyarakat.' });
  }
};