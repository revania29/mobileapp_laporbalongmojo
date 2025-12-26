import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lapor_balongmojo/models/berita_model.dart';
import 'package:lapor_balongmojo/services/api_service.dart';
import 'package:lapor_balongmojo/widgets/glass_card.dart';
import 'dart:ui';

class DetailBeritaScreen extends StatefulWidget {
  final BeritaModel berita;
  const DetailBeritaScreen({super.key, required this.berita});

  @override
  State<DetailBeritaScreen> createState() => _DetailBeritaScreenState();
}

class _DetailBeritaScreenState extends State<DetailBeritaScreen> {
  late bool _isDarurat;
  final ApiService _apiService = ApiService();
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _isDarurat = widget.berita.isPeringatanDarurat;
  }

  Future<void> _updateStatusBerita(bool isDarurat) async {
    setState(() => _isUpdating = true);
    try {
      await _apiService.updateBerita(widget.berita.id, widget.berita.judul, widget.berita.isi, widget.berita.gambarUrl, isDarurat);
      setState(() => _isDarurat = isDarurat);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isDarurat ? "Mode DARURAT" : "Mode AMAN"), backgroundColor: isDarurat ? Colors.red : Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF2E004F), Color(0xFF6A0059)])),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text("DETAIL BERITA", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)), centerTitle: true, backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), onPressed: () => Navigator.pop(context))),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (_isDarurat)
                Container(width: double.infinity, margin: const EdgeInsets.only(bottom: 20), padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 15)]), child: const Center(child: Text("⚠️ PERINGATAN DARURAT ⚠️", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))),

              GlassCard(
                opacity: 0.15, color: Colors.black,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.berita.gambarUrl != null) ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network('${ApiService.publicBaseUrl}${widget.berita.gambarUrl!}', width: double.infinity, fit: BoxFit.cover)),
                    const SizedBox(height: 20),
                    Text(widget.berita.judul, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 10),
                    Text(DateFormat('EEEE, dd MMM yyyy').format(widget.berita.createdAt), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                    const Divider(color: Colors.white24, height: 30),
                    Text(widget.berita.isi, style: const TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.justify),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              
              const Align(alignment: Alignment.centerLeft, child: Text("Status Berita:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(color: const Color(0xFF4A148C), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white30)),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _isDarurat ? 'DARURAT' : 'AMAN',
                    dropdownColor: const Color(0xFF4A148C),
                    icon: _isUpdating ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    isExpanded: true,
                    items: ['AMAN', 'DARURAT'].map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: TextStyle(color: value == 'DARURAT' ? Colors.redAccent : Colors.white)))).toList(),
                    onChanged: (newValue) { if (newValue != null) { bool newStatus = (newValue == 'DARURAT'); if (newStatus != _isDarurat) _updateStatusBerita(newStatus); }},
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}