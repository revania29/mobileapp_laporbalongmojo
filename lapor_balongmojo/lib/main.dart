import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapor_balongmojo/providers/auth_provider.dart';
import 'package:lapor_balongmojo/screens/auth/login_screen.dart';
import 'package:lapor_balongmojo/screens/auth/register_masyarakat_screen.dart';
import 'package:lapor_balongmojo/screens/masyarakat/home_screen_masyarakat.dart';
import 'package:lapor_balongmojo/screens/masyarakat/form_laporan_screen.dart';

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
        
        initialRoute: LoginScreen.routeName, 
        
        routes: {
          LoginScreen.routeName: (ctx) => const LoginScreen(),
          RegisterMasyarakatScreen.routeName: (ctx) => const RegisterMasyarakatScreen(),
          HomeScreenMasyarakat.routeName: (ctx) => const HomeScreenMasyarakat(),
          FormLaporanScreen.routeName: (ctx) => const FormLaporanScreen(),
        },
      ),
    );
  }
}