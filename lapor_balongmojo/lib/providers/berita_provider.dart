import 'package:flutter/material.dart';
import 'dart:io';
import 'package:lapor_balongmojo/services/api_service.dart';

class BeritaProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<void> postBerita(String judul, String isi, File image) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.postBerita(judul, isi, image);
    } catch (e) {
      debugPrint("Error post berita: $e"); 
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}