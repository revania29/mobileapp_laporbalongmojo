const admin = require('firebase-admin');
const path = require('path');
const serviceAccount = require('../config/serviceAccountKey.json');

if (!admin.apps.length) {
    admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
    });
}
/**
 * @param {string} topic 
 * @param {string} title 
 * @param {string} body 
 * @param {object} data
 */
const sendNotificationToTopic = async (topic, title, body, data = {}) => {
    try {
        const message = {
            notification: {
                title: title,
                body: body
            },
            data: data,
            topic: topic
        };

        const response = await admin.messaging().send(message);
        console.log('✅ Notifikasi berhasil dikirim:', response);
        return true;
    } catch (error) {
        console.error('❌ Gagal mengirim notifikasi:', error);
        return false;
    }
};

module.exports = { sendNotificationToTopic };