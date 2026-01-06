import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/registered_employee.dart';
import '../models/attendance.dart';
import '../core/constants/app_constants.dart';

/// Service untuk mengelola data admin
/// Menggunakan SharedPreferences untuk penyimpanan lokal
class AdminService {
  static const String _employeesKey = 'registered_employees';
  static const String _attendanceKey = AppConstants.keyAttendanceHistory;
  static const String _adminCredentialsKey = 'admin_credentials';

  // Default admin credentials
  static const String defaultAdminEmail = 'admin@infirst.com';
  static const String defaultAdminPassword = 'admin123';

  /// Validasi login admin
  Future<bool> validateAdminLogin(String email, String password) async {
    // Untuk sementara gunakan credential default
    // Bisa dikembangkan dengan menyimpan ke SharedPreferences
    return email == defaultAdminEmail && password == defaultAdminPassword;
  }

  /// Mendapatkan semua karyawan terdaftar
  Future<List<RegisteredEmployee>> getAllEmployees() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_employeesKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => RegisteredEmployee.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Menyimpan karyawan baru
  Future<void> addEmployee(RegisteredEmployee employee) async {
    final employees = await getAllEmployees();
    employees.add(employee);
    await _saveEmployees(employees);
  }

  /// Update karyawan
  Future<void> updateEmployee(RegisteredEmployee employee) async {
    final employees = await getAllEmployees();
    final index = employees.indexWhere((e) => e.id == employee.id);
    if (index != -1) {
      employees[index] = employee;
      await _saveEmployees(employees);
    }
  }

  /// Hapus karyawan
  Future<void> deleteEmployee(String id) async {
    final employees = await getAllEmployees();
    employees.removeWhere((e) => e.id == id);
    await _saveEmployees(employees);
  }

  /// Validasi login karyawan
  Future<RegisteredEmployee?> validateEmployeeLogin(
    String email,
    String password,
  ) async {
    final employees = await getAllEmployees();
    try {
      return employees.firstWhere(
        (e) => e.email == email && e.password == password && e.isActive,
      );
    } catch (e) {
      return null;
    }
  }

  /// Cek apakah email sudah terdaftar
  Future<bool> isEmailRegistered(String email) async {
    final employees = await getAllEmployees();
    return employees.any((e) => e.email == email);
  }

  /// Simpan daftar karyawan
  Future<void> _saveEmployees(List<RegisteredEmployee> employees) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(
      employees.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_employeesKey, jsonString);
  }

  /// Mendapatkan semua record presensi
  Future<List<Map<String, dynamic>>> getAllAttendanceRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_attendanceKey);
    final employees = await getAllEmployees();

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<Map<String, dynamic>> records = [];
      
      for (final json in jsonList) {
        final record = json as Map<String, dynamic>;
        final employeeId = record['employee_id'] as String?;
        
        // Cari nama karyawan berdasarkan employeeId
        String employeeName = 'Unknown';
        String employeeEmail = '';
        
        for (final emp in employees) {
          if (emp.email == employeeId || emp.id == employeeId) {
            employeeName = emp.nama;
            employeeEmail = emp.email;
            break;
          }
        }
        
        records.add({
          ...record,
          'employee_name': employeeName,
          'employee_email': employeeEmail,
        });
      }
      
      // Sort by date descending
      records.sort((a, b) {
        final dateA = DateTime.tryParse(a['tanggal'] ?? '') ?? DateTime(2000);
        final dateB = DateTime.tryParse(b['tanggal'] ?? '') ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });
      
      return records;
    } catch (e) {
      return [];
    }
  }

  /// Mendapatkan presensi per karyawan
  Future<List<Attendance>> getEmployeeAttendance(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_attendanceKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<Attendance> attendances = [];
      
      for (final json in jsonList) {
        final record = Attendance.fromJson(json);
        // Filter by employee email or id
        if (record.employeeId == email) {
          attendances.add(record);
        }
      }
      
      return attendances;
    } catch (e) {
      return [];
    }
  }

  /// Mendapatkan statistik kehadiran
  Future<Map<String, dynamic>> getAttendanceStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final employees = await getAllEmployees();
    int totalHadir = 0;
    int totalAlfa = 0;
    int totalKaryawan = employees.length;

    for (final employee in employees) {
      final attendance = await getEmployeeAttendance(employee.email);
      
      for (final record in attendance) {
        // Filter berdasarkan tanggal jika ada
        if (startDate != null && record.tanggal.isBefore(startDate)) continue;
        if (endDate != null && record.tanggal.isAfter(endDate)) continue;

        if (record.status == AttendanceStatus.hadir) {
          totalHadir++;
        } else {
          totalAlfa++;
        }
      }
    }

    return {
      'total_karyawan': totalKaryawan,
      'total_hadir': totalHadir,
      'total_alfa': totalAlfa,
      'persentase_kehadiran': totalHadir + totalAlfa > 0
          ? (totalHadir / (totalHadir + totalAlfa) * 100).toStringAsFixed(1)
          : '0',
    };
  }
}
