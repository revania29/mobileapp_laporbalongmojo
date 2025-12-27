import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:ui'; 
import 'package:lapor_balongmojo/providers/auth_provider.dart';
import 'package:lapor_balongmojo/providers/laporan_provider.dart';
import 'package:lapor_balongmojo/services/api_service.dart';
import 'package:lapor_balongmojo/models/berita_model.dart';
import 'package:lapor_balongmojo/screens/masyarakat/form_laporan_screen.dart';
import 'package:lapor_balongmojo/screens/masyarakat/riwayat_laporan_screen.dart';
import 'package:lapor_balongmojo/screens/masyarakat/pages/home_page.dart';
import 'package:lapor_balongmojo/screens/masyarakat/berita_detail_screen.dart';
import 'package:lapor_balongmojo/widgets/glass_card.dart';
import 'package:lapor_balongmojo/screens/masyarakat/profile_screen.dart';

class HomeScreenMasyarakat extends StatefulWidget {
  static const routeName = '/home-masyarakat';
  const HomeScreenMasyarakat({super.key});

  @override
  State<HomeScreenMasyarakat> createState() => _HomeScreenMasyarakatState();
}

class _HomeScreenMasyarakatState extends State<HomeScreenMasyarakat> {
  int _selectedIndex = 1;

  static final List<Widget> _widgetOptions = <Widget>[
    const BeritaPage(),
    const HomePage(), 
    const RiwayatLaporanScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => Provider.of<LaporanProvider>(context, listen: false).fetchLaporan());
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2E004F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Keluar Akun",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Apakah Anda yakin ingin keluar dari aplikasi?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
            child: const Text(
              "Keluar",
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
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
        extendBody: true, 
        
        appBar: AppBar(
          title: const Text(
            'LAPOR BALONGMOJO', 
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white, fontSize: 20)
          ),
          centerTitle: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Theme(
                data: Theme.of(context).copyWith(
                  popupMenuTheme: PopupMenuThemeData(color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 10)),
                child: PopupMenuButton<String>(
                  offset: const Offset(0, 50),
                  icon: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: Colors.white30, width: 1.5)), child: const Icon(Icons.person_rounded, color: Colors.white, size: 24)),
                  onSelected: (value) async {
                    if (value == 'profile') {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                    } else if (value == 'logout') { 
                      _showLogoutDialog();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'profile', child: Row(children: [Icon(Icons.edit_rounded, color: Color(0xFF2E004F)), SizedBox(width: 12), Text("Edit Profil")])),
                    const PopupMenuItem(value: 'logout', child: Row(children: [Icon(Icons.logout_rounded, color: Colors.red), SizedBox(width: 12), Text("Keluar")])),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        body: _widgetOptions.elementAt(_selectedIndex),
        floatingActionButton: Container(
          height: 60, width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle, 
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFAB47BC), Color(0xFF7B1FA2)], 
            ), 
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7B1FA2).withOpacity(0.5),
                blurRadius: 15, 
                offset: const Offset(0, 5)
              )
            ]
          ),
          child: FloatingActionButton(
            backgroundColor: Colors.transparent, 
            elevation: 0, 
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const FormLaporanScreen())), 
            child: const Icon(Icons.add_rounded, size: 36, color: Colors.white)
          ),
        ),
        
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
          child: GlassCard(
            opacity: 0.25, blur: 20, color: Colors.black, borderColor: Colors.transparent, padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_buildNavItem(Icons.newspaper_rounded, 'Berita', 0), _buildNavItem(Icons.grid_view_rounded, 'Home', 1), _buildNavItem(Icons.history_edu_rounded, 'Riwayat', 2)]),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: isSelected ? BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.2), blurRadius: 10)]) : null,
        child: Row(children: [Icon(icon, color: isSelected ? const Color(0xFF2E004F) : Colors.white54, size: 24), if (isSelected) ...[const SizedBox(width: 8), Text(label, style: const TextStyle(color: Color(0xFF2E004F), fontWeight: FontWeight.bold, fontSize: 14))]]),
      ),
    );
  }
}

class BeritaPage extends StatefulWidget {
  const BeritaPage({super.key});
  @override
  State<BeritaPage> createState() => _BeritaPageState();
}

class _BeritaPageState extends State<BeritaPage> {
  late Future<List<BeritaModel>> _beritaFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _beritaFuture = _apiService.getBerita();
  }

  Future<void> _refreshBerita() async {
    setState(() { _beritaFuture = _apiService.getBerita(); });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshBerita,
      color: Colors.cyanAccent,
      backgroundColor: Colors.purple[900],
      child: FutureBuilder<List<BeritaModel>>(
        future: _beritaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada berita terbaru.', style: TextStyle(color: Colors.white54)));
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            itemCount: snapshot.data!.length,
            separatorBuilder: (ctx, index) => const SizedBox(height: 20),
            itemBuilder: (ctx, index) {
              return _BeritaCardItem(berita: snapshot.data![index]);
            },
          );
        },
      ),
    );
  }
}

class _BeritaCardItem extends StatefulWidget {
  final BeritaModel berita;
  const _BeritaCardItem({required this.berita});

  @override
  State<_BeritaCardItem> createState() => _BeritaCardItemState();
}

class _BeritaCardItemState extends State<_BeritaCardItem> {
  bool _isHovering = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isDarurat = widget.berita.isPeringatanDarurat;
    final bool hasImage = widget.berita.gambarUrl != null && widget.berita.gambarUrl!.isNotEmpty;
    final bool isActive = _isHovering || _isPressed;

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
          Navigator.push(context, MaterialPageRoute(builder: (context) => BeritaDetailScreen(berita: widget.berita)));
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutBack,
          transform: Matrix4.identity()..scale(isActive ? 1.02 : 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarurat 
                  ? [const Color(0xFFB71C1C).withOpacity(0.9), const Color(0xFFC62828).withOpacity(0.7)]
                  : (isActive 
                      ? [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.05)] 
                      : [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.02)]),
            ),
            border: Border.all(
              color: isDarurat 
                  ? Colors.redAccent 
                  : (isActive ? Colors.cyanAccent.withOpacity(0.5) : Colors.white.withOpacity(0.2)),
              width: isActive ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isDarurat 
                    ? Colors.red.withOpacity(0.5)
                    : (isActive ? Colors.cyan.withOpacity(0.2) : Colors.black.withOpacity(0.3)),
                blurRadius: isActive ? 25 : 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isDarurat)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD50000),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 1),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "PERINGATAN DARURAT", 
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.0)
                            ),
                          ],
                        ),
                      ),
                    if (hasImage)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        height: 180, width: double.infinity,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), image: DecorationImage(image: NetworkImage('${ApiService.publicBaseUrl}${widget.berita.gambarUrl!}'), fit: BoxFit.cover)),
                      ),
                    Text(widget.berita.judul, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white, height: 1.2)),
                    const SizedBox(height: 8),
                    Text(widget.berita.isi.length > 100 ? '${widget.berita.isi.substring(0, 100)}...' : widget.berita.isi, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14, height: 1.5)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(radius: 12, backgroundColor: Colors.white24, child: const Icon(Icons.person, size: 14, color: Colors.white)),
                        const SizedBox(width: 8),
                        Text(widget.berita.authorName, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                        const Spacer(),
                        Icon(Icons.access_time, size: 14, color: isDarurat ? Colors.white : Colors.cyanAccent),
                        const SizedBox(width: 4),
                        Text(DateFormat('dd MMM HH:mm').format(widget.berita.createdAt), style: TextStyle(fontSize: 12, color: isDarurat ? Colors.white : Colors.cyanAccent)),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}