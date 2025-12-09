import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapor_balongmojo/providers/auth_provider.dart';
import 'package:lapor_balongmojo/providers/laporan_provider.dart';
import 'package:lapor_balongmojo/providers/berita_provider.dart'; 
import 'package:lapor_balongmojo/screens/auth/login_screen.dart';
import 'package:lapor_balongmojo/screens/auth/register_masyarakat_screen.dart';
import 'package:lapor_balongmojo/screens/splash_screen.dart';
import 'package:lapor_balongmojo/screens/masyarakat/home_screen_masyarakat.dart';
import 'package:lapor_balongmojo/screens/masyarakat/form_laporan_screen.dart';
import 'package:lapor_balongmojo/screens/masyarakat/riwayat_laporan_screen.dart';
import 'package:lapor_balongmojo/screens/perangkat/dashboard_screen_perangkat.dart';
import 'package:lapor_balongmojo/screens/perangkat/list_laporan_admin_screen.dart';
import 'package:lapor_balongmojo/screens/perangkat/detail_laporan_screen.dart';
import 'package:lapor_balongmojo/screens/perangkat/form_berita_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LaporanProvider()),
        ChangeNotifierProvider(create: (_) => BeritaProvider()),
      ],
      child: MaterialApp(
        title: 'Lapor Balongmojo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: Colors.grey[50],
          useMaterial3: false,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        
        initialRoute: SplashScreen.routeName, 
        
        routes: {
          SplashScreen.routeName: (ctx) => const SplashScreen(),
          LoginScreen.routeName: (ctx) => const LoginScreen(),
          RegisterMasyarakatScreen.routeName: (ctx) => const RegisterMasyarakatScreen(),
          
          HomeScreenMasyarakat.routeName: (ctx) => const HomeScreenMasyarakat(),
          FormLaporanScreen.routeName: (ctx) => const FormLaporanScreen(),
          RiwayatLaporanScreen.routeName: (ctx) => const RiwayatLaporanScreen(),
          
          DashboardScreenPerangkat.routeName: (ctx) => const DashboardScreenPerangkat(),
          ListLaporanAdminScreen.routeName: (ctx) => const ListLaporanAdminScreen(),
          DetailLaporanScreen.routeName: (ctx) => const DetailLaporanScreen(),
          FormBeritaScreen.routeName: (ctx) => const FormBeritaScreen(), // Route Baru Hari 17
        },
      ),
    );
  }
}