import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapor_balongmojo/providers/auth_provider.dart';
import 'package:lapor_balongmojo/providers/laporan_provider.dart';
import 'package:lapor_balongmojo/screens/auth/login_screen.dart';
import 'package:lapor_balongmojo/screens/perangkat/form_berita_screen.dart';
import 'package:lapor_balongmojo/screens/perangkat/list_laporan_admin_screen.dart';

class DashboardScreenPerangkat extends StatefulWidget {
  static const routeName = '/dashboard-perangkat';
  const DashboardScreenPerangkat({super.key});

  @override
  State<DashboardScreenPerangkat> createState() =>
      _DashboardScreenPerangkatState();
}

class _DashboardScreenPerangkatState extends State<DashboardScreenPerangkat> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LaporanProvider>(
        context,
        listen: false,
      ).fetchAllLaporanAdmin();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Consumer<LaporanProvider>(
      builder: (context, laporanData, child) {
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
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            final rootNavigator = Navigator.of(context);
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );

                            await authProvider.logout();

                            rootNavigator.pushNamedAndRemoveUntil(
                              LoginScreen.routeName,
                              (route) => false,
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
          body: laporanData.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang,',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      Text(
                        user?.nama ?? 'Admin Desa',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        "Statistik Laporan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              title: 'Menunggu',
                              count: laporanData.countMenunggu.toString(),
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              title: 'Proses',
                              count: laporanData.countProses.toString(),
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              title: 'Selesai',
                              count: laporanData.countSelesai.toString(),
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        "Menu Manajemen",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.teal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.assignment,
                              color: Colors.teal,
                            ),
                          ),
                          title: const Text('Kelola Laporan Warga'),
                          subtitle: const Text(
                            'Lihat dan update status laporan',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed(ListLaporanAdminScreen.routeName);
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.article,
                              color: Colors.blue,
                            ),
                          ),
                          title: const Text('Publikasi Berita'),
                          subtitle: const Text(
                            'Buat pengumuman atau berita desa',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.of(
                              context,
                            ).pushNamed(FormBeritaScreen.routeName);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String count;
  final Color color;

  const _StatCard({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
