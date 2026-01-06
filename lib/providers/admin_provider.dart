import 'package:flutter/material.dart';
import '../models/registered_employee.dart';
import '../models/attendance.dart';
import '../services/admin_service.dart';

/// Provider untuk mengelola state admin dashboard
class AdminProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  List<RegisteredEmployee> _employees = [];
  List<Map<String, dynamic>> _attendanceRecords = [];
  Map<String, dynamic> _stats = {};

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  List<RegisteredEmployee> get employees => _employees;
  List<Map<String, dynamic>> get attendanceRecords => _attendanceRecords;
  Map<String, dynamic> get stats => _stats;

  /// Login admin
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final isValid = await _adminService.validateAdminLogin(email, password);

    if (isValid) {
      _isLoggedIn = true;
      _isLoading = false;
      await loadAllData();
      notifyListeners();
      return true;
    } else {
      _isLoading = false;
      _errorMessage = 'Email atau password admin salah';
      notifyListeners();
      return false;
    }
  }

  /// Logout admin
  void logout() {
    _isLoggedIn = false;
    _employees = [];
    _attendanceRecords = [];
    _stats = {};
    notifyListeners();
  }

  /// Load semua data
  Future<void> loadAllData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _employees = await _adminService.getAllEmployees();
      _attendanceRecords = await _adminService.getAllAttendanceRecords();
      _stats = await _adminService.getAttendanceStats();
    } catch (e) {
      _errorMessage = 'Gagal memuat data: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Tambah karyawan baru
  Future<bool> addEmployee({
    required String nama,
    required String email,
    required String password,
    required String jabatan,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Cek apakah email sudah terdaftar
      final isRegistered = await _adminService.isEmailRegistered(email);
      if (isRegistered) {
        _isLoading = false;
        _errorMessage = 'Email sudah terdaftar';
        notifyListeners();
        return false;
      }

      final employee = RegisteredEmployee(
        id: 'EMP_${DateTime.now().millisecondsSinceEpoch}',
        nama: nama,
        email: email,
        password: password,
        jabatan: jabatan,
        tanggalDaftar: DateTime.now(),
      );

      await _adminService.addEmployee(employee);
      _employees = await _adminService.getAllEmployees();
      _successMessage = 'Karyawan berhasil ditambahkan';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal menambah karyawan: $e';
      notifyListeners();
      return false;
    }
  }

  /// Update karyawan
  Future<bool> updateEmployee(RegisteredEmployee employee) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _adminService.updateEmployee(employee);
      _employees = await _adminService.getAllEmployees();
      _successMessage = 'Data karyawan berhasil diperbarui';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal memperbarui data: $e';
      notifyListeners();
      return false;
    }
  }

  /// Hapus karyawan
  Future<bool> deleteEmployee(String id) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _adminService.deleteEmployee(id);
      _employees = await _adminService.getAllEmployees();
      _successMessage = 'Karyawan berhasil dihapus';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal menghapus karyawan: $e';
      notifyListeners();
      return false;
    }
  }

  /// Toggle status aktif karyawan
  Future<bool> toggleEmployeeStatus(RegisteredEmployee employee) async {
    final updated = employee.copyWith(isActive: !employee.isActive);
    return await updateEmployee(updated);
  }

  /// Mendapatkan presensi karyawan tertentu
  Future<List<Attendance>> getEmployeeAttendance(String email) async {
    return await _adminService.getEmployeeAttendance(email);
  }

  /// Refresh data
  Future<void> refresh() async {
    await loadAllData();
  }

  /// Clear messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
