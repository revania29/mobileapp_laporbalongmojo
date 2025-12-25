import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapor_balongmojo/providers/auth_provider.dart';
import 'package:lapor_balongmojo/providers/berita_provider.dart';
import 'package:lapor_balongmojo/screens/auth/login_screen.dart';
import 'package:lapor_balongmojo/screens/masyarakat/form_laporan_screen.dart';
import 'package:lapor_balongmojo/screens/masyarakat/riwayat_laporan_screen.dart';
import 'package:lapor_balongmojo/screens/masyarakat/detail_berita_screen.dart'; 
import 'package:lapor_balongmojo/services/api_service.dart';
import 'package:lapor_balongmojo/utils/ui_utils.dart';


class HomeScreenMasyarakat extends StatefulWidget {
  static const routeName = '/home-masyarakat';
  const HomeScreenMasyarakat({super.key});

  @override
  State<HomeScreenMasyarakat> createState() => _HomeScreenMasyarakatState();
}

class _HomeScreenMasyarakatState extends State<HomeScreenMasyarakat> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BeritaProvider>(context, listen: false).fetchBerita();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final beritaData = Provider.of<BeritaProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lapor Balongmojo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Konfirmasi Logout'),
                  content: const Text('Apakah Anda yakin ingin keluar aplikasi?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Batal')),
                    TextButton(
                      onPressed: () async {
                        final rootNavigator = Navigator.of(context);
                        final scaffoldContext = context;
                        Navigator.of(ctx).pop();
                        await Provider.of<AuthProvider>(context, listen: false).logout();
                        if (!scaffoldContext.mounted) return;
                        UiUtils.showSuccess(scaffoldContext, "Anda berhasil keluar. Sampai jumpa!");
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
        onRefresh: () => Provider.of<BeritaProvider>(context, listen: false).fetchBerita(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.account_circle, size: 80, color: Colors.indigo),
                    const SizedBox(height: 10),
                    Text('Halo, ${user?.nama ?? "Warga"}!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const Text('Selamat datang di layanan pengaduan desa.'),
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).pushNamed(FormLaporanScreen.routeName),
                            icon: const Icon(Icons.add_a_photo),
                            label: const Text('Lapor'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => Navigator.of(context).pushNamed(RiwayatLaporanScreen.routeName),
                            icon: const Icon(Icons.history),
                            label: const Text('Riwayat'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              side: const BorderSide(color: Colors.indigo),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              const Text("Berita Desa Terkini", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              beritaData.isLoading
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                  : beritaData.listBerita.isEmpty
                      ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Belum ada berita.")))
                      : ListView.builder(
                          shrinkWrap: true, 
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: beritaData.listBerita.length,
                          itemBuilder: (ctx, i) {
                            final berita = beritaData.listBerita[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 2,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    DetailBeritaScreen.routeName,
                                    arguments: berita,
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (berita.gambarUrl != null)
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                        child: Image.network(
                                          '${ApiService.publicBaseUrl}${berita.gambarUrl}',
                                          height: 150,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (ctx, err, _) => Container(height: 150, color: Colors.grey[200], child: const Icon(Icons.image)),
                                        ),
                                      ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            berita.judul,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            berita.isi,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }
}