import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:lapor_balongmojo/providers/laporan_provider.dart';
import 'dart:ui'; 

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      children: [
        // Header Statistik
        const Text(
          "Statistik Desa",
          style: TextStyle(
            fontSize: 22, 
            fontWeight: FontWeight.w900, 
            color: Colors.white, 
            letterSpacing: 1.2,
            shadows: [Shadow(color: Colors.black45, offset: Offset(2, 2), blurRadius: 4)]
          ),
        ),
        
        const SizedBox(height: 12),
        
        // GRID STATISTIK
        const InfoDesaGrid(), 
        
        // Header Peta
        Padding(
          padding: const EdgeInsets.only(top: 8.0), 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Peta Wilayah",
                style: TextStyle(
                  fontSize: 22, 
                  fontWeight: FontWeight.w900, 
                  color: Colors.white, 
                  letterSpacing: 1.2,
                  shadows: [Shadow(color: Colors.black45, offset: Offset(2, 2), blurRadius: 4)]
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
                // ✅ ICON PETA JADI MERAH (Sesuai Permintaan)
                child: const Icon(Icons.map_rounded, color: Colors.redAccent, size: 20),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 10),
        
        // PETA
        const PetaBalongmojoCard(),
      ],
    );
  }
}

class InfoDesaGrid extends StatelessWidget {
  const InfoDesaGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LaporanProvider>(
      builder: (context, laporanProvider, child) {
        String jumlahLaporanUser = laporanProvider.laporanList.length.toString();

        final List<Map<String, dynamic>> infoItems = [
          {'title': 'Dusun', 'value': '6', 'icon': Icons.holiday_village_rounded, 'color': Colors.cyanAccent},
          {'title': 'Penduduk', 'value': '4.337', 'icon': Icons.groups_rounded, 'color': Colors.greenAccent}, 
          {'title': 'Laki-laki', 'value': '2.195', 'icon': Icons.male_rounded, 'color': Colors.blueAccent},   
          {'title': 'Perempuan', 'value': '2.142', 'icon': Icons.female_rounded, 'color': Colors.pinkAccent}, 
          {'title': 'Laporan Saya', 'value': jumlahLaporanUser, 'icon': Icons.assignment_turned_in_rounded, 'color': Colors.orangeAccent},
          {'title': 'Instansi', 'value': '5', 'icon': Icons.location_city_rounded, 'color': Colors.purpleAccent},
        ];

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero, 
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12, 
            mainAxisSpacing: 12,  
            childAspectRatio: 1.45, 
          ),
          itemCount: infoItems.length,
          itemBuilder: (context, index) {
            return _StatCard(item: infoItems[index]);
          },
        );
      },
    );
  }
}

// --- WIDGET KARTU STATISTIK ---
class _StatCard extends StatefulWidget {
  final Map<String, dynamic> item;
  const _StatCard({required this.item});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isHovering = false;
  bool _isPressed = false;  

