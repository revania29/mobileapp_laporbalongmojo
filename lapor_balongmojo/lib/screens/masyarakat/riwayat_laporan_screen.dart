import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapor_balongmojo/providers/laporan_provider.dart';
import 'package:lapor_balongmojo/services/api_service.dart';

class RiwayatLaporanScreen extends StatefulWidget {
  static const routeName = '/riwayat-laporan';
  const RiwayatLaporanScreen({super.key});

  @override
  State<RiwayatLaporanScreen> createState() => _RiwayatLaporanScreenState();
}

class _RiwayatLaporanScreenState extends State<RiwayatLaporanScreen> {
  
  @override
  void initState() {
    super.initState(); 
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LaporanProvider>(context, listen: false).fetchRiwayatLaporan();
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'menunggu': return Colors.orange;
      case 'proses': return Colors.blue;
      case 'selesai': return Colors.green;
      case 'ditolak': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final laporanData = Provider.of<LaporanProvider>(context);
    final laporanList = laporanData.riwayatLaporan;

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Laporan Saya')),
      body: laporanData.isLoading
          ? const Center(child: CircularProgressIndicator())
          : laporanList.isEmpty
              ? const Center(
                  child: Text('Belum ada laporan yang dikirim.', style: TextStyle(color: Colors.grey)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: laporanList.length,
                  itemBuilder: (ctx, i) {
                    final lap = laporanList[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (lap.fotoUrl != null)
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Image.network(
                                '${ApiService.publicBaseUrl}${lap.fotoUrl}', 
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, error, stackTrace) =>
                                    const SizedBox(height: 150, child: Center(child: Icon(Icons.broken_image, color: Colors.grey))),
                              ),
                            ),
                          
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        lap.judul,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(lap.status).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: _getStatusColor(lap.status)),
                                      ),
                                      child: Text(
                                        lap.status.toUpperCase(),
                                        style: TextStyle(color: _getStatusColor(lap.status), fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(lap.deskripsi, maxLines: 2, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 8),
                                Text(
                                  "Dikirim pada: ${lap.createdAt}",
                                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}