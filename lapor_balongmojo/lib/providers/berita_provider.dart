import 'package:flutter/material.dart';
import 'dart:io';
import 'package:lapor_balongmojo/services/api_service.dart';
import 'package:lapor_balongmojo/models/berita_model.dart'; 

class BeritaProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  List<BeritaModel> _listBerita = []; 

  bool get isLoading => _isLoading;
  List<BeritaModel> get listBerita => _listBerita;

  Future<void> postBerita(String judul, String isi, File image) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.postBerita(judul, isi, image);
      await fetchBerita(); 
    } catch (e) {
      debugPrint("Error post berita: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBerita() async {
    _isLoading = true;
    notifyListeners();
    try {
      _listBerita = await _apiService.getBerita();
    } catch (e) {
      debugPrint("Error fetch berita: $e");
      _listBerita = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}