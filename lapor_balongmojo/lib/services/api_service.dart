import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart'; // Untuk debugPrint
import 'package:http_parser/http_parser.dart';
import 'package:lapor_balongmojo/services/secure_storage_service.dart'; // Sesuai nama file Anda
import 'package:path/path.dart';

class ApiService {
  // IP Emulator: 10.0.2.2 | Device Fisik: Ganti dengan IP Laptop (misal 192.168.1.x)
  static const String _baseUrl = 'http://10.0.2.2:3000';
  static const String publicBaseUrl = _baseUrl;

  final SecureStorageService _storageService = SecureStorageService();

  // --- 1. LOGIN ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    final uri = Uri.parse('$_baseUrl/auth/login');
    
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data; 
      } else {
        throw Exception(data['message'] ?? 'Login gagal');
      }
    } catch (e) {
      debugPrint("Error Login: $e");
      rethrow;
    }
  }

  // --- 2. REGISTER (MASYARAKAT) ---
  Future<void> register(String nama, String email, String password, String nik, String phone) async {
    final uri = Uri.parse('$_baseUrl/auth/register');
    
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nama_lengkap': nama,
        'email': email,
        'password': password,
        'nik': nik,
        'no_telepon': phone,
        'role': 'masyarakat', 
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // --- 3. GET BERITA (Warga) ---
  Future<List<dynamic>> getBerita() async {
    final uri = Uri.parse('$_baseUrl/berita');
    final token = await _storageService.readToken();

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat berita');
    }
  }

  // --- 4. POST LAPORAN (Warga) ---
  Future<void> postLaporan(String judul, String deskripsi, File imageFile) async {
    final uri = Uri.parse('$_baseUrl/laporan');
    final token = await _storageService.readToken();

    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['judul'] = judul;
    request.fields['deskripsi'] = deskripsi;
    // request.fields['lokasi'] = lokasi; // Jika ada fitur lokasi

    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      filename: basename(imageFile.path),
      contentType: MediaType('image', 'jpeg'),
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201) {
      throw Exception('Gagal mengirim laporan: ${jsonDecode(response.body)['message']}');
    }
  }

  // --- 5. GET RIWAYAT LAPORAN (Warga) ---
  Future<List<dynamic>> getLaporan() async {
    // Endpoint bisa '/laporan' atau '/laporan/riwayat' tergantung backend user controller
    final uri = Uri.parse('$_baseUrl/laporan'); 
    final token = await _storageService.readToken();

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat riwayat laporan');
    }
  }

  // --- 6. GET SEMUA LAPORAN (Admin) ---
  Future<List<dynamic>> getAllLaporanAdmin() async {
    final uri = Uri.parse('$_baseUrl/laporan/admin/all');
    final token = await _storageService.readToken();

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat data admin');
    }
  }

  // --- 7. UPDATE STATUS LAPORAN (Admin) ---
  Future<void> updateStatusLaporan(int id, String status) async {
    final uri = Uri.parse('$_baseUrl/laporan/$id');
    final token = await _storageService.readToken();

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal update status');
    }
  }

  // --- 8. POST BERITA (Admin) ---
  Future<void> postBerita(String judul, String isi, File imageFile, bool isDarurat) async {
    final uri = Uri.parse('$_baseUrl/berita');
    final token = await _storageService.readToken();

    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['judul'] = judul;
    request.fields['isi'] = isi;
    request.fields['is_darurat'] = isDarurat.toString(); 

    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      filename: basename(imageFile.path),
      contentType: MediaType('image', 'jpeg'),
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    
    if (response.statusCode != 201) {
      throw Exception('Gagal upload berita: ${jsonDecode(response.body)['message']}');
    }
  }

  // --- 9. GET STATISTIK (Admin) ---
  Future<Map<String, dynamic>> getStatistik() async {
    // Sesuaikan endpoint backend Anda. 
    // Di backend Hari 19/27 endpointnya biasanya '/laporan/admin/statistik' atau '/laporan/stats'
    final uri = Uri.parse('$_baseUrl/laporan/stats'); // Mengikuti kode Anda sebelumnya
    final token = await _storageService.readToken();

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {'menunggu': 0, 'proses': 0, 'selesai': 0};
    }
  }

  // --- 10. GET USERS PENDING (Admin - Verifikasi) ---
  Future<List<dynamic>> getPendingUsers() async {
    // Endpoint backend biasanya '/auth/pending-users' atau '/users/pending'
    final uri = Uri.parse('$_baseUrl/users/pending'); // Mengikuti kode Anda sebelumnya
    final token = await _storageService.readToken();

    final response = await http.get(uri, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal ambil user pending');
    }
  }

  // --- 11. VERIFIKASI USER (Admin) ---
  Future<void> verifyUser(int userId, String action) async {
    // Endpoint backend
    final uri = Uri.parse('$_baseUrl/users/$userId/verify'); // Mengikuti kode Anda sebelumnya
    final token = await _storageService.readToken();

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({'action': action}), // 'approve' atau 'reject'
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal verifikasi user');
    }
  }
}