import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapor_balongmojo/providers/auth_provider.dart';
import 'package:lapor_balongmojo/screens/auth/login_screen.dart';
import 'package:lapor_balongmojo/screens/perangkat/form_berita_screen.dart';
import 'package:lapor_balongmojo/screens/perangkat/list_laporan_admin_screen.dart';
import 'package:lapor_balongmojo/screens/perangkat/verifikasi_warga_screen.dart';
import 'package:lapor_balongmojo/services/api_service.dart';

class DashboardScreenPerangkat extends StatefulWidget {
  static const routeName = '/dashboard-perangkat';
  const DashboardScreenPerangkat({super.key});

  @override
  State<DashboardScreenPerangkat> createState() => _DashboardScreenPerangkatState();
}

class _DashboardScreenPerangkatState extends State<DashboardScreenPerangkat> {
  Map<String, dynamic> _stats = {'menunggu': 0, 'proses': 0, 'selesai': 0};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadStats());
  }

  // Fungsi ambil statistik langsung dari API
  Future<void> _loadStats() async {
    try {
      final stats = await ApiService().getStatistik();
      if(mounted) setState(() => _stats = stats);
    } catch (e) {
      debugPrint("Gagal load stats: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Perangkat'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
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
                        final rootNavigator = Navigator.of(context);
                        await Provider.of<AuthProvider>(context, listen: false).logout();
                        if (!mounted) return;
                        rootNavigator.pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
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
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selamat Datang,', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              Text(user?.nama ?? 'Admin Desa', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              const Text("Statistik Laporan (Realtime)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _StatCard(title: 'Menunggu', count: _stats['menunggu'].toString(), color: Colors.orange)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(title: 'Proses', count: _stats['proses'].toString(), color: Colors.blue)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(title: 'Selesai', count: _stats['selesai'].toString(), color: Colors.green)),
                ],
              ),

              const SizedBox(height: 30),
              const Text("Menu Manajemen", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              
              // Menu 1: Verifikasi Warga (BARU)
               Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.person_add, color: Colors.orange),
                  ),
                  title: const Text('Verifikasi Warga Baru'),
                  subtitle: const Text('Terima atau tolak pendaftaran'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.of(context).pushNamed(VerifikasiWargaScreen.routeName),
                ),
              ),
              const SizedBox(height: 10),

              // Menu 2: Kelola Laporan
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.teal.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.assignment, color: Colors.teal),
                  ),
                  title: const Text('Kelola Laporan Warga'),
                  subtitle: const Text('Lihat dan update status laporan'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.of(context).pushNamed(ListLaporanAdminScreen.routeName),
                ),
              ),
              const SizedBox(height: 10),

              // Menu 3: Berita
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.article, color: Colors.blue),
                  ),
                  title: const Text('Publikasi Berita'),
                  subtitle: const Text('Buat pengumuman atau berita desa'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.of(context).pushNamed(FormBeritaScreen.routeName),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4, offset: const Offset(0, 4))],
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