import 'package:flutter/material.dart';
import 'package:lapor_balongmojo/models/user_model.dart';
import 'package:lapor_balongmojo/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _user;
  String? _token;

  AuthStatus get status => _status;
  UserModel? get user => _user;

  Future<void> login(String email, String password) async {
    try {
      final responseData = await _apiService.login(email, password);
      
      _token = responseData['token'];
      _user = UserModel.fromJson(responseData['user']);
      
      await _storage.write(key: 'jwt_token', value: _token);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userRole', _user!.role);
      await prefs.setString('userName', _user!.nama);

      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow; 
    }
  }

  Future<void> register(String nama, String email, String noTelp, String password) async {
    await _apiService.registerMasyarakat(nama, email, noTelp, password);
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _status = AuthStatus.unauthenticated;
    
    await _storage.delete(key: 'jwt_token');
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    notifyListeners();
  }
}