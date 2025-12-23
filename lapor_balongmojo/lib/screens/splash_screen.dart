import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapor_balongmojo/providers/auth_provider.dart';
import 'package:lapor_balongmojo/screens/auth/login_screen.dart';
import 'package:lapor_balongmojo/screens/masyarakat/home_screen_masyarakat.dart';
import 'package:lapor_balongmojo/screens/perangkat/dashboard_screen_perangkat.dart';

class SplashScreen extends StatefulWidget {
  static const routeName = '/splash';
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Delay estetika agar logo terlihat
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final isAuth = await auth.tryAutoLogin();

    if (!mounted) return;

    if (isAuth) {
      if (auth.user?.role == 'perangkat') {
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
      // HAPUS backgroundColor solid, GANTI dengan Container Gradient
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.indigo, Colors.teal], // Gradasi warna brand
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo dalam lingkaran putih
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2), // Shadow halus
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ]
                ),
                child: const Icon(Icons.verified_user, size: 70, color: Colors.indigo),
              ),
              const SizedBox(height: 24),
              
              // Teks Judul
              const Text(
                'LAPOR\nBALONGMOJO',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                  height: 1.2,
                ),
              ),
              
              const SizedBox(height: 50),
              
              // Loading Indicator Putih
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
              
              const SizedBox(height: 20),
              const Text(
                'Versi 1.0.0',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}