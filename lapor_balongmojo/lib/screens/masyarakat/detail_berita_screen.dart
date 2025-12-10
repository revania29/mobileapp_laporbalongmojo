import 'package:flutter/material.dart';
import 'package:lapor_balongmojo/models/berita_model.dart';
import 'package:lapor_balongmojo/services/api_service.dart';

class DetailBeritaScreen extends StatelessWidget {
  static const routeName = '/detail-berita';
  const DetailBeritaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final berita = ModalRoute.of(context)!.settings.arguments as BeritaModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Berita'),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    berita.judul,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    berita.createdAt.split('T')[0], 
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const Divider(height: 30),
                  Text(
                    berita.isi,
                    style: const TextStyle(fontSize: 16, height: 1.5),
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