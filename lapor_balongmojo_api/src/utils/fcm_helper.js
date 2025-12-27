const admin = require('firebase-admin');

async function kirimNotifikasiDarurat(judulBerita, isiBerita) {
  try {
    const message = {
      notification: {
        title: '🚨 DARURAT 🚨', 
        body: judulBerita,
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'high_importance_channel',
          priority: 'max',
          defaultSound: true,
          visibility: 'public',
          color: '#f44336' 
        }
      },
      data: {
        screen: 'BeritaDetail',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
        refresh: 'true' 
      },
      topic: 'emergency_alerts', 
    };

    await admin.messaging().send(message);
    console.log('✅ Notifikasi DARURAT terkirim dengan judul 🚨 DARURAT 🚨');
  } catch (error) {
    console.error('❌ Gagal mengirim notifikasi darurat:', error);
  }
}

async function kirimNotifikasiLaporanBaru(judulLaporan, namaPelapor, listTokenDevice) {
  if (!listTokenDevice || listTokenDevice.length === 0) {
    console.log('⚠️ Tidak ada token perangkat desa. Notifikasi skip.');
    return;
  }

  try {
    const message = {
      notification: {
        title: '📢 Laporan Warga',
        body: judulLaporan, 
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'high_importance_channel',
          priority: 'max',
          defaultSound: true,
        }
      },
      data: {
        refresh: 'true',
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      },

      tokens: listTokenDevice 
    };

    const response = await admin.messaging().sendEachForMulticast(message);
    console.log(`✅ Notifikasi LAPORAN terkirim: ${response.successCount} sukses.`);
  } catch (error) {
    console.error('❌ Gagal mengirim notifikasi laporan:', error);
  }
}

module.exports = {
  kirimNotifikasiDarurat,
  kirimNotifikasiLaporanBaru 
};