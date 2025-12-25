class LaporanModel {
  final int id;
  final int userId;
  final String judul;
  final String deskripsi;
  final String? fotoUrl;
  final String? lokasi;
  final String status;
  final String createdAt;
  final String? namaPelapor;

  LaporanModel({
    required this.id,
    required this.userId,
    required this.judul,
    required this.deskripsi,
    this.fotoUrl,
    this.lokasi,
    required this.status,
    required this.createdAt,
    this.namaPelapor,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    return LaporanModel(
      id: int.tryParse(json['id'].toString()) ?? 0, 
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      judul: json['judul'] ?? 'Tanpa Judul',
      deskripsi: json['deskripsi'] ?? '-',
      fotoUrl: (json['foto_url'] != null && json['foto_url'].toString().isNotEmpty) 
          ? json['foto_url'] 
          : null, 
      lokasi: json['lokasi'],
      status: json['status'] ?? 'menunggu',
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
      namaPelapor: json['nama_lengkap'],
    );
  }
}