class BeritaModel {
  final int id;
  final String judul;
  final String isi;
  final String? gambarUrl;
  final String authorName;
  final DateTime createdAt;
  final bool isPeringatanDarurat;

  BeritaModel({
    required this.id,
    required this.judul,
    required this.isi,
    this.gambarUrl,
    required this.authorName,
    required this.createdAt,
    this.isPeringatanDarurat = false,
  });

  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    // LOGIKA PERBAIKAN: Sesuaikan KEY dengan DATABASE (is_peringatan_darurat)
    bool checkEmergency = false;
    
    // Cek kolom 'is_peringatan_darurat' (Sesuai screenshot database Anda)
    if (json['is_peringatan_darurat'] != null) {
      var val = json['is_peringatan_darurat'];
      if (val is int) {
        checkEmergency = (val == 1);
      } else if (val is String) {
        checkEmergency = (val == '1' || val.toLowerCase() == 'true');
      } else if (val is bool) {
        checkEmergency = val;
      }
    }

    return BeritaModel(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      isi: json['isi'] ?? '',
      gambarUrl: json['gambar_url'], 
      authorName: json['author_name'] ?? 'Admin',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      isPeringatanDarurat: checkEmergency, 
    );
  }
}