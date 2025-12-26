import 'package:flutter/material.dart';
import 'package:lapor_balongmojo/models/laporan_model.dart';
import 'package:lapor_balongmojo/services/api_service.dart';

enum LaporanStatus { initial, loading, loaded, error }

class LaporanProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<LaporanModel> _laporanList = [];
  int _totalLaporan = 0;
  LaporanStatus _status = LaporanStatus.initial;
  String _errorMessage = '';

  List<LaporanModel> get laporanList => _laporanList;
  int get totalLaporan => _totalLaporan;
  LaporanStatus get status => _status;
  bool get isLoading => _status == LaporanStatus.loading;

  // Fungsi Utama: Ambil Data dari API
  Future<void> fetchLaporan() async {
    _status = LaporanStatus.loading;
    notifyListeners(); // Beritahu UI untuk muter loading

    try {
      // Ambil List Laporan
      final data = await _apiService.getLaporan();
      
      // (Opsional) Jika backend support pagination/total count terpisah:
      // final total = await _apiService.getTotalLaporan(); 

      _laporanList = data;
      _totalLaporan = data.length; 
      _status = LaporanStatus.loaded;
    } catch (e) {
      _status = LaporanStatus.error;
      _errorMessage = e.toString();
      _laporanList = [];
    }
    
    notifyListeners(); // Beritahu UI data sudah siap
  }

  // Fungsi Tambah Laporan (Opsional jika perangkat bisa nambah)
  Future<void> addLaporan(String judul, String deskripsi, String? fotoUrl) async {
    try {
      await _apiService.postLaporan(judul, deskripsi, fotoUrl);
      await fetchLaporan(); // Refresh otomatis setelah posting
    } catch (e) {
      rethrow;
    }
  }
}