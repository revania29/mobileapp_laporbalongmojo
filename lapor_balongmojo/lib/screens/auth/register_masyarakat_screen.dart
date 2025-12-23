import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lapor_balongmojo/providers/auth_provider.dart';
import 'package:lapor_balongmojo/widgets/custom_textfield.dart';
import 'package:lapor_balongmojo/utils/ui_utils.dart';  

class RegisterMasyarakatScreen extends StatefulWidget {
  static const routeName = '/register-masyarakat';
  const RegisterMasyarakatScreen({super.key});

  @override
  State<RegisterMasyarakatScreen> createState() => _RegisterMasyarakatScreenState();
}

class _RegisterMasyarakatScreenState extends State<RegisterMasyarakatScreen> {
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nikController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _register() async {
    // Validasi input kosong manual
    if (_namaController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passwordController.text.isEmpty ||
        _nikController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      UiUtils.showError(context, "Semua field wajib diisi!");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Mengirim 5 Parameter ke Provider
      await Provider.of<AuthProvider>(context, listen: false).register(
        _namaController.text,
        _emailController.text,
        _passwordController.text,
        _nikController.text,
        _phoneController.text,
      );

      if (!mounted) return;
      
      UiUtils.showSuccess(context, "Pendaftaran berhasil! Silakan Login.");
      Navigator.of(context).pop(); 

    } catch (e) {
      if (!mounted) return;
      UiUtils.showError(context, "Gagal daftar: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun Warga')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.person_add, size: 60, color: Colors.indigo),
            const SizedBox(height: 20),
            
            CustomTextField(
              controller: _namaController, 
              labelText: 'Nama Lengkap', 
              icon: Icons.person
            ),
            const SizedBox(height: 12),
            
            CustomTextField(
              controller: _nikController, 
              labelText: 'NIK', 
              icon: Icons.badge, 
              keyboardType: TextInputType.number
            ),
            const SizedBox(height: 12),
            
            CustomTextField(
              controller: _phoneController, 
              labelText: 'No. Telepon', 
              icon: Icons.phone, 
              keyboardType: TextInputType.phone
            ),
            const SizedBox(height: 12),
            
            CustomTextField(
              controller: _emailController, 
              labelText: 'Email', 
              icon: Icons.email, 
              keyboardType: TextInputType.emailAddress
            ),
            const SizedBox(height: 12),
            
            // PERBAIKAN DI SINI:
            // Menggunakan isPassword: true (sesuai file custom_textfield.dart Anda)
            CustomTextField(
              controller: _passwordController, 
              labelText: 'Password', 
              icon: Icons.lock, 
              isPassword: true, // <-- Ganti obscureText jadi isPassword
            ),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                  : const Text('DAFTAR SEKARANG', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}