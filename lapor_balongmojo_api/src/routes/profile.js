const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { verifyToken } = require('../middleware/auth');

router.put('/update-fcm', verifyToken, async (req, res) => {
  try {
    const { fcm_token } = req.body; 
    const userId = req.user.id; 

    if (!fcm_token) {
      return res.status(400).json({ message: 'FCM token tidak boleh kosong' });
    }

    await db.execute(
      'UPDATE users SET fcm_token = ? WHERE id = ?',
      [fcm_token, userId]
    );

    res.status(200).json({ message: 'FCM token berhasil diperbarui.' });

  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

module.exports = router;