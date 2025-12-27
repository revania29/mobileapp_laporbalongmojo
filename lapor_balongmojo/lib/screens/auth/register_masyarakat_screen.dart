import 'package:flutter/material.dart';
import 'package:lapor_balongmojo/providers/auth_provider.dart';
import 'package:lapor_balongmojo/widgets/custom_textfield.dart';
import 'package:lapor_balongmojo/widgets/primary_button.dart';
import 'package:provider/provider.dart';

class RegisterMasyarakatScreen extends StatefulWidget {
  static const routeName = '/register-masyarakat';
  const RegisterMasyarakatScreen({super.key});

  @override
  State<RegisterMasyarakatScreen> createState() =>
      _RegisterMasyarakatScreenState();
}

class _RegisterMasyarakatScreenState extends State<RegisterMasyarakatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noTelpController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noTelpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() { _isLoading = true; });

    try {
      await Provider.of<AuthProvider>(context, listen: false)
          .registerMasyarakat(
        _namaController.text.trim(),
        _emailController.text.trim(),
        _noTelpController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan tunggu verifikasi perangkat desa.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        )
      );
      Navigator.of(context).pop();

    } catch (error) {
      if (mounted) {
        // ✅ Membersihkan pesan error agar tidak muncul tulisan "Exception: "
        String errorMessage = error.toString()
            .replaceAll('Exception: ', '')
            .replaceAll('Exception:', '')
            .trim();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun Masyarakat'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _namaController,
                labelText: 'Nama Lengkap',
                icon: Icons.person,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailController,
                labelText: 'Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Wajib diisi';
                  if (!val.contains('@')) return 'Masukkan email yang valid';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _noTelpController,
                labelText: 'No. Telepon',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                labelText: 'Password',
                icon: Icons.lock,
                isObscure: true,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Wajib diisi';
                  if (val.length < 6) return 'Password minimal 6 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'DAFTAR',
                onPressed: _submitRegister,
                isLoading: _isLoading,
              )
            ],
          ),
        ),
      ),
    );
  }
}