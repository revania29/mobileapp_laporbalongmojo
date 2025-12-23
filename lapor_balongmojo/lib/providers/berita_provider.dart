import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lapor_balongmojo/models/berita_model.dart';
import 'package:lapor_balongmojo/services/api_service.dart';

class BeritaProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<BeritaModel> _listBerita = [];
  bool _isLoading = false;

  List<BeritaModel> get listBerita => _listBerita;
  bool get isLoading => _isLoading;

  Future<void> fetchBerita() async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<dynamic> rawData = await _apiService.getBerita();
      _listBerita = rawData.map((item) => BeritaModel.fromJson(item)).toList();
    
    } catch (e) {
      debugPrint("Error fetch berita: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> postBerita(String judul, String isi, File image, bool isDarurat) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _apiService.postBerita(judul, isi, image, isDarurat);
      await fetchBerita(); 
    } catch (e) {
      debugPrint("Error post berita: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}