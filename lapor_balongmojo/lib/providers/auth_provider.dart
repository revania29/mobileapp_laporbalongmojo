import 'package:flutter/material.dart';
import 'package:lapor_balongmojo/models/user_model.dart';
import 'package:lapor_balongmojo/services/api_service.dart';
import 'package:lapor_balongmojo/services/secure_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SecureStorageService _storageService = SecureStorageService();

  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _user;
  String? _token;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  bool get isLoggedIn => _status == AuthStatus.authenticated;

  bool get isAdmin => _user?.role == 'perangkat';

  Future<bool> tryAutoLogin() async {
    final token = await _storageService.readToken();
    if (token == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }

    _token = token;

    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('userRole') ?? 'masyarakat';
    final nama = prefs.getString('userName') ?? 'User';
    final id = prefs.getInt('userId') ?? 0;

    _user = UserModel(id: id, nama: nama, email: '', role: role);

    _status = AuthStatus.authenticated;
    notifyListeners();
    return true;
  }

  Future<void> login(String email, String password) async {
    try {
      final responseData = await _apiService.login(email, password);

      _token = responseData['token'];
      _user = UserModel.fromJson(responseData['user']);

      await _storageService.writeToken(_token!);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userRole', _user!.role); // Role disimpan disini
      await prefs.setString('userName', _user!.nama);
      await prefs.setInt('userId', _user!.id);

      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register(
    String nama,
    String email,
    String password,
    String nik,
    String phone,
  ) async {
    try {
      await _apiService.register(nama, email, password, nik, phone);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _status = AuthStatus.unauthenticated;

    await _storageService.deleteToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }
}
