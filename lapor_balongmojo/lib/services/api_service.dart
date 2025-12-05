import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:lapor_balongmojo/models/laporan_model.dart';
import 'package:lapor_balongmojo/services/secure_storage_service.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:3000';
  
  static const String publicBaseUrl = _baseUrl; 
  
  final SecureStorageService _storageService = SecureStorageService();

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _storageService.readToken();
    return {
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<void> registerMasyarakat(
      String nama, String email, String noTelp, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register/masyarakat'),
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

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201) {
      throw Exception(jsonDecode(response.body)['message']);
    }
  }

  Future<List<LaporanModel>> getLaporan() async {
    final uri = Uri.parse('$_baseUrl/laporan');
    final headers = await _getAuthHeaders(); 

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<LaporanModel> laporanList = body
          .map((dynamic item) => LaporanModel.fromJson(item))
          .toList();
      return laporanList;
    } else {
      throw Exception('Gagal mengambil data laporan');
    }
  }

  Future<List<LaporanModel>> getAllLaporanAdmin() async {
    final uri = Uri.parse('$_baseUrl/laporan/admin/all');
    final headers = await _getAuthHeaders();

    final response = await http.get(uri, headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<LaporanModel> laporanList = body
          .map((dynamic item) => LaporanModel.fromJson(item))
          .toList();
      return laporanList;
    } else {
      throw Exception('Gagal mengambil data laporan admin');
    }
  }
}