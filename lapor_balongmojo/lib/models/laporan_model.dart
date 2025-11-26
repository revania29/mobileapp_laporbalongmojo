class LaporanModel {
  final int id;
  final String judul;
  final String deskripsi;
  final String? fotoUrl;
  final String status;
  final String createdAt;

  LaporanModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    this.fotoUrl,
    required this.status,
    required this.createdAt,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    return LaporanModel(
      id: json['id'],
      judul: json['judul'],
      deskripsi: json['deskripsi'],
      fotoUrl: json['foto_url'], 
      status: json['status'] ?? 'menunggu',
      createdAt: json['created_at'] ?? '',
    );
  }
}