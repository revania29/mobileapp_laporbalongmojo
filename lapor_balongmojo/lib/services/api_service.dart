import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:lapor_balongmojo/services/secure_storage_service.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

class ApiService {
  // 10.0.2.2 localhost untuk Android Emulator
  static const String _baseUrl = 'http://10.0.2.2:3000'; 
  
  final SecureStorageService _storageService = SecureStorageService();

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storageService.readToken();
    return {
      'Authorization': 'Bearer $token',
    };
  }

  // --- 1. LOGIN ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // --- 2. REGISTER ---
  Future<void> registerMasyarakat(
      String nama, String email, String noTelp, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nama_lengkap': nama,
        'email': email,
        'no_telepon': noTelp,
        'password': password,
        'role': 'masyarakat',
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  // --- 3. POST LAPORAN ---
  Future<void> postLaporan(String judul, String deskripsi, File imageFile) async {
    final uri = Uri.parse('$_baseUrl/laporan');
    final token = await _storageService.readToken();

    var request = http.MultipartRequest('POST', uri);
    
    request.headers['Authorization'] = 'Bearer $token';

    // Field Teks
    request.fields['judul'] = judul;
    request.fields['deskripsi'] = deskripsi;

    // Field File Gambar
    request.files.add(await http.MultipartFile.fromPath(
      'image',
      imageFile.path,
      filename: basename(imageFile.path),
      contentType: MediaType('image', 'jpeg'),
    ));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201) {
      try {
        throw Exception(jsonDecode(response.body)['message']);
      } catch (e) {
        throw Exception('Gagal mengirim laporan. Status: ${response.statusCode}');
      }
    }
  }
}