  void _showDetailModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, 
      barrierColor: Colors.black.withOpacity(0.5),
      isScrollControlled: true, 
      isDismissible: true,
      enableDrag: true,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65, 
          decoration: BoxDecoration(
            color: const Color(0xFF2E004F).withOpacity(0.95), 
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.3), width: 1.5)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 30, spreadRadius: 5)],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Column(
                children: [
                  Center(child: Container(width: 50, height: 5, margin: const EdgeInsets.symmetric(vertical: 15), decoration: BoxDecoration(color: Colors.white38, borderRadius: BorderRadius.circular(10)))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    child: Row(
                      children: [
                        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: widget.item['color'].withOpacity(0.2), shape: BoxShape.circle), child: Icon(Icons.info_outline, color: widget.item['color'], size: 24)),
                        const SizedBox(width: 15),
                        Expanded(child: Text("Detail ${widget.item['title']}", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
                        IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white54), onPressed: () => Navigator.pop(ctx))
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white12, thickness: 1),
                  Expanded(child: ListView(padding: const EdgeInsets.all(20), children: _buildDetailContent())),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildDetailContent() {
    String type = widget.item['title'];
    Color color = widget.item['color'];
    
    List<Map<String, String>> data = [];
    if (type == 'Dusun') {
       data = [{'label': 'Setoyo', 'sub': 'Ka. Dusun: Bpk. Sadi'}, {'label': 'Delik', 'sub': 'Ka. Dusun: Bpk. Hartono'}, {'label': 'Karangnongko', 'sub': 'Ka. Dusun: Bpk. Slamet'}, {'label': 'Soogo', 'sub': 'Ka. Dusun: Bpk. Wibowo'}, {'label': 'Balongwaru', 'sub': 'Ka. Dusun: Bpk. Sutrisno'}, {'label': 'Jetak', 'sub': 'Ka. Dusun: Bpk. Mulyadi'}];
    } else if (type == 'Penduduk') {
       data = [{'label': 'Dsn. Setoyo', 'sub': '950 Jiwa'}, {'label': 'Dsn. Balongwaru', 'sub': '850 Jiwa'}, {'label': 'Dsn. Delik', 'sub': '800 Jiwa'}, {'label': 'Dsn. Karangnongko', 'sub': '750 Jiwa'}, {'label': 'Dsn. Soogo', 'sub': '600 Jiwa'}, {'label': 'Dsn. Jetak', 'sub': '387 Jiwa'}];
    } else if (type == 'Laki-laki') {
       data = [{'label': 'Anak-anak', 'sub': '500 Jiwa (0-12 Thn)'}, {'label': 'Remaja', 'sub': '450 Jiwa (13-18 Thn)'}, {'label': 'Dewasa', 'sub': '800 Jiwa (19-59 Thn)'}, {'label': 'Lansia', 'sub': '445 Jiwa (>60 Thn)'}];
    } else if (type == 'Perempuan') {
       data = [{'label': 'Anak-anak', 'sub': '480 Jiwa (0-12 Thn)'}, {'label': 'Remaja', 'sub': '420 Jiwa (13-18 Thn)'}, {'label': 'Dewasa', 'sub': '790 Jiwa (19-59 Thn)'}, {'label': 'Lansia', 'sub': '452 Jiwa (>60 Thn)'}];
    } else if (type == 'Instansi') {
       data = [{'label': 'Kantor Desa', 'sub': 'Pusat Pelayanan'}, {'label': 'SDN Balongmojo', 'sub': 'Pendidikan Dasar'}, {'label': 'MI Nurul Huda', 'sub': 'Pendidikan Islam'}, {'label': 'Polindes', 'sub': 'Kesehatan Desa'}, {'label': 'TK Dharma Wanita', 'sub': 'Pendidikan Usia Dini'}];
    } else if (type == 'Laporan Saya') {
      return [const Center(child: Text("Lihat detail di menu Riwayat.", style: TextStyle(color: Colors.white70)))];
    }

    return data.map((d) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: ListTile(leading: Icon(Icons.circle, color: color, size: 10), title: Text(d['label']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), subtitle: Text(d['sub']!, style: TextStyle(color: Colors.white.withOpacity(0.6))))
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    Color itemColor = widget.item['color'];
    bool isActive = _isHovering || _isPressed; 

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click, 
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: () {
           setState(() => _isPressed = true);
           Future.delayed(const Duration(milliseconds: 100), () {
             if (mounted) setState(() => _isPressed = false);
             _showDetailModal(context);
           });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutBack,
          transform: Matrix4.identity()..scale(isActive ? 1.05 : 1.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isActive
                  ? [itemColor.withOpacity(0.5), itemColor.withOpacity(0.2)] 
                  : [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.02)],
            ),
            border: Border.all(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
              width: isActive ? 1.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isActive ? itemColor.withOpacity(0.5) : Colors.black.withOpacity(0.3),
                blurRadius: isActive ? 20 : 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start, 
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isActive ? Colors.white.withOpacity(0.3) : itemColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: itemColor.withOpacity(0.4), blurRadius: 8, spreadRadius: -2)
                            ],
                            border: Border.all(color: itemColor.withOpacity(0.3), width: 1)
                          ),
                          child: Icon(widget.item['icon'], color: isActive ? Colors.white : itemColor, size: 18),
                        ),
                        const SizedBox(width: 10), 
                        Expanded(
                          child: Text(
                            widget.item['value'], 
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white, letterSpacing: 0.5),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: isActive ? 40 : 20, 
                              height: 3, 
                              color: itemColor.withOpacity(0.5), 
                              margin: const EdgeInsets.only(bottom: 4)
                            ),
                            Text(
                              widget.item['title'].toUpperCase(), 
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)
                            ),
                          ],
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, color: isActive ? Colors.white : Colors.white.withOpacity(0.2), size: 10),
                      ],
                    ),
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

// --- WIDGET PETA (MERAH SEMUA) ---
class PetaBalongmojoCard extends StatefulWidget {
  const PetaBalongmojoCard({super.key});

  @override
  State<PetaBalongmojoCard> createState() => _PetaBalongmojoCardState();
}

class _PetaBalongmojoCardState extends State<PetaBalongmojoCard> {
  bool _isInteractive = false; 
  bool _isHovering = false;
  bool _isPressed = false; 

  @override
  Widget build(BuildContext context) {
    bool isActive = _isHovering || _isPressed;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutBack,
          transform: Matrix4.identity()..scale(isActive ? 1.02 : 1.0),
          
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isActive
                  ? [Colors.purpleAccent.withOpacity(0.15), Colors.deepPurpleAccent.withOpacity(0.05)]
                  : [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.02)],
            ),
            border: Border.all(
              color: isActive ? Colors.purpleAccent : Colors.white.withOpacity(0.2), 
              width: isActive ? 2.0 : 1.2
            ),
            boxShadow: [
              BoxShadow(
                color: isActive ? Colors.purpleAccent.withOpacity(0.3) : Colors.black.withOpacity(0.4),
                blurRadius: isActive ? 30 : 20,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Stack(
                children: [
                  IgnorePointer(
                    ignoring: !_isInteractive, 
                    child: SizedBox(
                      height: 380, 
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: const LatLng(-7.51272, 112.44911),
                          initialZoom: 15.0,
                          interactionOptions: InteractionOptions(
                            flags: _isInteractive ? InteractiveFlag.all : InteractiveFlag.none,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.lapor_balongmojo',
                          ),
                          const MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(-7.51272, 112.44911),
                                width: 100, height: 100,
                                // ✅ PIN PETA MERAH
                                child: Icon(Icons.location_on, color: Colors.redAccent, size: 50),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  Positioned(
                    top: 15, left: 15,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6), 
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              // ✅ LEGEND MERAH
                              Icon(Icons.location_city_rounded, color: Colors.redAccent, size: 16),
                              SizedBox(width: 8),
                              Text("Lokasi Balai Desa", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 15, right: 15,
                    child: InkWell(
                      onTap: () => setState(() => _isInteractive = !_isInteractive),
                      borderRadius: BorderRadius.circular(30),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: _isInteractive ? Colors.green.withOpacity(0.9) : Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: _isInteractive ? Colors.white : Colors.white.withOpacity(0.2)),
                              boxShadow: _isInteractive 
                                ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.4), blurRadius: 10, spreadRadius: 1)] 
                                : [],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_isInteractive ? Icons.touch_app_rounded : Icons.lock_rounded, color: Colors.white, size: 16),
                                const SizedBox(width: 8),
                                Text(_isInteractive ? "Aktif" : "Terkunci", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}