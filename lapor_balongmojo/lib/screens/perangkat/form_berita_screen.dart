import 'package:flutter/material.dart';

class FormBeritaScreen extends StatelessWidget {
  static const routeName = '/form-berita';
  const FormBeritaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Berita')),
      body: const Center(
        child: Text('Halaman ini akan dibuat di Hari 16-17'),
      ),
    );
  }
}