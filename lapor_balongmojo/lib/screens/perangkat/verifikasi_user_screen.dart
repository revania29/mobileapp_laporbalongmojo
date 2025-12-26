import 'package:flutter/material.dart';
import 'package:lapor_balongmojo/services/api_service.dart';
import 'package:lapor_balongmojo/widgets/glass_card.dart';

class VerifikasiUserScreen extends StatefulWidget {
  const VerifikasiUserScreen({super.key});

  @override
  State<VerifikasiUserScreen> createState() => _VerifikasiUserScreenState();
}

class _VerifikasiUserScreenState extends State<VerifikasiUserScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _pendingUsersFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _pendingUsersFuture = _apiService.getPendingUsers();
    });
  }

  Future<void> _verifikasiUser(int userId) async {
    try {
      await _apiService.verifikasiUser(userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User berhasil diverifikasi!'), backgroundColor: Colors.green),
      );
      _loadData(); // Refresh list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal verifikasi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _tolakUser(int userId) async {
    try {
      await _apiService.tolakUser(userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User berhasil ditolak!'), backgroundColor: Colors.orange),
      );
      _loadData(); // Refresh list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menolak: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _pendingUsersFuture,
      builder: (context, snapshot) {
        // 1. Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
        }
        
        // 2. Error
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)));
        }
        
        // 3. Kosong
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Tidak ada user yang perlu diverifikasi.',
              style: TextStyle(color: Colors.white, fontSize: 16), // ✅ Teks Putih
            ),
          );
        }

        // 4. Ada Data
        final users = snapshot.data!;
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: users.length,
          separatorBuilder: (ctx, index) => const SizedBox(height: 15),
          itemBuilder: (ctx, index) {
            final user = users[index];
            
            // ✅ Menggunakan GlassCard agar seragam dengan Dashboard
            return GlassCard(
              opacity: 0.15,
              color: Colors.black,
              borderColor: Colors.white.withOpacity(0.2),
              child: Row(
                children: [
                  // Icon User
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: Colors.blueAccent, size: 24),
                  ),
                  const SizedBox(width: 15),
                  
                  // Info User
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['nama_lengkap'] ?? 'Tanpa Nama',
                          style: const TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold, 
                            fontSize: 16
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user['email'] ?? '-',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        Text(
                          user['no_telepon'] ?? '-',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tombol Aksi
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.greenAccent),
                        tooltip: 'Verifikasi',
                        onPressed: () => _verifikasiUser(user['id']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.redAccent),
                        tooltip: 'Tolak',
                        onPressed: () => _tolakUser(user['id']),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}