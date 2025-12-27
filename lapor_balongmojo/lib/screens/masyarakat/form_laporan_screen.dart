import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:lapor_balongmojo/providers/laporan_provider.dart';
import 'package:lapor_balongmojo/services/api_service.dart';
import 'package:lapor_balongmojo/widgets/glass_card.dart';

class FormLaporanScreen extends StatefulWidget {
  static const routeName = '/form-laporan';
  const FormLaporanScreen({super.key});

  @override
  State<FormLaporanScreen> createState() => _FormLaporanScreenState();
}

class _FormLaporanScreenState extends State<FormLaporanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final List<String> _listDusun = [
    'Setoyo',
    'Delik',
    'Karangnongko',
    'Soogo',
    'Balongwaru',
    'Jetak'
  ];
  String? _selectedDusun;

  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  final ApiService _apiService = ApiService(); 
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 80);
      if (image == null) return;

      final File imageFile = File(image.path);
      final int fileSize = await imageFile.length();
      final double fileSizeInMB = fileSize / (1024 * 1024);

      if (fileSizeInMB > 5.0) { 
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ukuran foto terlalu besar (Max 5MB)'), backgroundColor: Colors.red),
        );
        return; 
      }

      setState(() {
        _pickedImage = imageFile;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil gambar: $e')),
      );
    }
  }

  void _clearImage() {
    setState(() {
      _pickedImage = null;
    });
  }

  Future<void> _submitLaporan() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_pickedImage == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wajib menyertakan foto bukti!'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      String? uploadedUrl;
      if (_pickedImage != null) {
        uploadedUrl = await _apiService.uploadImage(_pickedImage!);
      }

      if (!mounted) return;
      String deskripsiFinal = "Lokasi: $_selectedDusun\n\n${_deskripsiController.text}";

      await Provider.of<LaporanProvider>(context, listen: false).addLaporan(
        _judulController.text, 
        deskripsiFinal, 
        uploadedUrl, 
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan berhasil dikirim!'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(); 

    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E004F), Color(0xFF6A0059)], 
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('BUAT LAPORAN BARU', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18, letterSpacing: 1)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GlassCard(
                  opacity: 0.15,
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: TextFormField(
                    controller: _judulController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Judul Laporan',
                      hintStyle: TextStyle(color: Colors.white70),
                      icon: Icon(Icons.title_rounded, color: Colors.white70),
                      border: InputBorder.none,
                    ),
                    validator: (val) => val!.isEmpty ? 'Judul wajib diisi' : null,
                  ),
                ),
                const SizedBox(height: 20),
                GlassCard(
                  opacity: 0.15,
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedDusun,
                    dropdownColor: const Color(0xFF4A148C), 
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    icon: const Icon(Icons.arrow_drop_down_circle, color: Colors.white70), 
                    
                    hint: const Text(
                      'Pilih Lokasi Dusun', 
                      style: TextStyle(color: Colors.white),
                    ),
                    
                    decoration: const InputDecoration(
                      icon: Icon(Icons.location_on, color: Colors.white70),
                      border: InputBorder.none,
                    ),
                    
                    items: _listDusun.map((String dusun) {
                      return DropdownMenuItem<String>(
                        value: dusun,
                        child: Text(dusun, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedDusun = newValue;
                      });
                    },
                    validator: (val) => val == null ? 'Lokasi dusun wajib dipilih' : null,
                  ),
                ),
                const SizedBox(height: 20),
                GlassCard(
                  opacity: 0.15,
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: TextFormField(
                    controller: _deskripsiController,
                    maxLines: 5,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Deskripsikan detail kejadian/masalah...',
                      hintStyle: TextStyle(color: Colors.white70),
                      icon: Icon(Icons.description_rounded, color: Colors.white70),
                      border: InputBorder.none,
                    ),
                    validator: (val) => val!.isEmpty ? 'Deskripsi wajib diisi' : null,
                  ),
                ),
                const SizedBox(height: 25),
                GlassCard(
                  opacity: 0.1,
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text("Foto Bukti Laporan", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 15),
                      
                      GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white30, width: 2, style: BorderStyle.solid),
                            image: _pickedImage != null
                                ? DecorationImage(image: FileImage(_pickedImage!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: _pickedImage == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.add_a_photo_rounded, size: 50, color: Colors.white38),
                                    SizedBox(height: 10),
                                    Text("Pilih foto", style: TextStyle(color: Colors.white54)),
                                  ],
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildMediaButton(Icons.camera_alt_rounded, "Kamera", ImageSource.camera),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: _buildMediaButton(Icons.photo_library_rounded, "Galeri", ImageSource.gallery),
                              ),
                            ],
                          ),
                          if (_pickedImage != null) ...[
                            const SizedBox(height: 15), // Jarak vertikal
                            _buildMediaButton(Icons.delete_forever, "Hapus Foto", null, isDelete: true),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),

                Container(
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7B1FA2), Color(0xFF4A148C)], 
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitLaporan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'KIRIM LAPORAN SEKARANG',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaButton(IconData icon, String label, ImageSource? source, {bool isDelete = false}) {
    return ElevatedButton.icon(
      onPressed: () {
        if (isDelete) {
          _clearImage();
        } else {
          _pickImage(source!);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isDelete ? Colors.red.withOpacity(0.2) : Colors.white.withOpacity(0.15),
        foregroundColor: isDelete ? Colors.redAccent : Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        side: BorderSide(color: isDelete ? Colors.redAccent.withOpacity(0.5) : Colors.white24),
        padding: const EdgeInsets.symmetric(vertical: 12), // Padding horizontal dihapus agar Expanded bekerja baik
      ),
      icon: Icon(icon, size: 20),
      label: Text(label, textAlign: TextAlign.center),
    );
  }
}