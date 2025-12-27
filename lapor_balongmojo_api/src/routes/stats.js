const express = require('express');
const router = express.Router();
const db = require('../config/database');

router.get('/laporan-total', async (req, res) => {
    try {

        const [result] = await db.execute('SELECT COUNT(*) as total_laporan FROM laporan');

        const total = result[0].total_laporan;

        res.json({ total_laporan: total });

    } catch (err) {
        res.status(500).json({ message: err.message });
    }
});

module.exports = router;