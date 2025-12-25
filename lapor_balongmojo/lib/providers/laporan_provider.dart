import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lapor_balongmojo/models/laporan_model.dart';
import 'package:lapor_balongmojo/services/api_service.dart';

class LaporanProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<LaporanModel> _riwayatLaporan = [];
  List<LaporanModel> _allLaporanAdmin = [];
  bool _isLoading = false;

  List<LaporanModel> get riwayatLaporan => _riwayatLaporan;
  List<LaporanModel> get allLaporanAdmin => _allLaporanAdmin;
  bool get isLoading => _isLoading;

  int get countMenunggu => _allLaporanAdmin.where((l) => l.status == 'menunggu').length;
  int get countProses => _allLaporanAdmin.where((l) => l.status == 'proses').length;
  int get countSelesai => _allLaporanAdmin.where((l) => l.status == 'selesai').length;

  Future<void> tambahLaporan(String judul, String deskripsi, File image) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.postLaporan(judul, deskripsi, image);
      await fetchRiwayatLaporan(); 
    } catch (e) {
      debugPrint("Error tambah laporan: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRiwayatLaporan() async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<dynamic> rawData = await _apiService.getLaporan();
      _riwayatLaporan = rawData.map((item) => LaporanModel.fromJson(item)).toList();
      
    } catch (e) {
      debugPrint("Error fetch laporan warga: $e");
      _riwayatLaporan = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllLaporanAdmin() async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<dynamic> rawData = await _apiService.getAllLaporanAdmin();
      _allLaporanAdmin = rawData.map((item) => LaporanModel.fromJson(item)).toList();
      
    } catch (e) {
      debugPrint("Error fetch laporan admin: $e");
      _allLaporanAdmin = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateStatus(int id, String newStatus) async {
    try {
      await _apiService.updateStatusLaporan(id, newStatus);
      await fetchAllLaporanAdmin(); 
    } catch (e) {
      rethrow;
    }
  }
}