import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lapor_balongmojo/models/laporan_model.dart';
import 'package:lapor_balongmojo/services/api_service.dart';
import 'package:lapor_balongmojo/widgets/glass_card.dart';

class DetailLaporanScreen extends StatefulWidget {
  final LaporanModel laporan;
  const DetailLaporanScreen({super.key, required this.laporan});

  @override
  State<DetailLaporanScreen> createState() => _DetailLaporanScreenState();
}

class _DetailLaporanScreenState extends State<DetailLaporanScreen> {
  late String _currentStatus;
  final ApiService _apiService = ApiService();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.laporan.status;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isUpdating = true);
    try {
      await _apiService.updateStatusLaporan(widget.laporan.id, newStatus);
      setState(() => _currentStatus = newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Status: ${newStatus.toUpperCase()}"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _deleteLaporan() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2E004F),
        title: const Text("Hapus Laporan?", style: TextStyle(color: Colors.white)),
        content: const Text("Tindakan ini permanen.", style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal", style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Hapus", style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.deleteLaporan(widget.laporan.id);
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Laporan berhasil dihapus"), backgroundColor: Colors.red));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal hapus: $e"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.laporan.fotoUrl != null && widget.laporan.fotoUrl!.isNotEmpty;
    bool canDelete = _currentStatus == 'selesai' || _currentStatus == 'tolak';

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
          title: const Text("DETAIL LAPORAN", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
          child: Column(
            children: [
              Container(
                width: double.infinity, 
                margin: const EdgeInsets.only(bottom: 20), 
                padding: const EdgeInsets.symmetric(vertical: 12), 
                decoration: BoxDecoration(
                  color: const Color(0xFF4A148C).withOpacity(0.8), 
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24),
                ), 
                child: const Center(
                  child: Text("📋 LAPORAN WARGA", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),

              GlassCard(
                opacity: 0.15, 
                color: Colors.black, 
                borderColor: Colors.white24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasImage)
                      Container(
                        height: 250, 
                        width: double.infinity, 
                        margin: const EdgeInsets.only(bottom: 20), 
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15), 
                          image: DecorationImage(
                            image: NetworkImage('${ApiService.publicBaseUrl}${widget.laporan.fotoUrl}'), 
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    
                    Text(widget.laporan.judul, 
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    
                    Row(
                      children: [
                        const Icon(Icons.person_pin_rounded, color: Color(0xFFCE93D8), size: 20), 
                        const SizedBox(width: 8), 
                        Text(widget.laporan.pelapor, 
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        const Icon(Icons.phone_android_rounded, color: Color(0xFFCE93D8), size: 20), 
                        const SizedBox(width: 8), 
                        Text(widget.laporan.noTelepon ?? "Tidak ada nomor", 
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(Icons.access_time_filled_rounded, color: Colors.white54, size: 18),
                        const SizedBox(width: 8),
                        Text(DateFormat('EEEE, dd MMM yyyy, HH:mm').format(widget.laporan.tanggal), 
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                    
                    const Divider(color: Colors.white24, height: 30),
                    
                    Text(widget.laporan.deskripsi, 
                      style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5), 
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Align(
                alignment: Alignment.centerLeft, 
                child: Text("Update Status:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A148C), 
                  borderRadius: BorderRadius.circular(15), 
                  border: Border.all(color: Colors.white30),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: ['belum terdaftar', 'diproses', 'selesai', 'tolak'].contains(_currentStatus) ? _currentStatus : 'belum terdaftar',
                    dropdownColor: const Color(0xFF4A148C),
                    icon: _isUpdating 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                      : const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    isExpanded: true,
                    items: ['belum terdaftar', 'diproses', 'selesai', 'tolak']
                        .map((String value) => DropdownMenuItem<String>(
                              value: value, 
                              child: Text(value.toUpperCase(), style: const TextStyle(color: Colors.white)),
                            ))
                        .toList(),
                    onChanged: (newValue) { if (newValue != null && newValue != _currentStatus) _updateStatus(newValue); },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              if (canDelete)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.withOpacity(0.9), 
                      padding: const EdgeInsets.symmetric(vertical: 15), 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    icon: const Icon(Icons.delete_forever_rounded, color: Colors.white),
                    label: const Text("Hapus Laporan Ini", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    onPressed: _deleteLaporan,
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}