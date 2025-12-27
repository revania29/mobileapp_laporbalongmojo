import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lapor_balongmojo/models/berita_model.dart';
import 'package:lapor_balongmojo/services/api_service.dart';
import 'package:lapor_balongmojo/widgets/glass_card.dart';

class DetailBeritaScreen extends StatefulWidget {
  final BeritaModel berita;
  const DetailBeritaScreen({super.key, required this.berita});

  @override
  State<DetailBeritaScreen> createState() => _DetailBeritaScreenState();
}

class _DetailBeritaScreenState extends State<DetailBeritaScreen> {
  late bool _isDarurat;
  final ApiService _apiService = ApiService();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _isDarurat = widget.berita.isPeringatanDarurat;
  }

  Future<void> _updateStatusBerita(bool isDarurat) async {
    setState(() => _isUpdating = true);
    try {
      await _apiService.updateBerita(
        widget.berita.id,
        widget.berita.judul,
        widget.berita.isi,
        widget.berita.gambarUrl,
        isDarurat,
      );
      setState(() => _isDarurat = isDarurat);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isDarurat ? "Mode DARURAT Aktif" : "Mode AMAN Aktif"),
          backgroundColor: isDarurat ? Colors.red : Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Gagal memperbarui: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
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
          title: const Text("DETAIL BERITA",
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.2)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isDarurat)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const Center(
                    child: Text("⚠️ PERINGATAN DARURAT",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                ),
              
              // Kartu Utama Berita
              GlassCard(
                opacity: 0.1,
                color: Colors.black,
                padding: const EdgeInsets.all(0), // Padding nol agar gambar bisa menempel ke pinggir atas
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar Berita di dalam kartu (Bagian Atas)
                    if (widget.berita.gambarUrl != null && widget.berita.gambarUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.network(
                          '${ApiService.publicBaseUrl}${widget.berita.gambarUrl!}',
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: Colors.white10,
                            child: const Icon(Icons.broken_image, color: Colors.white24, size: 50),
                          ),
                        ),
                      ),
                    
                    // Konten Teks di bawah gambar
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.berita.judul,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.2),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded,
                                  color: Colors.cyanAccent, size: 14),
                              const SizedBox(width: 8),
                              Text(
                                // Menambahkan Jam (HH:mm)
                                DateFormat('EEEE, dd MMM yyyy • HH:mm')
                                    .format(widget.berita.createdAt),
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 13),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white10, height: 35),
                          Text(
                            widget.berita.isi,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16,
                                height: 1.6),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              const Text(
                "Ubah Status Berita:",
                style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              const SizedBox(height: 10),
              
              // Pengaturan Status (Dropdown)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _isDarurat ? 'DARURAT' : 'AMAN',
                    dropdownColor: const Color(0xFF2E004F),
                    icon: _isUpdating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.arrow_drop_down_circle_outlined,
                            color: Colors.white),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                    isExpanded: true,
                    items: ['AMAN', 'DARURAT']
                        .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style: TextStyle(
                                      color: value == 'DARURAT'
                                          ? Colors.redAccent
                                          : Colors.greenAccent)),
                            ))
                        .toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        bool newStatus = (newValue == 'DARURAT');
                        if (newStatus != _isDarurat) {
                          _updateStatusBerita(newStatus);
                        }
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}