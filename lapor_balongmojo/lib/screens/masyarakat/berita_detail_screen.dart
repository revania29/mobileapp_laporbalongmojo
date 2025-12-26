import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lapor_balongmojo/models/berita_model.dart';
import 'package:lapor_balongmojo/services/api_service.dart';
import 'package:lapor_balongmojo/widgets/glass_card.dart';

class BeritaDetailScreen extends StatelessWidget {
  final BeritaModel berita;

  const BeritaDetailScreen({super.key, required this.berita});

  @override
  Widget build(BuildContext context) {
    final bool isDarurat = berita.isPeringatanDarurat;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarurat
              ? [const Color(0xFFB71C1C), const Color(0xFFEF5350)]
              : [const Color(0xFF4527A0), const Color(0xFF7E57C2)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              GlassCard(
                opacity: 0.9,
                color: isDarurat ? const Color(0xFFFFEBEE) : Colors.white,
                borderColor: isDarurat ? Colors.red : Colors.white54,
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (berita.gambarUrl != null && berita.gambarUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.network(
                          '${ApiService.publicBaseUrl}${berita.gambarUrl!}',
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => const SizedBox(),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isDarurat)
                            Container(
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD32F2F),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text("PERINGATAN DARURAT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                            ),

                          Text(
                            berita.judul,
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: isDarurat ? const Color(0xFFB71C1C) : const Color(0xFF311B92), height: 1.2),
                          ),
                          const SizedBox(height: 10),
                          
                          Row(
                            children: [
                              Icon(Icons.person, size: 14, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(berita.authorName, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                              const Spacer(),
                              Text(DateFormat('dd MMM yyyy, HH:mm').format(berita.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            ],
                          ),
                          const Divider(height: 30),
                          Text(berita.isi, style: const TextStyle(fontSize: 16, height: 1.6), textAlign: TextAlign.justify),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}