/// Konstanta aplikasi INFIRST
class AppConstants {
  // Nama Aplikasi
  static const String appName = 'INFIRST';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Aplikasi Absensi Karyawan';

  // Jam Kerja Default
  static const int jamMasuk = 8; // 08:00
  static const int jamPulang = 17; // 17:00

  // Status Presensi
  static const String statusHadir = 'HADIR';
  static const String statusAlfa = 'ALFA';

  // Shared Preferences Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyEmployeeData = 'employee_data';
  static const String keyAttendanceHistory = 'attendance_history';

  // Messages
  static const String msgCheckInSuccess = 'Check-in berhasil!';
  static const String msgCheckOutSuccess = 'Check-out berhasil!';
  static const String msgAlreadyCheckIn = 'Anda sudah melakukan check-in hari ini';
  static const String msgAlreadyCheckOut = 'Anda sudah melakukan check-out hari ini';
  static const String msgNoCheckIn = 'Anda belum melakukan check-in hari ini';
}
