import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapor_balongmojo/providers/laporan_provider.dart';
import 'package:lapor_balongmojo/services/api_service.dart';

class ListLaporanAdminScreen extends StatelessWidget {
  static const routeName = '/list-laporan-admin';
  const ListLaporanAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final laporanList = Provider.of<LaporanProvider>(context).allLaporanAdmin;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Laporan Masuk'),
        backgroundColor: Colors.teal,
      ),
      body: laporanList.isEmpty
          ? const Center(child: Text('Belum ada laporan masuk.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: laporanList.length,
              itemBuilder: (ctx, i) {
                final lap = laporanList[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: lap.fotoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              '${ApiService.publicBaseUrl}${lap.fotoUrl}',
                              width: 50, height: 50, fit: BoxFit.cover,
                              errorBuilder: (ctx, err, _) => const Icon(Icons.broken_image),
                            ),
                          )
                        : const Icon(Icons.image_not_supported),
                    title: Text(lap.judul, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${lap.deskripsi}\nStatus: ${lap.status.toUpperCase()}',
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur Detail & Edit Status akan dibuat di Hari 15')),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}