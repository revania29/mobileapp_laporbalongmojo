import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapor_balongmojo/providers/auth_provider.dart';
import 'package:lapor_balongmojo/widgets/custom_textfield.dart';
import 'package:lapor_balongmojo/widgets/primary_button.dart';
import 'package:lapor_balongmojo/screens/auth/register_masyarakat_screen.dart';

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .login(_emailController.text, _passwordController.text);
      
      if (!mounted) return;
      // Sementara ke halaman kosong dulu (Home belum dibuat)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Berhasil!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login Gagal: ${e.toString()}')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_police, size: 80, color: Colors.indigo),
                const SizedBox(height: 16),
                const Text("Lapor Balongmojo", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                CustomTextField(controller: _emailController, labelText: 'Email', icon: Icons.email, keyboardType: TextInputType.emailAddress),
                CustomTextField(controller: _passwordController, labelText: 'Password', icon: Icons.lock, isPassword: true),
                const SizedBox(height: 24),
                PrimaryButton(text: 'MASUK', onPressed: _submit, isLoading: _isLoading),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed(RegisterMasyarakatScreen.routeName);
                  },
                  child: const Text('Belum punya akun? Daftar disini'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}