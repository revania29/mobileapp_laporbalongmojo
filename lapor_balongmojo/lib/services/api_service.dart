import 'dart:convert';

import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:lapor_balongmojo/models/laporan_model.dart';

import 'package:lapor_balongmojo/models/berita_model.dart';

import 'package:lapor_balongmojo/services/secure_storage_service.dart';

import 'package:http_parser/http_parser.dart';

import 'package:path/path.dart';



class ApiService {

// GANTI IP SESUAI CONFIG ANDA

static const String _baseUrl = 'http://10.0.2.2:3000';

static const String publicBaseUrl = _baseUrl;


final SecureStorageService _storageService = SecureStorageService();



Future<Map<String, String>> _getAuthHeaders() async {

final token = await _storageService.readToken();

return {

'Content-Type': 'application/json; charset=UTF-8',

'Authorization': 'Bearer $token',

};

}



// --- AUTH ---

Future<Map<String, dynamic>> login(String email, String password, String? fcmToken) async {

final response = await http.post(

Uri.parse('$_baseUrl/auth/login'),

headers: {'Content-Type': 'application/json; charset=UTF-8'},

body: jsonEncode({'email': email, 'password': password, 'fcm_token': fcmToken}),

);

if (response.statusCode == 200) return jsonDecode(response.body);

else throw Exception(jsonDecode(response.body)['message']);

}



Future<void> registerMasyarakat(String nama, String email, String noTelp, String password) async {

final response = await http.post(

Uri.parse('$_baseUrl/auth/register/masyarakat'),

headers: {'Content-Type': 'application/json; charset=UTF-8'},

body: jsonEncode({'nama_lengkap': nama, 'email': email, 'no_telepon': noTelp, 'password': password}),

);

if (response.statusCode != 201) throw Exception(jsonDecode(response.body)['message']);

}



// --- BERITA ---

Future<List<BeritaModel>> getBerita() async {

final response = await http.get(Uri.parse('$_baseUrl/berita'));

if (response.statusCode == 200) {

List<dynamic> jsonList = jsonDecode(response.body);

return jsonList.map((json) => BeritaModel.fromJson(json)).toList();

} else throw Exception('Gagal memuat berita');

}



Future<void> createBerita(String judul, String isi, String? gambarUrl, bool isPeringatanDarurat) async {

final headers = await _getAuthHeaders();

final body = jsonEncode({'judul': judul, 'isi': isi, 'gambar_url': gambarUrl, 'is_peringatan_darurat': isPeringatanDarurat});

final response = await http.post(Uri.parse('$_baseUrl/berita'), headers: headers, body: body);

if (response.statusCode != 201) throw Exception(jsonDecode(response.body)['message']);

}



Future<void> updateBerita(int id, String judul, String isi, String? gambarUrl, bool isPeringatanDarurat) async {

final headers = await _getAuthHeaders();

final body = jsonEncode({'judul': judul, 'isi': isi, 'gambar_url': gambarUrl, 'is_peringatan_darurat': isPeringatanDarurat});

final response = await http.put(Uri.parse('$_baseUrl/berita/$id'), headers: headers, body: body);

if (response.statusCode != 200) throw Exception('Gagal update berita');

}



Future<void> deleteBerita(int id) async {

final headers = await _getAuthHeaders();

final response = await http.delete(Uri.parse('$_baseUrl/berita/$id'), headers: headers);

if (response.statusCode != 200) throw Exception('Gagal hapus berita');

}



// --- LAPORAN ---

Future<List<LaporanModel>> getLaporan() async {

final headers = await _getAuthHeaders();

final response = await http.get(Uri.parse('$_baseUrl/laporan'), headers: headers);

if (response.statusCode == 200) {

List<dynamic> jsonList = jsonDecode(response.body);

return jsonList.map((json) => LaporanModel.fromJson(json)).toList();

} else throw Exception('Gagal memuat laporan');

}



Future<void> postLaporan(String judul, String deskripsi, String? fotoUrl) async {

final headers = await _getAuthHeaders();

final response = await http.post(

Uri.parse('$_baseUrl/laporan'),

headers: headers,

body: jsonEncode({'judul': judul, 'deskripsi': deskripsi, 'foto_url': fotoUrl}),

);

if (response.statusCode != 201) throw Exception(jsonDecode(response.body)['message']);

}



Future<void> updateStatusLaporan(int id, String status) async {

final headers = await _getAuthHeaders();

final response = await http.put(

Uri.parse('$_baseUrl/laporan/$id'),

headers: headers,

body: jsonEncode({'status': status}),

);

if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message']);

}



// ✅ FUNGSI DELETE LAPORAN (WAJIB ADA)

Future<void> deleteLaporan(int id) async {

final headers = await _getAuthHeaders();

final response = await http.delete(Uri.parse('$_baseUrl/laporan/$id'), headers: headers);

if (response.statusCode != 200) {

try {

throw Exception(jsonDecode(response.body)['message']);

} catch (_) {

throw Exception('Gagal menghapus laporan');

}

}

}



// --- ADMIN & OTHERS ---

Future<List<dynamic>> getPendingUsers() async {

final headers = await _getAuthHeaders();

final response = await http.get(Uri.parse('$_baseUrl/admin/users-pending'), headers: headers);

if (response.statusCode == 200) return jsonDecode(response.body);

else throw Exception('Gagal memuat user pending');

}



Future<void> verifikasiUser(int userId) async {

final headers = await _getAuthHeaders();

final response = await http.put(Uri.parse('$_baseUrl/admin/verifikasi/$userId'), headers: headers);

if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message']);

}



Future<void> tolakUser(int userId) async {

final headers = await _getAuthHeaders();

final response = await http.delete(Uri.parse('$_baseUrl/admin/tolak/$userId'), headers: headers);

if (response.statusCode != 200) throw Exception(jsonDecode(response.body)['message']);

}



Future<int> getTotalLaporan() async {

try {

final response = await http.get(Uri.parse('$_baseUrl/stats/laporan-total'));

if (response.statusCode == 200) {

final data = jsonDecode(response.body);

return data['total_laporan'] as int;

} else return 0;

} catch (e) { return 0; }

}



Future<String> uploadImage(File imageFile) async {

final token = await _storageService.readToken();

var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload'));

request.headers['Authorization'] = 'Bearer $token';

request.files.add(await http.MultipartFile.fromPath('image', imageFile.path, filename: basename(imageFile.path), contentType: MediaType('image', 'jpeg')));


var streamedResponse = await request.send();

var response = await http.Response.fromStream(streamedResponse);

if (response.statusCode == 200 || response.statusCode == 201) {

return jsonDecode(response.body)['url'] ?? jsonDecode(response.body)['imageUrl'];

} else throw Exception('Gagal upload gambar');

}



Future<void> updateProfile(String nama, String? noTelepon) async {

final headers = await _getAuthHeaders();

await http.put(Uri.parse('$_baseUrl/profile'), headers: headers, body: jsonEncode({'nama_lengkap': nama, 'no_telepon': noTelepon}));

}

}

