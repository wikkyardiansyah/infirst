/// Model Presensi (Attendance)
/// Menyimpan data presensi karyawan per hari
class Attendance {
  final String id;
  final String employeeId;
  final DateTime tanggal;
  final DateTime? waktuCheckIn;
  final DateTime? waktuCheckOut;
  final AttendanceStatus status;
  final String? keterangan;
  final String? fotoCheckIn;
  final String? fotoCheckOut;
  final double? latitudeCheckIn;
  final double? longitudeCheckIn;
  final double? latitudeCheckOut;
  final double? longitudeCheckOut;
  final String? alamatCheckIn;
  final String? alamatCheckOut;

  Attendance({
    required this.id,
    required this.employeeId,
    required this.tanggal,
    this.waktuCheckIn,
    this.waktuCheckOut,
    required this.status,
    this.keterangan,
    this.fotoCheckIn,
    this.fotoCheckOut,
    this.latitudeCheckIn,
    this.longitudeCheckIn,
    this.latitudeCheckOut,
    this.longitudeCheckOut,
    this.alamatCheckIn,
    this.alamatCheckOut,
  });

  /// Cek apakah sudah check-in
  bool get sudahCheckIn => waktuCheckIn != null;

  /// Cek apakah sudah check-out
  bool get sudahCheckOut => waktuCheckOut != null;

  /// Menghitung durasi kerja dalam jam
  double get durasiKerja {
    if (waktuCheckIn == null || waktuCheckOut == null) return 0;
    final durasi = waktuCheckOut!.difference(waktuCheckIn!);
    return durasi.inMinutes / 60;
  }

  /// Format durasi kerja
  String get durasiKerjaFormatted {
    if (waktuCheckIn == null || waktuCheckOut == null) return '-';
    final durasi = waktuCheckOut!.difference(waktuCheckIn!);
    final jam = durasi.inHours;
    final menit = durasi.inMinutes % 60;
    return '${jam}j ${menit}m';
  }

  /// Factory constructor untuk membuat Attendance dari JSON
  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String,
      tanggal: DateTime.parse(json['tanggal'] as String),
      waktuCheckIn: json['waktu_check_in'] != null
          ? DateTime.parse(json['waktu_check_in'] as String)
          : null,
      waktuCheckOut: json['waktu_check_out'] != null
          ? DateTime.parse(json['waktu_check_out'] as String)
          : null,
      status: AttendanceStatus.fromString(json['status'] as String),
      keterangan: json['keterangan'] as String?,
      fotoCheckIn: json['foto_check_in'] as String?,
      fotoCheckOut: json['foto_check_out'] as String?,
      latitudeCheckIn: json['latitude_check_in'] as double?,
      longitudeCheckIn: json['longitude_check_in'] as double?,
      latitudeCheckOut: json['latitude_check_out'] as double?,
      longitudeCheckOut: json['longitude_check_out'] as double?,
      alamatCheckIn: json['alamat_check_in'] as String?,
      alamatCheckOut: json['alamat_check_out'] as String?,
    );
  }

  /// Mengkonversi Attendance ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'tanggal': tanggal.toIso8601String(),
      'waktu_check_in': waktuCheckIn?.toIso8601String(),
      'waktu_check_out': waktuCheckOut?.toIso8601String(),
      'status': status.name,
      'keterangan': keterangan,
      'foto_check_in': fotoCheckIn,
      'foto_check_out': fotoCheckOut,
      'latitude_check_in': latitudeCheckIn,
      'longitude_check_in': longitudeCheckIn,
      'latitude_check_out': latitudeCheckOut,
      'longitude_check_out': longitudeCheckOut,
      'alamat_check_in': alamatCheckIn,
      'alamat_check_out': alamatCheckOut,
    };
  }

  /// Membuat salinan Attendance dengan data yang diubah
  Attendance copyWith({
    String? id,
    String? employeeId,
    DateTime? tanggal,
    DateTime? waktuCheckIn,
    DateTime? waktuCheckOut,
    AttendanceStatus? status,
    String? keterangan,
    String? fotoCheckIn,
    String? fotoCheckOut,
    double? latitudeCheckIn,
    double? longitudeCheckIn,
    double? latitudeCheckOut,
    double? longitudeCheckOut,
    String? alamatCheckIn,
    String? alamatCheckOut,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      tanggal: tanggal ?? this.tanggal,
      waktuCheckIn: waktuCheckIn ?? this.waktuCheckIn,
      waktuCheckOut: waktuCheckOut ?? this.waktuCheckOut,
      status: status ?? this.status,
      keterangan: keterangan ?? this.keterangan,
      fotoCheckIn: fotoCheckIn ?? this.fotoCheckIn,
      fotoCheckOut: fotoCheckOut ?? this.fotoCheckOut,
      latitudeCheckIn: latitudeCheckIn ?? this.latitudeCheckIn,
      longitudeCheckIn: longitudeCheckIn ?? this.longitudeCheckIn,
      latitudeCheckOut: latitudeCheckOut ?? this.latitudeCheckOut,
      longitudeCheckOut: longitudeCheckOut ?? this.longitudeCheckOut,
      alamatCheckIn: alamatCheckIn ?? this.alamatCheckIn,
      alamatCheckOut: alamatCheckOut ?? this.alamatCheckOut,
    );
  }
}

/// Enum Status Presensi (disederhanakan - hanya hadir dan alfa)
enum AttendanceStatus {
  hadir,
  alfa;

  /// Mendapatkan label untuk ditampilkan
  String get label {
    switch (this) {
      case AttendanceStatus.hadir:
        return 'HADIR';
      case AttendanceStatus.alfa:
        return 'ALFA';
    }
  }

  /// Factory constructor dari string
  static AttendanceStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'hadir':
        return AttendanceStatus.hadir;
      case 'alfa':
      default:
        return AttendanceStatus.alfa;
    }
  }
}

/// Model Ringkasan Kehadiran (disederhanakan)
class AttendanceSummary {
  final int totalHadir;
  final int totalAlfa;
  final int totalHariKerja;

  AttendanceSummary({
    required this.totalHadir,
    required this.totalAlfa,
    required this.totalHariKerja,
  });

  /// Persentase kehadiran
  double get persentaseKehadiran {
    if (totalHariKerja == 0) return 0;
    return (totalHadir / totalHariKerja) * 100;
  }

  /// Factory untuk ringkasan kosong
  factory AttendanceSummary.empty() {
    return AttendanceSummary(
      totalHadir: 0,
      totalAlfa: 0,
      totalHariKerja: 0,
    );
  }
}
