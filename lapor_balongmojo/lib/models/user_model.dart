class UserModel {
  final int id;
  final String nama;
  final String email;
  final String role;
  final String? noTelepon;
  final String? fotoProfil;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
    this.noTelepon,
    this.fotoProfil,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // Menggunakan parse toString() untuk jaga-jaga jika ID dikirim sebagai String dari backend
      id: int.tryParse(json['id'].toString()) ?? 0, 
      nama: json['nama'] ?? 'No Name',
      email: json['email'] ?? '',
      role: json['role'] ?? 'masyarakat',
      // Mengambil data snake_case dari backend
      noTelepon: json['no_telepon'], 
      fotoProfil: json['foto_profil'],
    );
  }

  // Method ini sangat berguna di AuthProvider saat update profile
  UserModel copyWith({
    int? id,
    String? nama,
    String? email,
    String? role,
    String? noTelepon,
    String? fotoProfil,
  }) {
    return UserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      role: role ?? this.role,
      noTelepon: noTelepon ?? this.noTelepon,
      fotoProfil: fotoProfil ?? this.fotoProfil,
    );
  }
}