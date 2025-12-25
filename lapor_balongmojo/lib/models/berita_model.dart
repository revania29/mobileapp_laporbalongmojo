class BeritaModel {
  final int id;
  final String judul;
  final String isi;
  final String? gambarUrl;
  final bool isDarurat;
  final String createdAt;

  BeritaModel({
    required this.id,
    required this.judul,
    required this.isi,
    this.gambarUrl,
    required this.isDarurat,
    required this.createdAt,
  });

  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    bool parseDarurat(dynamic val) {
      if (val == 1 || val == '1' || val == true || val == 'true') {
        return true;
      }
      return false;
    }

    return BeritaModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      judul: json['judul'] ?? 'Tanpa Judul',
      isi: json['isi'] ?? '-',
      gambarUrl: (json['gambar_url'] != null && json['gambar_url'].toString().isNotEmpty) 
          ? json['gambar_url'] 
          : null,
      isDarurat: parseDarurat(json['is_darurat']),
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
    );
  }
}