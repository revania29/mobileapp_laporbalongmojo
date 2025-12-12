import 'package:flutter/material.dart';
import 'package:lapor_balongmojo/services/api_service.dart';

class VerifikasiWargaScreen extends StatefulWidget {
  static const routeName = '/verifikasi-warga';
  const VerifikasiWargaScreen({super.key});

  @override
  State<VerifikasiWargaScreen> createState() => _VerifikasiWargaScreenState();
}

class _VerifikasiWargaScreenState extends State<VerifikasiWargaScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _pendingUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _apiService.getPendingUsers();
      setState(() => _pendingUsers = data);
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verify(int id, String nama, bool isAccept) async {
    final action = isAccept ? 'verified' : 'rejected';
    try {
      await _apiService.verifyUser(id, action);
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$nama berhasil di-${isAccept ? 'terima' : 'tolak'}")));
      _fetchData(); // Refresh list
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi Warga Baru'), backgroundColor: Colors.teal),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _pendingUsers.isEmpty
          ? const Center(child: Text("Tidak ada pendaftaran baru."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingUsers.length,
              itemBuilder: (ctx, i) {
                final user = _pendingUsers[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.person_outline, color: Colors.white)),
                    title: Text(user['nama_lengkap'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${user['email']}\n${user['no_telepon']}"),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () => _verify(user['id'], user['nama_lengkap'], true),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => _verify(user['id'], user['nama_lengkap'], false),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}