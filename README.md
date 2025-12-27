# 📱 Lapor Balongmojo - Mobile App

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-blue?logo=flutter)
![Backend](https://img.shields.io/badge/Backend-Node.js%20%26%20MySQL-green?logo=node.js)
![Status](https://img.shields.io/badge/Status-Completed-success)

**Lapor Balongmojo** adalah aplikasi mobile berbasis Flutter yang dirancang untuk mendigitalisasi layanan masyarakat di Desa Balongmojo.
Aplikasi ini menjembatani komunikasi antara warga dan perangkat desa, memungkinkan pelaporan masalah lingkungan secara *real-time* serta penyebaran informasi desa yang efektif.

---

## 🌟 Fitur Unggulan

Aplikasi ini memiliki dua peran pengguna (*Role-Based*) dengan fitur yang berbeda:

### 👨‍👩‍👧‍👦 Modul Warga (Masyarakat)
* **Registrasi & Login Aman:** Sistem autentikasi menggunakan JWT.
* **Laporan Pengaduan:** Melaporkan masalah (jalan rusak, sampah, keamanan) dilengkapi dengan **Foto Bukti** dan **Pilih Lokasi Dusun**.
* **Pantau Status:** Melihat progres laporan (Menunggu ➔ Diproses ➔ Selesai) secara transparan.
* **Berita Desa:** Mengakses informasi dan pengumuman terbaru dari desa.
* **Notifikasi Darurat:** Menerima *Push Notification* (FCM) untuk berita penting/darurat.

### 👮‍♂️ Modul Perangkat Desa (Admin)
* **Dashboard Statistik:** Ringkasan visual jumlah laporan masuk, diproses, dan selesai.
* **Verifikasi Warga:** Validasi pendaftaran warga baru untuk keamanan data.
* **Manajemen Laporan:** Mengubah status laporan warga dan memberikan tindak lanjut.
* **Content Management:** Menulis dan mempublikasikan berita desa.
* **Broadcast Alert:** Mengirim notifikasi darurat ke seluruh warga dalam satu klik.

---

## 🛠️ Teknologi yang Digunakan

Project ini dibangun menggunakan *Tech Stack* modern:

| Kategori | Teknologi |
| :--- | :--- |
| **Mobile Framework** | [Flutter](https://flutter.dev/) (Dart) |
| **State Management** | Provider |
| **Backend API** | Node.js & Express.js |
| **Database** | MySQL |
| **Authentication** | JSON Web Token (JWT) |
| **Cloud Services** | Firebase Cloud Messaging (FCM) |
| **Containerization** | Docker |

---

## 🚀 Cara Instalasi & Menjalankan

Ikuti langkah ini untuk menjalankan aplikasi di komputer Anda.

### 1. Persiapan Backend (Server)
Pastikan Anda sudah menginstal MySQL dan Node.js.

```bash
# 1. Clone repository ini
git clone [https://github.com/revania29/mobileapp_laporbalongmojo.git](https://github.com/revania29/mobileapp_laporbalongmojo.git)

# 2. Masuk ke folder backend (sesuaikan nama foldernya jika berbeda)
cd lapor_balongmojo_api

# 3. Install dependencies
npm install

# 4. Setup Database
# - Buat database baru di MySQL bernama 'db_lapor_balongmojo'

# 5. Jalankan Server
npm start
# (Server berjalan di port: 3000)
```
### 2. Frontend (Mobile App)
Pastikan sudah install: Flutter SDK (Terbaru) & Android Studio (Emulator)

```bash
# 1. Kembali ke root folder dan masuk ke folder flutter
cd lapor_balongmojo

# 2. Download package flutter
flutter pub get

# 3. ⚠️ KONFIGURASI IP ADDRESS ⚠️
# - Buka file: lib/services/api_service.dart
# - Ganti 'baseUrl' dengan IP Laptop Anda (Contoh: [http://192.168.1.10:3000](http://192.168.1.10:3000))
# - JANGAN gunakan localhost jika mengetes di HP fisik.

# 4. Jalankan Aplikasi
# (Pastikan Emulator sudah menyala atau HP terhubung)
flutter run
```

=========================================
      TIM PENGEMBANG (DEV TEAM)
=========================================

1. Alvyn Wira Pratama (DEV)
2. Kifansa Naufal Fadhlurrohman (DEV)
3. Revania Kyla Evadne (PO)
4. Angelina Kurniawan (SM)

-----------------------------------------
Tahun: 2025
Copyright (c) Lapor Balongmojo
=========================================
