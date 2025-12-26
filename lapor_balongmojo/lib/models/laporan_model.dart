class LaporanModel {
  final int id;
  final String judul;
  final String deskripsi;
  final String? fotoUrl;
  final String status;
  final DateTime tanggal; // Menggunakan nama 'tanggal' sesuai permintaan Anda
  final String pelapor;

  LaporanModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    this.fotoUrl,
    required this.status,
    required this.tanggal,
    required this.pelapor,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    return LaporanModel(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? 'Tanpa Judul',
      deskripsi: json['deskripsi'] ?? '',
      
      // Sesuaikan dengan respon backend (biasanya snake_case: foto_url)
      fotoUrl: json['foto_url'], 
      
      status: json['status'] ?? 'belum terdaftar',
      
      // Map 'created_at' dari database ke variabel 'tanggal'
      tanggal: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      
      // ✅ PERBAIKAN DI SINI:
      // Backend mengirim key 'pelapor' (karena query: u.nama_lengkap AS pelapor)
      // Jadi kita panggil json['pelapor'], BUKAN json['pelapor_name']
      pelapor: json['pelapor'] ?? 'Warga', 
    );
  }
}