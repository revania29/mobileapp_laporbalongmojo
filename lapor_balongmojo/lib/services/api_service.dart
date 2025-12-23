import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart'; 
import 'package:http_parser/http_parser.dart';
import 'package:lapor_balongmojo/services/secure_storage_service.dart'; 
import 'package:path/path.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:3000';
  static const String publicBaseUrl = _baseUrl;

  final SecureStorageService _storageService = SecureStorageService();

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

  Future<void> postLaporan(String judul, String deskripsi, File imageFile) async {
    final uri = Uri.parse('$_baseUrl/laporan');
    final token = await _storageService.readToken();

    var request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['judul'] = judul;
    request.fields['deskripsi'] = deskripsi;

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

  Future<List<dynamic>> getLaporan() async {
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

  Future<Map<String, dynamic>> getStatistik() async {
    final uri = Uri.parse('$_baseUrl/laporan/stats');
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

  Future<List<dynamic>> getPendingUsers() async {
    final uri = Uri.parse('$_baseUrl/users/pending'); 
    final token = await _storageService.readToken();

    final response = await http.get(uri, headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal ambil user pending');
    }
  }

  Future<void> verifyUser(int userId, String action) async {
    // Endpoint backend
    final uri = Uri.parse('$_baseUrl/users/$userId/verify'); 
    final token = await _storageService.readToken();

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({'action': action}), 
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal verifikasi user');
    }
  }
}