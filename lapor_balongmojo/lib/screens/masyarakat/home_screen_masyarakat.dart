import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapor_balongmojo/providers/auth_provider.dart';
import 'package:lapor_balongmojo/screens/auth/login_screen.dart';
import 'package:lapor_balongmojo/screens/masyarakat/form_laporan_screen.dart';

class HomeScreenMasyarakat extends StatelessWidget {
  static const routeName = '/home-masyarakat';
  const HomeScreenMasyarakat({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lapor Balongmojo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (!context.mounted) return;
              Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Halo, ${user?.nama ?? "Warga"}!', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Laporkan masalah di sekitarmu.'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(FormLaporanScreen.routeName);
        },
        label: const Text('Lapor'),
        icon: const Icon(Icons.add_a_photo),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}