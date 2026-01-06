/// Model Karyawan (Employee)
/// Menyimpan data profil karyawan
class Employee {
  final String id;
  final String nama;
  final String jabatan;
  final String email;
  final String? fotoUrl;
  final DateTime tanggalBergabung;

  Employee({
    required this.id,
    required this.nama,
    required this.jabatan,
    required this.email,
    this.fotoUrl,
    required this.tanggalBergabung,
  });

  /// Factory constructor untuk membuat Employee dari JSON
  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String,
      nama: json['nama'] as String,
      jabatan: json['jabatan'] as String,
      email: json['email'] as String,
      fotoUrl: json['foto_url'] as String?,
      tanggalBergabung: DateTime.parse(json['tanggal_bergabung'] as String),
    );
  }

  /// Mengkonversi Employee ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'jabatan': jabatan,
      'email': email,
      'foto_url': fotoUrl,
      'tanggal_bergabung': tanggalBergabung.toIso8601String(),
    };
  }

  /// Membuat salinan Employee dengan data yang diubah
  Employee copyWith({
    String? id,
    String? nama,
    String? jabatan,
    String? email,
    String? fotoUrl,
    DateTime? tanggalBergabung,
  }) {
    return Employee(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      jabatan: jabatan ?? this.jabatan,
      email: email ?? this.email,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      tanggalBergabung: tanggalBergabung ?? this.tanggalBergabung,
    );
  }
}
