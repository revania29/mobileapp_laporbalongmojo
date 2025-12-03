const jwt = require('jsonwebtoken');
require('dotenv').config();

const verifyToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        return res.status(403).json({ message: 'Akses ditolak! Token tidak tersedia.' });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;
        next();
    } catch (error) {
        return res.status(401).json({ message: 'Token tidak valid!' });
    }
};

const isPerangkat = (req, res, next) => {
    if (req.user && req.user.role === 'perangkat') {
        next();
    } else {
        res.status(403).json({ message: 'Akses Ditolak! Khusus Perangkat Desa.' });
    }
};

module.exports = { verifyToken };