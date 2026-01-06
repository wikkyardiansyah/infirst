/// Model Karyawan Terdaftar (Registered Employee)
/// Menyimpan data karyawan yang sudah didaftarkan oleh admin
class RegisteredEmployee {
  final String id;
  final String nama;
  final String email;
  final String password;
  final String jabatan;
  final DateTime tanggalDaftar;
  final bool isActive;

  RegisteredEmployee({
    required this.id,
    required this.nama,
    required this.email,
    required this.password,
    required this.jabatan,
    required this.tanggalDaftar,
    this.isActive = true,
  });

  /// Factory constructor untuk membuat RegisteredEmployee dari JSON
  factory RegisteredEmployee.fromJson(Map<String, dynamic> json) {
    return RegisteredEmployee(
      id: json['id'] as String,
      nama: json['nama'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      jabatan: json['jabatan'] as String,
      tanggalDaftar: DateTime.parse(json['tanggal_daftar'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Mengkonversi RegisteredEmployee ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'password': password,
      'jabatan': jabatan,
      'tanggal_daftar': tanggalDaftar.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Membuat salinan dengan data yang diubah
  RegisteredEmployee copyWith({
    String? id,
    String? nama,
    String? email,
    String? password,
    String? jabatan,
    DateTime? tanggalDaftar,
    bool? isActive,
  }) {
    return RegisteredEmployee(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      password: password ?? this.password,
      jabatan: jabatan ?? this.jabatan,
      tanggalDaftar: tanggalDaftar ?? this.tanggalDaftar,
      isActive: isActive ?? this.isActive,
    );
  }
}
