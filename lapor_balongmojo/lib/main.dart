import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapor_balongmojo/providers/auth_provider.dart';
import 'package:lapor_balongmojo/screens/auth/login_screen.dart';
import 'package:lapor_balongmojo/screens/auth/register_masyarakat_screen.dart';

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
        ),
        initialRoute: LoginScreen.routeName, 
        
        routes: {
          LoginScreen.routeName: (ctx) => const LoginScreen(),
          RegisterMasyarakatScreen.routeName: (ctx) => const RegisterMasyarakatScreen(),
        },
      ),
    );
  }
}