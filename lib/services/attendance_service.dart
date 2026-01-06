import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/attendance.dart';
import '../core/constants/app_constants.dart';
import 'location_service.dart';

/// Service untuk mengelola data presensi
/// Menggunakan SharedPreferences untuk penyimpanan lokal
class AttendanceService {
  static const String _attendanceKey = AppConstants.keyAttendanceHistory;
  final LocationService _locationService = LocationService();

  /// Menyimpan data presensi ke local storage
  Future<void> saveAttendance(Attendance attendance) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Attendance> allAttendances = await getAllAttendances();

    // Cek apakah sudah ada presensi untuk tanggal yang sama
    final existingIndex = allAttendances.indexWhere(
      (a) =>
          a.employeeId == attendance.employeeId &&
          _isSameDate(a.tanggal, attendance.tanggal),
    );

    if (existingIndex != -1) {
      // Update data yang sudah ada
      allAttendances[existingIndex] = attendance;
    } else {
      // Tambah data baru
      allAttendances.add(attendance);
    }

    // Simpan ke SharedPreferences
    final jsonList = allAttendances.map((a) => a.toJson()).toList();
    await prefs.setString(_attendanceKey, jsonEncode(jsonList));
  }

  /// Mengambil semua data presensi
  Future<List<Attendance>> getAllAttendances() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_attendanceKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Attendance.fromJson(json)).toList();
  }

  /// Mengambil data presensi berdasarkan employee ID
  Future<List<Attendance>> getAttendancesByEmployee(String employeeId) async {
    final allAttendances = await getAllAttendances();
    return allAttendances.where((a) => a.employeeId == employeeId).toList();
  }

  /// Mengambil data presensi hari ini
  Future<Attendance?> getTodayAttendance(String employeeId) async {
    final allAttendances = await getAttendancesByEmployee(employeeId);
    final today = DateTime.now();

    try {
      return allAttendances.firstWhere(
        (a) => _isSameDate(a.tanggal, today),
      );
    } catch (e) {
      return null;
    }
  }

  /// Mengambil data presensi berdasarkan rentang tanggal
  Future<List<Attendance>> getAttendancesByDateRange(
    String employeeId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allAttendances = await getAttendancesByEmployee(employeeId);
    return allAttendances.where((a) {
      return (a.tanggal.isAfter(startDate) ||
              _isSameDate(a.tanggal, startDate)) &&
          (a.tanggal.isBefore(endDate) || _isSameDate(a.tanggal, endDate));
    }).toList();
  }

  /// Menghitung ringkasan kehadiran bulan ini
  Future<AttendanceSummary> getMonthlyAttendanceSummary(
    String employeeId,
  ) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    final attendances = await getAttendancesByDateRange(
      employeeId,
      startOfMonth,
      endOfMonth,
    );

    int hadir = 0;
    int alfa = 0;

    for (final attendance in attendances) {
      switch (attendance.status) {
        case AttendanceStatus.hadir:
          hadir++;
          break;
        case AttendanceStatus.alfa:
          alfa++;
          break;
      }
    }

    // Hitung total hari kerja (Senin - Sabtu) dalam bulan ini
    int totalHariKerja = 0;
    DateTime currentDate = startOfMonth;
    final today = DateTime.now();

    while (currentDate.isBefore(endOfMonth) ||
        _isSameDate(currentDate, endOfMonth)) {
      if (currentDate.weekday >= 1 &&
          currentDate.weekday <= 6 &&
          (currentDate.isBefore(today) || _isSameDate(currentDate, today))) {
        totalHariKerja++;
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return AttendanceSummary(
      totalHadir: hadir,
      totalAlfa: alfa,
      totalHariKerja: totalHariKerja,
    );
  }

  /// Melakukan check-in dengan lokasi GPS
  Future<Attendance> checkIn(String employeeId, {String? fotoPath}) async {
    final now = DateTime.now();

    // Dapatkan lokasi GPS
    final locationData = await _locationService.getCurrentLocation();

    final attendance = Attendance(
      id: 'ATT_${employeeId}_${now.millisecondsSinceEpoch}',
      employeeId: employeeId,
      tanggal: DateTime(now.year, now.month, now.day),
      waktuCheckIn: now,
      status: AttendanceStatus.hadir,
      fotoCheckIn: fotoPath,
      latitudeCheckIn: locationData?.latitude,
      longitudeCheckIn: locationData?.longitude,
      alamatCheckIn: locationData?.alamat,
    );

    await saveAttendance(attendance);
    return attendance;
  }

  /// Melakukan check-out dengan lokasi GPS
  Future<Attendance?> checkOut(String employeeId, {String? fotoPath}) async {
    final todayAttendance = await getTodayAttendance(employeeId);

    if (todayAttendance == null) {
      return null;
    }

    // Dapatkan lokasi GPS
    final locationData = await _locationService.getCurrentLocation();

    final now = DateTime.now();
    final updatedAttendance = todayAttendance.copyWith(
      waktuCheckOut: now,
      fotoCheckOut: fotoPath,
      latitudeCheckOut: locationData?.latitude,
      longitudeCheckOut: locationData?.longitude,
      alamatCheckOut: locationData?.alamat,
    );

    await saveAttendance(updatedAttendance);
    return updatedAttendance;
  }

  /// Menghapus semua data (untuk reset)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_attendanceKey);
  }

  /// Helper untuk membandingkan tanggal (tanpa waktu)
  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
