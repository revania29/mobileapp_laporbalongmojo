import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lapor_balongmojo/providers/laporan_provider.dart';
import 'package:lapor_balongmojo/models/laporan_model.dart';
import 'package:lapor_balongmojo/services/api_service.dart';
import 'package:lapor_balongmojo/screens/masyarakat/detail_laporan_screen.dart';

class RiwayatLaporanScreen extends StatefulWidget {
  const RiwayatLaporanScreen({super.key});

  @override
  State<RiwayatLaporanScreen> createState() => _RiwayatLaporanScreenState();
}

class _RiwayatLaporanScreenState extends State<RiwayatLaporanScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    await Provider.of<LaporanProvider>(context, listen: false).fetchLaporan();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LaporanProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: _refreshData,
          color: Colors.cyanAccent,
          backgroundColor: const Color(0xFF2E004F),
          child: _buildContent(provider),
        );
      },
    );
  }

  Widget _buildContent(LaporanProvider provider) {
    if (provider.isLoading && provider.laporanList.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
    }

    if (provider.laporanList.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          const Center(
            child: Text(
              "Belum ada riwayat.\nTarik ke bawah untuk memuat ulang.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 150),
      itemCount: provider.laporanList.length,
      separatorBuilder: (ctx, index) => const SizedBox(height: 16),
      itemBuilder: (ctx, index) {
        final laporan = provider.laporanList[index];
        return _RiwayatCardItem(laporan: laporan, onRefresh: _refreshData);
      },
    );
  }
}

class _RiwayatCardItem extends StatefulWidget {
  final LaporanModel laporan;
  final Future<void> Function() onRefresh;
  const _RiwayatCardItem({required this.laporan, required this.onRefresh});

  @override
  State<_RiwayatCardItem> createState() => _RiwayatCardItemState();
}

class _RiwayatCardItemState extends State<_RiwayatCardItem> {
  bool _isHovering = false;
  bool _isPressed = false;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return Colors.orange;
      case 'proses':
      case 'diproses':
        return Colors.lightBlueAccent;
      case 'selesai':
        return Colors.greenAccent;
      case 'ditolak':
      case 'tolak':
        return Colors.redAccent;
      default:
        return Colors.white70;
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
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailLaporanScreen(laporan: widget.laporan),
            ),
          );
          widget.onRefresh();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutBack,
          transform: Matrix4.identity()..scale(isActive ? 1.02 : 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black.withOpacity(0.3),
            border: Border.all(
              color: statusColor.withOpacity(0.5),
              width: isActive ? 2.0 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.15),
                blurRadius: isActive ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white12),
                    image: (widget.laporan.fotoUrl != null &&
                            widget.laporan.fotoUrl!.isNotEmpty)
                        ? DecorationImage(
                            image: NetworkImage(
                                '${ApiService.publicBaseUrl}${widget.laporan.fotoUrl}'),
                            fit: BoxFit.cover)
                        : null,
                  ),
                  child: (widget.laporan.fotoUrl == null ||
                          widget.laporan.fotoUrl!.isEmpty)
                      ? const Icon(Icons.image_not_supported_outlined,
                          color: Colors.white24, size: 28)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.laporan.judul,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.calendar_month_outlined,
                              size: 12, color: Colors.white.withOpacity(0.5)),
                          const SizedBox(width: 4),
                          Text(
                              DateFormat('dd MMM yyyy')
                                  .format(widget.laporan.tanggal),
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: statusColor.withOpacity(0.6),
                                width: 1.0)),
                        child: Text(widget.laporan.status.toUpperCase(),
                            style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withOpacity(0.2), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}