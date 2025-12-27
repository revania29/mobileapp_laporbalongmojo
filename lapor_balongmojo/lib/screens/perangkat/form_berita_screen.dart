import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lapor_balongmojo/services/api_service.dart';
import 'package:lapor_balongmojo/models/berita_model.dart';
import 'package:lapor_balongmojo/widgets/glass_card.dart';

class FormBeritaScreen extends StatefulWidget {
  final BeritaModel? beritaToEdit;

  const FormBeritaScreen({super.key, this.beritaToEdit});

  @override
  State<FormBeritaScreen> createState() => _FormBeritaScreenState();
}

class _FormBeritaScreenState extends State<FormBeritaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _isiController = TextEditingController();
  
  bool _isPeringatanDarurat = false;
  bool _isLoading = false;
  
  File? _pickedImage;
  String? _existingImageUrl;
  
  final ApiService _apiService = ApiService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.beritaToEdit != null) {
      _judulController.text = widget.beritaToEdit!.judul;
      _isiController.text = widget.beritaToEdit!.isi;
      _isPeringatanDarurat = widget.beritaToEdit!.isPeringatanDarurat;
      _existingImageUrl = widget.beritaToEdit!.gambarUrl;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source, imageQuality: 80);
      if (image == null) return;
      
      final File imageFile = File(image.path);
      final int size = await imageFile.length();
      if (size > 5 * 1024 * 1024) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ukuran gambar max 5MB"), backgroundColor: Colors.red));
        return;
      }

      setState(() {
        _pickedImage = imageFile;
      });
    } catch (e) {
      print("Error pick image: $e");
    }
  }

  void _clearImage() {
    setState(() {
      _pickedImage = null;
      _existingImageUrl = null;
    });
  }

  Future<void> _submitBerita() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? finalImageUrl = _existingImageUrl;

      if (_pickedImage != null) {
        finalImageUrl = await _apiService.uploadImage(_pickedImage!);
      }

      if (widget.beritaToEdit != null) {
        await _apiService.updateBerita(
          widget.beritaToEdit!.id,
          _judulController.text,
          _isiController.text,
          finalImageUrl,
          _isPeringatanDarurat,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berita diperbarui!'), backgroundColor: Colors.green));
      } else {
        await _apiService.createBerita(
          _judulController.text,
          _isiController.text,
          finalImageUrl,
          _isPeringatanDarurat,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berita diterbitkan!'), backgroundColor: Colors.green));
      }

      Navigator.of(context).pop();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.beritaToEdit != null;

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
          title: Text(isEdit ? "EDIT BERITA" : "BUAT BERITA BARU", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
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
                      hintText: 'Judul Berita',
                      hintStyle: TextStyle(color: Colors.white54),
                      icon: Icon(Icons.title, color: Colors.white70),
                      border: InputBorder.none,
                    ),
                    validator: (val) => val!.isEmpty ? 'Judul wajib diisi' : null,
                  ),
                ),
                const SizedBox(height: 20),

                GlassCard(
                  opacity: _isPeringatanDarurat ? 0.4 : 0.15,
                  color: _isPeringatanDarurat ? Colors.red.shade900 : Colors.black,
                  borderColor: _isPeringatanDarurat ? Colors.redAccent : null,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: SwitchListTile(
                    title: const Text("Peringatan Darurat?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      _isPeringatanDarurat ? "Notifikasi bahaya akan dikirim!" : "Berita informasi biasa.",
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                    ),
                    value: _isPeringatanDarurat,
                    activeThumbColor: Colors.white,
                    activeTrackColor: Colors.redAccent,
                    secondary: Icon(Icons.warning_amber_rounded, color: _isPeringatanDarurat ? Colors.white : Colors.white54, size: 30),
                    onChanged: (val) {
                      setState(() => _isPeringatanDarurat = val);
                    },
                  ),
                ),
                const SizedBox(height: 20),

                GlassCard(
                  opacity: 0.15,
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: TextFormField(
                    controller: _isiController,
                    maxLines: 8,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      hintText: 'Tulis isi berita...',
                      hintStyle: TextStyle(color: Colors.white54),
                      icon: Icon(Icons.article_outlined, color: Colors.white70),
                      border: InputBorder.none,
                    ),
                    validator: (val) => val!.isEmpty ? 'Isi berita wajib diisi' : null,
                  ),
                ),
                const SizedBox(height: 25),

                GlassCard(
                  opacity: 0.1,
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text("Lampirkan Foto", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      
                      GestureDetector(
                        onTap: () => _pickImage(ImageSource.gallery),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white30, width: 2, style: BorderStyle.solid),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: _buildImagePreview(),
                          ),
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
                          
                          if (_pickedImage != null || _existingImageUrl != null) ...[
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
                    gradient: LinearGradient(
                      colors: isEdit 
                          ? [Colors.orange.shade800, Colors.deepOrange]
                          : [const Color(0xFF7B1FA2), const Color(0xFF4A148C)], 
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitBerita,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            isEdit ? 'SIMPAN PERUBAHAN' : 'TERBITKAN BERITA',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
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

  Widget _buildImagePreview() {
    if (_pickedImage != null) {
      return Image.file(_pickedImage!, fit: BoxFit.cover);
    } else if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      return Image.network(
        '${ApiService.publicBaseUrl}$_existingImageUrl',
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => const Center(child: Icon(Icons.broken_image, color: Colors.white54)),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add_photo_alternate_rounded, size: 50, color: Colors.white38),
          SizedBox(height: 10),
          Text("Preview Foto", style: TextStyle(color: Colors.white54)),
        ],
      );
    }
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
        padding: const EdgeInsets.symmetric(vertical: 12), // Padding horizontal dihapus
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, textAlign: TextAlign.center),
    );
  }
}