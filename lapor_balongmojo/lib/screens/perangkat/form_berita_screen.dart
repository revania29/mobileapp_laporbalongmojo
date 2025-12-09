import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:lapor_balongmojo/providers/berita_provider.dart';
import 'package:lapor_balongmojo/widgets/custom_textfield.dart';

class FormBeritaScreen extends StatefulWidget {
  static const routeName = '/form-berita';
  const FormBeritaScreen({super.key});

  @override
  State<FormBeritaScreen> createState() => _FormBeritaScreenState();
}

class _FormBeritaScreenState extends State<FormBeritaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();
  
  File? _selectedImage;

  Future<void> _pickImage(ImageSource source) async {
    final returnedImage = await ImagePicker().pickImage(source: source);
    if (returnedImage == null) return;
    
    setState(() {
      _selectedImage = File(returnedImage.path);
    });
  }

  Future<void> _submitBerita() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap sertakan gambar sampul berita!')),
      );
      return;
    }

    try {
      await Provider.of<BeritaProvider>(context, listen: false).postBerita(
        _judulController.text,
        _isiController.text,
        _selectedImage!,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berita Berhasil Dipublikasikan!')),
      );
      Navigator.of(context).pop(); // Kembali ke Dashboard
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = Provider.of<BeritaProvider>(context).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tulis Berita Desa'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _judulController, 
                labelText: 'Judul Berita', 
                icon: Icons.title
              ),
              const SizedBox(height: 10),
              
              TextFormField(
                controller: _isiController,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: 'Isi Berita Lengkap',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  alignLabelWithHint: true,
                ),
                validator: (val) => val!.isEmpty ? 'Isi berita wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              
              // Preview Gambar
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : const Center(child: Text('Belum ada foto sampul', style: TextStyle(color: Colors.grey))),
              ),
              const SizedBox(height: 10),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Kamera'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeri'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submitBerita,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('PUBLIKASIKAN BERITA', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}