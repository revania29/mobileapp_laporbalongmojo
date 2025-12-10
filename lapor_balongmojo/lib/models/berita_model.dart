class BeritaModel {
  final int id;
  final String judul;
  final String isi;
  final String? gambarUrl;
  final String createdAt;

  BeritaModel({
    required this.id,
    required this.judul,
    required this.isi,
    this.gambarUrl,
    required this.createdAt,
  });

  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    return BeritaModel(
      id: json['id'],
      judul: json['judul'],
      isi: json['isi'],
      gambarUrl: json['gambar_url'],
      createdAt: json['created_at'] ?? '',
    );
  }
}