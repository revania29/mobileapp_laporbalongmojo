const admin = require('firebase-admin');

// ============================================================
// LOGIKA 1: ADMIN KIRIM BERITA DARURAT -> KE SEMUA MASYARAKAT
// ============================================================
async function kirimNotifikasiDarurat(judulBerita, isiBerita) {
  try {
    const message = {
      notification: {
        title: `🚨 PERINGATAN DARURAT`, // Judul mencolok
        body: judulBerita,
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'high_importance_channel',
          priority: 'max',
          defaultSound: true,
          visibility: 'public',
        }
      },
      data: {
        screen: 'BeritaDetail',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
        refresh: 'true' // Agar UI Berita refresh otomatis
      },
      // ✅ PENTING: Kirim ke TOPIK (Broadcast), bukan token individu
      topic: 'emergency_alerts', 
    };

    await admin.messaging().send(message);
    console.log('✅ Notifikasi DARURAT terkirim ke topik: emergency_alerts');
  } catch (error) {
    console.error('❌ Gagal mengirim notifikasi darurat:', error);
  }
}

// ============================================================
// LOGIKA 2: MASYARAKAT LAPOR -> KE ADMIN (PERANGKAT)
// ============================================================
async function kirimNotifikasiLaporanBaru(judulLaporan, namaPelapor, listTokenDevice) {
  // Cek validasi
  if (!listTokenDevice || listTokenDevice.length === 0) {
    console.log('⚠️ Tidak ada token perangkat desa (Admin belum login). Notifikasi skip.');
    return;
  }

  try {
    const message = {
      notification: {
        title: '📢 Laporan Warga Baru',
        body: `${namaPelapor}: ${judulLaporan}`,
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
        screen: 'LaporanPerangkat', 
        refresh: 'true', // Sinyal ke Flutter untuk auto-refresh List Laporan
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      },
      // ✅ PENTING: Kirim ke TOKEN HP Admin yang sedang login
      tokens: listTokenDevice 
    };

    const response = await admin.messaging().sendEachForMulticast(message);
    console.log(`✅ Notifikasi LAPORAN terkirim: ${response.successCount} sukses, ${response.failureCount} gagal.`);
  } catch (error) {
    console.error('❌ Gagal mengirim notifikasi laporan:', error);
  }
}

module.exports = {
  kirimNotifikasiDarurat,
  kirimNotifikasiLaporanBaru 
};