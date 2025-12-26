import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import Provider
import 'package:lapor_balongmojo/providers/auth_provider.dart';

// Import Widget & Screen Lain
import 'package:lapor_balongmojo/widgets/custom_textfield.dart';
import 'package:lapor_balongmojo/widgets/primary_button.dart';
import 'package:lapor_balongmojo/screens/auth/register_masyarakat_screen.dart';

// --- PENTING: Import Halaman Tujuan ---
import 'package:lapor_balongmojo/screens/perangkat/dashboard_screen_perangkat.dart';
import 'package:lapor_balongmojo/screens/masyarakat/home_screen_masyarakat.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    // 1. Validasi Form
    if (!_formKey.currentState!.validate()) {
      return; 
    }
    _formKey.currentState!.save();
    
    setState(() { _isLoading = true; });
    
    try {
      // 2. Panggil Fungsi Login di Provider
      await Provider.of<AuthProvider>(context, listen: false).login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Cek apakah widget masih aktif sebelum navigasi
      if (!mounted) return;

      // 3. Ambil Role User untuk menentukan halaman tujuan
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final role = authProvider.userRole;

      print("Login Berhasil. Role: $role. Mengalihkan halaman...");

      // 4. Logika Navigasi Berdasarkan Role
      if (role == 'perangkat' || role == 'admin') {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const DashboardScreenPerangkat()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => const HomeScreenMasyarakat()),
        );
      }

    } catch (error) {
      // 5. Tampilkan Error jika login gagal
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // 6. Matikan loading
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo atau Judul
                Text(
                  'Lapor Balongmojo',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 32),

                // Input Email
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!val.contains('@')) {
                      return 'Masukkan email yang valid';
                    }
                    return null;
                  },
                ),

                // Input Password
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  icon: Icons.lock,
                  isObscure: true,
                  validator: (val) =>
                      val!.isEmpty ? 'Password tidak boleh kosong' : null,
                ),
                
                const SizedBox(height: 24),

                // Tombol Login
                PrimaryButton(
                  text: 'LOGIN',
                  onPressed: _submitLogin,
                  isLoading: _isLoading,
                ),

                // Tombol Daftar
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(RegisterMasyarakatScreen.routeName);
                  },
                  child: const Text('Belum punya akun? Daftar (Masyarakat)'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}