import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../models/employee.dart';
import '../services/attendance_service.dart';
import '../services/employee_service.dart';

/// Provider untuk mengelola state presensi
/// 
/// Fungsi utama:
/// - Menyimpan dan mengambil data presensi
/// - Mengelola check-in dan check-out
/// - Menyediakan ringkasan kehadiran
/// - Mengelola riwayat presensi dengan filter
class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();
  final EmployeeService _employeeService = EmployeeService();
  
  Employee? _employee;

  // State
  Attendance? _todayAttendance;
  List<Attendance> _attendanceHistory = [];
  AttendanceSummary _summary = AttendanceSummary.empty();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  DateTime _selectedFilterDate = DateTime.now();

  // Getters
  Attendance? get todayAttendance => _todayAttendance;
  List<Attendance> get attendanceHistory => _attendanceHistory;
  AttendanceSummary get summary => _summary;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  Employee? get employee => _employee;
  DateTime get selectedFilterDate => _selectedFilterDate;

  /// Status check-in hari ini
  bool get sudahCheckIn => _todayAttendance?.sudahCheckIn ?? false;

  /// Status check-out hari ini
  bool get sudahCheckOut => _todayAttendance?.sudahCheckOut ?? false;

  /// Apakah employee sudah terload
  bool get hasEmployee => _employee != null;

  /// Inisialisasi dengan email dari login
  Future<void> initializeWithEmail(String email) async {
    _setLoading(true);
    try {
      _employee = await _employeeService.getOrCreateEmployee(email);
      await loadTodayAttendance();
      await loadMonthlySummary();
      await loadAttendanceHistory();
    } catch (e) {
      _errorMessage = 'Gagal menginisialisasi data';
    }
    _setLoading(false);
  }

  /// Inisialisasi data saat aplikasi dimulai (load employee dari storage)
  Future<void> initialize() async {
    _setLoading(true);
    try {
      _employee = await _employeeService.getEmployee();
      if (_employee != null) {
        await loadTodayAttendance();
        await loadMonthlySummary();
        await loadAttendanceHistory();
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat data';
    }
    _setLoading(false);
  }

  /// Memuat data presensi hari ini
  Future<void> loadTodayAttendance() async {
    if (_employee == null) return;
    
    _setLoading(true);
    try {
      _todayAttendance = await _attendanceService.getTodayAttendance(
        _employee!.id,
      );
      _clearMessages();
    } catch (e) {
      _errorMessage = 'Gagal memuat data presensi hari ini';
    }
    _setLoading(false);
  }

  /// Memuat ringkasan kehadiran bulan ini
  Future<void> loadMonthlySummary() async {
    if (_employee == null) return;
    
    try {
      _summary = await _attendanceService.getMonthlyAttendanceSummary(
        _employee!.id,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat ringkasan kehadiran';
      notifyListeners();
    }
  }

  /// Memuat riwayat presensi
  Future<void> loadAttendanceHistory() async {
    if (_employee == null) return;
    
    _setLoading(true);
    try {
      _attendanceHistory = await _attendanceService.getAttendancesByEmployee(
        _employee!.id,
      );
      // Urutkan dari terbaru
      _attendanceHistory.sort((a, b) => b.tanggal.compareTo(a.tanggal));
      _clearMessages();
    } catch (e) {
      _errorMessage = 'Gagal memuat riwayat presensi';
    }
    _setLoading(false);
  }

  /// Melakukan check-in
  Future<bool> checkIn({String? fotoPath}) async {
    if (_employee == null) {
      _errorMessage = 'Data karyawan belum tersedia';
      notifyListeners();
      return false;
    }

    if (sudahCheckIn) {
      _errorMessage = 'Anda sudah melakukan check-in hari ini';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      _todayAttendance = await _attendanceService.checkIn(
        _employee!.id,
        fotoPath: fotoPath,
      );
      _successMessage = 'Check-in berhasil!';
      await loadMonthlySummary();
      await loadAttendanceHistory();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal melakukan check-in';
      _setLoading(false);
      return false;
    }
  }

  /// Melakukan check-out
  Future<bool> checkOut({String? fotoPath}) async {
    if (_employee == null) {
      _errorMessage = 'Data karyawan belum tersedia';
      notifyListeners();
      return false;
    }

    if (!sudahCheckIn) {
      _errorMessage = 'Anda belum melakukan check-in hari ini';
      notifyListeners();
      return false;
    }

    if (sudahCheckOut) {
      _errorMessage = 'Anda sudah melakukan check-out hari ini';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      _todayAttendance = await _attendanceService.checkOut(
        _employee!.id,
        fotoPath: fotoPath,
      );
      _successMessage = 'Check-out berhasil!';
      await loadAttendanceHistory();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal melakukan check-out';
      _setLoading(false);
      return false;
    }
  }

  /// Filter riwayat berdasarkan bulan
  Future<void> filterByMonth(DateTime date) async {
    if (_employee == null) return;

    _selectedFilterDate = date;
    _setLoading(true);
    try {
      final startOfMonth = DateTime(date.year, date.month, 1);
      final endOfMonth = DateTime(date.year, date.month + 1, 0);

      _attendanceHistory = await _attendanceService.getAttendancesByDateRange(
        _employee!.id,
        startOfMonth,
        endOfMonth,
      );
      _attendanceHistory.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    } catch (e) {
      _errorMessage = 'Gagal memfilter riwayat';
    }
    _setLoading(false);
  }

  /// Update profil karyawan
  Future<bool> updateProfile({
    String? nama,
    String? jabatan,
  }) async {
    if (_employee == null) {
      _errorMessage = 'Data karyawan belum tersedia';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    try {
      _employee = await _employeeService.updateEmployee(
        currentEmployee: _employee!,
        nama: nama,
        jabatan: jabatan,
      );
      _successMessage = 'Profil berhasil diperbarui!';
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Gagal memperbarui profil';
      _setLoading(false);
      return false;
    }
  }

  /// Menghapus pesan
  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  /// Menghapus pesan sukses/error secara manual
  void clearMessages() {
    _clearMessages();
    notifyListeners();
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Reset semua data (untuk testing atau logout)
  Future<void> resetAllData() async {
    await _attendanceService.clearAllData();
    _todayAttendance = null;
    _attendanceHistory = [];
    _summary = AttendanceSummary.empty();
    notifyListeners();
  }

  /// Clear data saat logout
  Future<void> clearOnLogout() async {
    _employee = null;
    _todayAttendance = null;
    _attendanceHistory = [];
    _summary = AttendanceSummary.empty();
    await _employeeService.clearEmployee();
    notifyListeners();
  }
}
