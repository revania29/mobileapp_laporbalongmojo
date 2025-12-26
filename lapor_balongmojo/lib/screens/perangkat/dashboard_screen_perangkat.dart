import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lapor_balongmojo/providers/auth_provider.dart';
import 'package:lapor_balongmojo/providers/laporan_provider.dart';
// Import Form Berita
import 'package:lapor_balongmojo/screens/perangkat/form_berita_screen.dart';
import 'package:lapor_balongmojo/screens/perangkat/verifikasi_user_screen.dart'; 
import 'package:lapor_balongmojo/services/api_service.dart';
import 'package:lapor_balongmojo/models/laporan_model.dart';
import 'package:lapor_balongmojo/models/berita_model.dart';
import 'package:lapor_balongmojo/widgets/glass_card.dart'; 
// Import Detail Screens
import 'package:lapor_balongmojo/screens/perangkat/detail_laporan_screen.dart'; 
import 'package:lapor_balongmojo/screens/perangkat/detail_berita_screen.dart'; 

class DashboardScreenPerangkat extends StatefulWidget {
  static const routeName = '/dashboard-perangkat';
  const DashboardScreenPerangkat({super.key});

  @override
  State<DashboardScreenPerangkat> createState() => _DashboardScreenPerangkatState();
}

class _DashboardScreenPerangkatState extends State<DashboardScreenPerangkat> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  late Future<List<BeritaModel>> _beritaFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // 1. Auto Refresh saat awal buka
    _refreshData(); 

    // 2. Auto Refresh saat ada notifikasi
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data['refresh'] == 'true' || true) {
        _refreshData();
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Data baru diterima!"), backgroundColor: Colors.green));
        }
      }
    });
  }

  Future<void> _refreshData() async { 
    if (mounted) {
      // Refresh Laporan via Provider
      await Provider.of<LaporanProvider>(context, listen: false).fetchLaporan();
      // Refresh Berita (setState untuk memicu FutureBuilder ulang)
      setState(() { _beritaFuture = _apiService.getBerita(); }); 
    }
  }

  void _showDeleteConfirm(BuildContext context, int id, bool isBerita) {
     showDialog(context: context, builder: (ctx) => AlertDialog(backgroundColor: const Color(0xFF2E004F), title: Text(isBerita ? "Hapus Berita?" : "Hapus?", style: const TextStyle(color: Colors.white)), actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal", style: TextStyle(color: Colors.grey))), TextButton(onPressed: () async { Navigator.pop(ctx); if(isBerita) await _apiService.deleteBerita(id); _refreshData(); }, child: const Text("Hapus", style: TextStyle(color: Colors.redAccent)))]));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2E004F), Color(0xFF6A0059)]), 
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, 
        appBar: AppBar(
          title: const Text('PERANGKAT DESA', style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            // ✅ TOMBOL REFRESH DIHAPUS, TINGGAL LOGOUT
            IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.white), onPressed: () {
                Provider.of<AuthProvider>(context, listen: false).logout();
                Navigator.of(context).pushReplacementNamed('/login');
            }),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white12)),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
                labelColor: const Color(0xFF311B92), unselectedLabelColor: Colors.white60, indicatorSize: TabBarIndicatorSize.tab, dividerColor: Colors.transparent, labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: const [Tab(text: 'Berita'), Tab(text: 'Laporan'), Tab(text: 'User')],
              ),
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildBeritaTab(), 
            _buildLaporanTab(), 
            const VerifikasiUserScreen(), 
          ],
        ),
        
        // FAB BULAT UNGU
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF7B1FA2), 
          foregroundColor: Colors.white,
          elevation: 10,
          shape: const CircleBorder(),
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const FormBeritaScreen()));
            _refreshData();
          },
          child: const Icon(Icons.add, size: 32, weight: 700),
        ),
      ),
    );
  }

  // ✅ TAB BERITA DENGAN PULL-TO-REFRESH
  Widget _buildBeritaTab() {
    return FutureBuilder<List<BeritaModel>>(
      future: _beritaFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
        
        // Handling jika kosong tetap bisa di-refresh
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refreshData,
            color: const Color(0xFF7B1FA2),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                 SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                 const Center(child: Text("Belum ada berita", style: TextStyle(color: Colors.white54))),
              ],
            ),
          );
        }

        // List Berita
        return RefreshIndicator(
          onRefresh: _refreshData,
          color: const Color(0xFF7B1FA2),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(), // Agar bisa ditarik meski item sedikit
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 100), 
            itemCount: snapshot.data!.length, 
            separatorBuilder: (ctx, index) => const SizedBox(height: 15),
            itemBuilder: (ctx, index) {
              final berita = snapshot.data![index];
              final bool isDarurat = berita.isPeringatanDarurat;
              Color statusColor = isDarurat ? Colors.redAccent : Colors.blueAccent;

              return GlassCard(
                opacity: 0.15,
                color: isDarurat ? Colors.red.shade900 : Colors.black, 
                borderColor: statusColor.withOpacity(0.5),
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => DetailBeritaScreen(berita: berita)));
                  _refreshData();
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    Row(
                      children: [
                        if(isDarurat) Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFD50000), borderRadius: BorderRadius.circular(6)), child: const Text("DARURAT", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                        Expanded(child: Text(berita.judul, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 16, height: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        GestureDetector(
                          onTapDown: (details) async {
                            final position = RelativeRect.fromLTRB(details.globalPosition.dx, details.globalPosition.dy, 0, 0);
                            await showMenu(context: context, position: position, color: const Color(0xFF2E004F), items: [const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Colors.white, size: 18), SizedBox(width: 8), Text("Edit Isi", style: TextStyle(color: Colors.white))])), const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.redAccent, size: 18), SizedBox(width: 8), Text("Hapus Berita", style: TextStyle(color: Colors.redAccent))]))]).then((value) {
                              if (value == 'edit') Navigator.push(context, MaterialPageRoute(builder: (_) => FormBeritaScreen(beritaToEdit: berita))).then((_) => _refreshData());
                              else if (value == 'delete') _showDeleteConfirm(context, berita.id, true);
                            });
                          },
                          child: const Icon(Icons.more_vert, color: Colors.white54, size: 20),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(DateFormat('dd MMM yyyy, HH:mm').format(berita.createdAt), style: const TextStyle(color: Colors.white54, fontSize: 11)),
                  ]),
              );
            },
          ),
        );
      },
    );
  }

  // ✅ TAB LAPORAN DENGAN PULL-TO-REFRESH
  Widget _buildLaporanTab() {
    return Consumer<LaporanProvider>(
      builder: (context, provider, child) {
         if (provider.isLoading && provider.laporanList.isEmpty) return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
         
         // Handling kosong tapi bisa refresh
         if (provider.laporanList.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshData,
              color: const Color(0xFF7B1FA2),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  const Center(child: Text("Belum ada laporan", style: TextStyle(color: Colors.white54))),
                ],
              ),
            );
         }
         
         // List Laporan
         return RefreshIndicator(
           onRefresh: _refreshData,
           color: const Color(0xFF7B1FA2),
           child: ListView.separated(
             physics: const AlwaysScrollableScrollPhysics(),
             padding: const EdgeInsets.fromLTRB(20, 10, 20, 100), itemCount: provider.laporanList.length, separatorBuilder: (ctx, index) => const SizedBox(height: 12),
             itemBuilder: (ctx, index) {
                 final lap = provider.laporanList[index];
                 Color statusColor = Colors.orange;
                 if(lap.status == 'selesai') statusColor = Colors.green;
                 if(lap.status == 'tolak') statusColor = Colors.red;
                 if(lap.status == 'diproses') statusColor = Colors.blue; 

                 return GlassCard(
                   opacity: 0.15, color: Colors.black, borderColor: statusColor.withOpacity(0.5), 
                   onTap: () async {
                     await Navigator.push(context, MaterialPageRoute(builder: (_) => DetailLaporanScreen(laporan: lap)));
                     _refreshData(); 
                   },
                   child: Row(children: [
                       Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: statusColor.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: statusColor.withOpacity(0.3))), child: Icon(Icons.assignment_ind_rounded, color: statusColor, size: 24)),
                       const SizedBox(width: 15),
                       Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(lap.judul, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis), const SizedBox(height: 4), Text(lap.pelapor, style: const TextStyle(color: Colors.white54, fontSize: 12))])),
                       Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: statusColor.withOpacity(0.5)), color: statusColor.withOpacity(0.1)), child: Text(lap.status.toUpperCase(), style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)))
                   ]),
                 );
              },
           ),
         );
      },
    );
  }
}