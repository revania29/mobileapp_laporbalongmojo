import 'packagea:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapor_balongmojo/providers/auth_provider.dart';
import 'package:lapor_balongmojo/screens/auth/login_screen.dart';

class DashboardScreenPerangkat extends StatelessWidget {
  static const routeName = '/dashboard-perangkat';
  const DashboardScreenPerangkat({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Perangkat'),
        backgroundColor: Colors.teal, // Warna pembeda untuk Admin
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              // Dialog Logout (Sama seperti warga)
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Konfirmasi Logout'),
                  content: const Text('Keluar dari mode Admin?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        await Provider.of<AuthProvider>(context, listen: false).logout();
                        if (!context.mounted) return;
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          LoginScreen.routeName, 
                          (route) => false
                        );
                      },
                      child: const Text('Ya, Keluar'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Sapaan
            Text(
              'Selamat Datang,',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            Text(
              user?.nama ?? 'Admin Desa',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // 2. Statistik Ringkas (Dummy Data dulu untuk Desain)
            const Text("Statistik Laporan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            Row(
              children: const [
                Expanded(child: _StatCard(title: 'Menunggu', count: '0', color: Colors.orange)),
                SizedBox(width: 10),
                Expanded(child: _StatCard(title: 'Proses', count: '0', color: Colors.blue)),
                SizedBox(width: 10),
                Expanded(child: _StatCard(title: 'Selesai', count: '0', color: Colors.green)),
              ],
            ),

            const SizedBox(height: 30),

            // 3. Menu Manajemen
            const Text("Menu Manajemen", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            
            // Menu Kelola Laporan
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.assignment, color: Colors.teal),
                ),
                title: const Text('Kelola Laporan Warga'),
                subtitle: const Text('Lihat dan update status laporan'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Nanti di hari berikutnya kita arahkan ke DetailLaporanScreen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur ini akan dibuat di Hari 13-14')),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 10),

            // Menu Kelola Berita
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.article, color: Colors.blue),
                ),
                title: const Text('Publikasi Berita'),
                subtitle: const Text('Buat pengumuman atau berita desa'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // Nanti di hari berikutnya kita arahkan ke FormBerita
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur ini akan dibuat di Hari 16-17')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget Kecil untuk Kartu Statistik
class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;

  const _StatCard({required this.title, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(count, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}