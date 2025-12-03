import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapor_balongmojo/providers/auth_provider.dart';
import 'package:lapor_balongmojo/screens/auth/login_screen.dart';
import 'package:lapor_balongmojo/screens/masyarakat/home_screen_masyarakat.dart';
import 'package:lapor_balongmojo/screens/perangkat/dashboard_screen_perangkat.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/'; // Route awal (root)
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLogged = await authProvider.tryAutoLogin();

    if (!mounted) return;

    if (isLogged) {
      // Cek Role untuk Auto Login
      if (authProvider.isAdmin) {
        Navigator.of(context).pushReplacementNamed(DashboardScreenPerangkat.routeName);
      } else {
        Navigator.of(context).pushReplacementNamed(HomeScreenMasyarakat.routeName);
      }
    } else {
      Navigator.of(context).pushReplacementNamed(LoginScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo, // Warna tema
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.local_police, size: 100, color: Colors.white),
            SizedBox(height: 20),
            Text(
              'Lapor Balongmojo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}