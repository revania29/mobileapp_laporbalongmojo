const jwt = require('jsonwebtoken');

exports.verifyToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ message: 'Akses ditolak, token tidak ditemukan.' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret_key_anda');
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(403).json({ message: 'Token tidak valid atau kadaluwarsa.' });
  }
};

exports.isPerangkat = (req, res, next) => {
  if (req.user.role === 'perangkat' || req.user.role === 'admin') {
    next();
  } else {
    return res.status(403).json({ message: 'Akses ditolak, hanya untuk perangkat desa.' });
  }
};

exports.isMasyarakat = (req, res, next) => {
  if (req.user.role === 'masyarakat') {
    next();
  } else {
    return res.status(403).json({ message: 'Akses ditolak, hanya untuk masyarakat.' });
  }
};