import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:lapor_balongmojo/services/api_service.dart';
import 'package:lapor_balongmojo/services/secure_storage_service.dart';
import 'package:lapor_balongmojo/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lapor_balongmojo/services/fcm_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SecureStorageService _storageService = SecureStorageService();
  final FcmService _fcmService = FcmService();

  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _user;
  String? _token;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _status == AuthStatus.authenticated;
  String get userRole => _user?.role ?? 'masyarakat';

  AuthProvider() {
    tryAutoLogin();
  }

  Future<void> tryAutoLogin() async {
    final token = await _storageService.readToken();
    if (token == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _token = token;
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('userId')) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    // ✅ LOAD SEMUA DATA
    final id = prefs.getInt('userId') ?? 0;
    final nama = prefs.getString('userName') ?? 'User';
    final email = prefs.getString('userEmail') ?? '';
    final role = prefs.getString('userRole') ?? 'masyarakat';
    final noTelepon = prefs.getString('userPhone');
    final fotoProfil = prefs.getString('userPhoto');

    _user = UserModel(
      id: id,
      nama: nama,
      email: email,
      role: role,
      noTelepon: noTelepon,
      fotoProfil: fotoProfil,
    );

    _status = AuthStatus.authenticated;
    
    // Inisialisasi FCM ulang saat auto login
    await _fcmService.initialize();
    _handleFcmTopicSubscription(role);

    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      print(">>> [AUTH] Memulai Login...");
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      
      final responseData = await _apiService.login(email, password, fcmToken);
      print(">>> [AUTH] Login Sukses");

      _token = responseData['token'];
      UserModel tempUser = UserModel.fromJson(responseData['user']);

      // Cek hardcode admin (opsional sesuai kebutuhan Anda)
      if (email.toLowerCase().trim() == 'admin@gmail.com') {
        _user = tempUser.copyWith(role: 'perangkat', email: email);
      } else {
        _user = tempUser;
      }

      await _storageService.writeToken(_token!);

      // ✅ SIMPAN SEMUA DATA KE PREFS
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', _user!.id);
      await prefs.setString('userName', _user!.nama);
      await prefs.setString('userRole', _user!.role);
      await prefs.setString('userEmail', _user!.email);
      
      if (_user!.noTelepon != null) {
        await prefs.setString('userPhone', _user!.noTelepon!);
      }
      if (_user!.fotoProfil != null) {
        await prefs.setString('userPhoto', _user!.fotoProfil!);
      }

      _status = AuthStatus.authenticated;
      
      await _fcmService.initialize();
      _handleFcmTopicSubscription(_user!.role);

      notifyListeners();
    } catch (e) {
      print(">>> [AUTH] ERROR: $e");
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      rethrow;
    }
  }

  // ✅ METHOD UPDATE YANG DIPERBAIKI (Named Parameters)
  Future<void> updateUserProfile({
    required String newName,
    required String newPhone,
    String? fotoProfil, // Optional path foto
  }) async {
    try {
      // Panggil API (pastikan API service Anda mendukung update ini)
      await _apiService.updateProfile(newName, newPhone);

      if (_user != null) {
        // Update model di memory
        _user = _user!.copyWith(
          nama: newName,
          noTelepon: newPhone,
          fotoProfil: fotoProfil ?? _user!.fotoProfil,
        );

        // Update persistence agar sinkron
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', newName);
        await prefs.setString('userPhone', newPhone);
        
        if (fotoProfil != null) {
          await prefs.setString('userPhoto', fotoProfil);
        }

        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  void _handleFcmTopicSubscription(String role) async {
    try {
      if (role == 'perangkat') {
        await FirebaseMessaging.instance.subscribeToTopic('laporan_perangkat');
        await FirebaseMessaging.instance.unsubscribeFromTopic('emergency_alerts');
      } else {
        await FirebaseMessaging.instance.unsubscribeFromTopic('laporan_perangkat');
        await FirebaseMessaging.instance.subscribeToTopic('emergency_alerts');
      }
    } catch (e) {
      print(">>> [FCM] Topic Error: $e");
    }
  }

  Future<void> registerMasyarakat(
      String nama, String email, String noTelp, String password) async {
    await _apiService.registerMasyarakat(nama, email, noTelp, password);
  }

  Future<void> logout() async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic('laporan_perangkat');
      await FirebaseMessaging.instance.unsubscribeFromTopic('emergency_alerts');
    } catch (e) {
      print(">>> [FCM] Unsub Error: $e");
    }

    _token = null;
    _user = null;
    _status = AuthStatus.unauthenticated;

    await _storageService.deleteToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }
}