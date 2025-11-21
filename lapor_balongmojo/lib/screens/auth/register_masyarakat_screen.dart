import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapor_balongmojo/providers/auth_provider.dart';
import 'package:lapor_balongmojo/widgets/custom_textfield.dart';
import 'package:lapor_balongmojo/widgets/primary_button.dart';

class RegisterMasyarakatScreen extends StatefulWidget {
  static const routeName = '/register-masyarakat';
  const RegisterMasyarakatScreen({super.key});

  @override
  State<RegisterMasyarakatScreen> createState() => _RegisterMasyarakatScreenState();
}

class _RegisterMasyarakatScreenState extends State<RegisterMasyarakatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(context, listen: false).register(
        _namaController.text,
        _emailController.text,
        _phoneController.text,
        _passwordController.text,
      );
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi Berhasil! Silakan Login.')),
      );
      Navigator.of(context).pop(); 
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: ${e.toString()}')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(controller: _namaController, labelText: 'Nama Lengkap', icon: Icons.person),
              CustomTextField(controller: _emailController, labelText: 'Email', icon: Icons.email, keyboardType: TextInputType.emailAddress),
              CustomTextField(controller: _phoneController, labelText: 'No. Telepon', icon: Icons.phone, keyboardType: TextInputType.phone),
              CustomTextField(controller: _passwordController, labelText: 'Password', icon: Icons.lock, isPassword: true),
              const SizedBox(height: 24),
              PrimaryButton(text: 'DAFTAR SEKARANG', onPressed: _submit, isLoading: _isLoading),
            ],
          ),
        ),
      ),
    );
  }
}