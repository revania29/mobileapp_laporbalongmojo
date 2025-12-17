const { sendNotificationToTopic } = require('../utils/fcm');
const testRun = async () => {
    console.log("⏳ Sedang mencoba mengirim notifikasi test...");
    const result = await sendNotificationToTopic(
        'test_channel',
        'Tes Dari Server Desa!',
        'Halo, ini adalah pesan percobaan dari Backend Lapor Balongmojo.',
        { tipe: 'testing', jam: new Date().toISOString() }
    );

    if (result) {
        console.log("🎉 SUKSES! Server backend terhubung ke Firebase.");
        console.log("👉 Jika nanti HP sudah di-setup (Hari 24), notif ini akan muncul.");
    } else {
        console.log("💀 GAGAL! Cek kembali serviceAccountKey.json Anda.");
    }

    process.exit();
};

testRun();