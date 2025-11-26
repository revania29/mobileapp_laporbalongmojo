import 'package:flutter/material.dart';
import 'package:lapor_balongmojo/models/laporan_model.dart';
import 'package:lapor_balongmojo/services/api_service.dart';

class LaporanProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<LaporanModel> _riwayatLaporan = [];
  bool _isLoading = false;

  List<LaporanModel> get riwayatLaporan => _riwayatLaporan;
  bool get isLoading => _isLoading;

  Future<void> fetchRiwayatLaporan() async {
    _isLoading = true;
    notifyListeners();

    try {
      _riwayatLaporan = await _apiService.getLaporan();
    } catch (e) {
      print("Error fetch laporan: $e");
      _riwayatLaporan = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}