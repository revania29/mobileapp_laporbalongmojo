class LaporanModel {
  final int id;
  final String judul;
  final String deskripsi;
  final String? fotoUrl;
  final String status;
  final DateTime tanggal;
  final String pelapor;
  final String? noTelepon; 

  LaporanModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    this.fotoUrl,
    required this.status,
    required this.tanggal,
    required this.pelapor,
    this.noTelepon,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    return LaporanModel(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? 'Tanpa Judul',
      deskripsi: json['deskripsi'] ?? '',
      fotoUrl: json['foto_url'], 
      status: json['status'] ?? 'belum terdaftar',
      tanggal: json['created_at'] != null 
          ? DateTime.parse(json['created_at']).add(const Duration(hours: 7)) 
          : DateTime.now(),
      
      pelapor: json['pelapor'] ?? 'Warga', 
      noTelepon: json['no_telepon'], 
    );
  }
}