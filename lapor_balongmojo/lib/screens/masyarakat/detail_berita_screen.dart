import 'package:flutter/material.dart';
import 'package:lapor_balongmojo/models/berita_model.dart';
import 'package:lapor_balongmojo/services/api_service.dart';

class DetailBeritaScreen extends StatelessWidget {
  static const routeName = '/detail-berita';
  const DetailBeritaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil data dari argument
    final berita = ModalRoute.of(context)!.settings.arguments as BeritaModel;

    return Scaffold(
      // AppBar transparan agar terlihat menyatu
      appBar: AppBar(
        title: const Text('Detail Berita'),
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100], // Background sedikit abu
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar Utama (Full Width)
            if (berita.gambarUrl != null)
              Image.network(
                '${ApiService.publicBaseUrl}${berita.gambarUrl}',
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, _) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.newspaper, size: 50, color: Colors.grey)),
                ),
              )
            else
              Container(
                height: 200,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.article, size: 60, color: Colors.grey)),
              ),

            // 2. Konten dengan efek Overlapping (Menumpuk ke atas)
            Container(
              transform: Matrix4.translationValues(0.0, -20.0, 0.0), // Geser ke atas 20px
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)), // Sudut membulat
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label Kategori & Tanggal
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "Berita Desa",
                          style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      // Menggunakan split tanggal dari kode Anda
                      Text(
                        berita.createdAt.split('T')[0], 
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Judul Berita Besar
                  Text(
                    berita.judul,
                    style: const TextStyle(
                      fontSize: 22, 
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                      color: Colors.black87
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Isi Berita
                  Text(
                    berita.isi,
                    style: const TextStyle(
                      fontSize: 16, 
                      height: 1.6, // Spasi antar baris lebih lega
                      color: Colors.black54
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}