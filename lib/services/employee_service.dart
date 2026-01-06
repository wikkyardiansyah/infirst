import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/employee.dart';
import '../models/registered_employee.dart';

/// Service untuk mengelola data karyawan
/// Menggunakan SharedPreferences untuk penyimpanan lokal
class EmployeeService {
  static const String _employeeKey = 'employee_profile';
  static const String _registeredEmployeesKey = 'registered_employees';

  /// Menyimpan data karyawan
  Future<void> saveEmployee(Employee employee) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_employeeKey, jsonEncode(employee.toJson()));
  }

  /// Mengambil data karyawan
  Future<Employee?> getEmployee() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_employeeKey);

    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      return Employee.fromJson(jsonDecode(jsonString));
    } catch (e) {
      return null;
    }
  }

  /// Mengambil data RegisteredEmployee berdasarkan email
  Future<RegisteredEmployee?> _getRegisteredEmployee(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_registeredEmployeesKey);

    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final employees = jsonList
          .map((json) => RegisteredEmployee.fromJson(json))
          .toList();
      
      return employees.firstWhere(
        (e) => e.email == email,
        orElse: () => throw Exception('Not found'),
      );
    } catch (e) {
      return null;
    }
  }

  /// Mengambil atau membuat karyawan baru berdasarkan email
  Future<Employee> getOrCreateEmployee(String email) async {
    final existing = await getEmployee();
    
    // Jika sudah ada dan email sama, gunakan yang ada
    if (existing != null && existing.email == email) {
      return existing;
    }

    // Cari data dari RegisteredEmployee yang sudah didaftarkan admin
    final registeredEmployee = await _getRegisteredEmployee(email);

    // Buat profil karyawan baru dengan data dari RegisteredEmployee
    final newEmployee = Employee(
      id: registeredEmployee?.id ?? 'EMP_${DateTime.now().millisecondsSinceEpoch}',
      nama: registeredEmployee?.nama ?? _extractNameFromEmail(email),
      jabatan: registeredEmployee?.jabatan ?? 'Karyawan',
      email: email,
      tanggalBergabung: registeredEmployee?.tanggalDaftar ?? DateTime.now(),
    );

    await saveEmployee(newEmployee);
    return newEmployee;
  }

  /// Update profil karyawan
  Future<Employee> updateEmployee({
    required Employee currentEmployee,
    String? nama,
    String? jabatan,
  }) async {
    final updated = currentEmployee.copyWith(
      nama: nama,
      jabatan: jabatan,
    );
    await saveEmployee(updated);
    return updated;
  }

  /// Hapus data karyawan (untuk logout)
  Future<void> clearEmployee() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_employeeKey);
  }

  /// Extract nama dari email
  String _extractNameFromEmail(String email) {
    final localPart = email.split('@').first;
    // Ubah format seperti "john.doe" atau "john_doe" menjadi "John Doe"
    final parts = localPart.split(RegExp(r'[._-]'));
    return parts
        .map((part) => part.isNotEmpty
            ? '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }
}
