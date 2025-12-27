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
              ? [const Color(0xFFB71C1C), const Color(0xFFD32F2F)]
              : [const Color(0xFF2E004F), const Color(0xFF6A0059)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            isDarurat ? "INFO DARURAT" : "DETAIL BERITA",
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            children: [
              if (isDarurat)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Center(
                    child: Text(
                      "🚨 PERINGATAN DARURAT 🚨",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.2),
                    ),
                  ),
                ),
              GlassCard(
                opacity: 0.1,
                color: Colors.black,
                borderColor: isDarurat ? Colors.white30 : Colors.white12,
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (berita.gambarUrl != null && berita.gambarUrl!.isNotEmpty)
                      ClipRRect(
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(20)),
                        child: Image.network(
                          '${ApiService.publicBaseUrl}${berita.gambarUrl!}',
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(
                            height: 200,
                            color: Colors.white10,
                            child: const Icon(Icons.broken_image,
                                color: Colors.white24, size: 50),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            berita.judul,
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.2),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 14,
                                  color: isDarurat
                                      ? Colors.white
                                      : Colors.cyanAccent),
                              const SizedBox(width: 6),
                              Text(
                                DateFormat('EEEE, dd MMM yyyy • HH:mm')
                                    .format(berita.createdAt),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white54),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.person_outline_rounded,
                                  size: 14, color: Colors.white54),
                              const SizedBox(width: 6),
                              Text(
                                berita.authorName,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white54),
                              ),
                            ],
                          ),
                          const Divider(height: 40, color: Colors.white10),
                          Text(
                            berita.isi,
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                                height: 1.6,
                                letterSpacing: 0.2),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                  ],
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