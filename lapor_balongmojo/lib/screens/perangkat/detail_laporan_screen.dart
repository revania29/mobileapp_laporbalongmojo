import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapor_balongmojo/models/laporan_model.dart';
import 'package:lapor_balongmojo/providers/laporan_provider.dart';
import 'package:lapor_balongmojo/services/api_service.dart';

class DetailLaporanScreen extends StatefulWidget {
  static const routeName = '/detail-laporan';
  const DetailLaporanScreen({super.key});

  @override
  State<DetailLaporanScreen> createState() => _DetailLaporanScreenState();
}

class _DetailLaporanScreenState extends State<DetailLaporanScreen> {
  bool _isUpdating = false;

  Future<void> _updateStatus(int id, String status) async {
    setState(() => _isUpdating = true);
    try {
      await Provider.of<LaporanProvider>(context, listen: false)
          .updateStatus(id, status);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status berhasil diubah menjadi ${status.toUpperCase()}')),
      );
      Navigator.of(context).pop(); 
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
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

  void _showConfirmDialog(int id, String status, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text("Status akan diubah menjadi ${status.toUpperCase()}."),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text("Batal")),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _updateStatus(id, status);
            },
            child: const Text("Ya, Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final laporan = ModalRoute.of(context)!.settings.arguments as LaporanModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (laporan.fotoUrl != null)
              Image.network(
                '${ApiService.publicBaseUrl}${laporan.fotoUrl}',
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, _) => Container(
                  height: 250,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    laporan.judul,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(laporan.createdAt, style: const TextStyle(color: Colors.grey)),
                      const Spacer(),
                      Chip(
                        label: Text(laporan.status.toUpperCase(), style: const TextStyle(color: Colors.white)),
                        backgroundColor: _getStatusColor(laporan.status),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  const Text("Deskripsi:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(laporan.deskripsi, style: const TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isUpdating 
          ? const LinearProgressIndicator(color: Colors.teal)
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildActionButtons(laporan),
            ),
    );
  }

  Widget _buildActionButtons(LaporanModel laporan) {
    if (laporan.status == 'selesai' || laporan.status == 'ditolak') {
      return Container(
        height: 50,
        alignment: Alignment.center,
        color: Colors.grey[200],
        child: const Text("Laporan ini sudah ditutup.", style: TextStyle(color: Colors.grey)),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showConfirmDialog(laporan.id, 'ditolak', 'Tolak Laporan ini?'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text("TOLAK"),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (laporan.status == 'menunggu') {
                _showConfirmDialog(laporan.id, 'proses', 'Proses Laporan ini?');
              } else if (laporan.status == 'proses') {
                _showConfirmDialog(laporan.id, 'selesai', 'Selesaikan Laporan?');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(laporan.status == 'menunggu' ? "PROSES" : "SELESAI"),
          ),
        ),
      ],
    );
  }
}