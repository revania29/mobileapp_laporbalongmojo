import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lapor_balongmojo/providers/laporan_provider.dart';
import 'package:lapor_balongmojo/models/laporan_model.dart';
import 'package:lapor_balongmojo/services/api_service.dart';
// IMPORT INI YANG DIBUTUHKAN (PASTIKAN FILE NO.3 DIATAS SUDAH DIBUAT)
import 'package:lapor_balongmojo/screens/masyarakat/detail_laporan_screen.dart';
import 'dart:ui'; 

class RiwayatLaporanScreen extends StatefulWidget {
  const RiwayatLaporanScreen({super.key});

  @override
  State<RiwayatLaporanScreen> createState() => _RiwayatLaporanScreenState();
}

class _RiwayatLaporanScreenState extends State<RiwayatLaporanScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<LaporanProvider>(context, listen: false).fetchLaporan()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LaporanProvider>(
      builder: (context, provider, child) {
        // PERBAIKAN: Gunakan 'isLoading' dari Provider yang sudah kita fix di LaporanProvider
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
        }

        if (provider.laporanList.isEmpty) {
          return const Center(child: Text("Belum ada riwayat.", style: TextStyle(color: Colors.white54)));
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          itemCount: provider.laporanList.length,
          separatorBuilder: (ctx, index) => const SizedBox(height: 16),
          itemBuilder: (ctx, index) {
            final laporan = provider.laporanList[index];
            return _RiwayatCardItem(laporan: laporan);
          },
        );
      },
    );
  }
}

// --- ITEM RIWAYAT DENGAN HOVER ---
class _RiwayatCardItem extends StatefulWidget {
  final LaporanModel laporan;
  const _RiwayatCardItem({required this.laporan});

  @override
  State<_RiwayatCardItem> createState() => _RiwayatCardItemState();
}

class _RiwayatCardItemState extends State<_RiwayatCardItem> {
  bool _isHovering = false;
  bool _isPressed = false;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu': return Colors.orangeAccent;
      case 'proses': return Colors.blueAccent;
      case 'selesai': return Colors.greenAccent;
      case 'ditolak': return Colors.redAccent;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(widget.laporan.status);
    final isActive = _isHovering || _isPressed;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () async {
          setState(() => _isPressed = true);
          await Future.delayed(const Duration(milliseconds: 100));
          if (!mounted) return;
          setState(() => _isPressed = false);
          // Navigasi ke Detail Laporan
          Navigator.push(context, MaterialPageRoute(builder: (context) => DetailLaporanScreen(laporan: widget.laporan)));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutBack,
          transform: Matrix4.identity()..scale(isActive ? 1.02 : 1.0),
          
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isActive ? statusColor.withOpacity(0.1) : Colors.white.withOpacity(0.05),
            border: Border.all(
              color: isActive ? statusColor.withOpacity(0.8) : Colors.white.withOpacity(0.1),
              width: isActive ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isActive ? statusColor.withOpacity(0.2) : Colors.black.withOpacity(0.1),
                blurRadius: isActive ? 20 : 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    image: (widget.laporan.fotoUrl != null && widget.laporan.fotoUrl!.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage('${ApiService.publicBaseUrl}${widget.laporan.fotoUrl}'),
                            fit: BoxFit.cover)
                        : null,
                  ),
                  child: (widget.laporan.fotoUrl == null || widget.laporan.fotoUrl!.isEmpty)
                      ? const Icon(Icons.description, color: Colors.white30)
                      : null,
                ),
                const SizedBox(width: 15),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.laporan.judul, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(DateFormat('dd MMM yyyy').format(widget.laporan.tanggal), style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: statusColor.withOpacity(0.5), width: 0.5)
                        ),
                        child: Text(widget.laporan.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.2), size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}