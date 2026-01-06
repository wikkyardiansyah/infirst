import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/admin_service.dart';

/// Provider untuk mengelola autentikasi pengguna
/// 
/// Fungsi:
/// - Login dengan email
/// - Logout dengan konfirmasi
/// - Menyimpan status login ke local storage
/// - Mengelola status landing page
class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _userEmail = '';
  bool _isLoading = false;
  bool _hasSeenLanding = false;
  bool _isInitialized = false;
  bool _isAdmin = false;

  // Keys untuk SharedPreferences
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserEmail = 'user_email';
  static const String _keyHasSeenLanding = 'has_seen_landing';
  static const String _keyIsAdmin = 'is_admin';

  bool get isLoggedIn => _isLoggedIn;
  String get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  bool get hasSeenLanding => _hasSeenLanding;
  bool get isInitialized => _isInitialized;
  bool get isAdmin => _isAdmin;

  /// Inisialisasi status login dari local storage
  Future<void> initialize() async {
    // Hindari inisialisasi ganda
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      _userEmail = prefs.getString(_keyUserEmail) ?? '';
      _hasSeenLanding = prefs.getBool(_keyHasSeenLanding) ?? false;
      _isAdmin = prefs.getBool(_keyIsAdmin) ?? false;
    } catch (e) {
      // Jika gagal, set default values
      _isLoggedIn = false;
      _userEmail = '';
      _hasSeenLanding = false;
      _isAdmin = false;
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Tandai sudah melihat landing page
  Future<void> markLandingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenLanding, true);
    _hasSeenLanding = true;
    notifyListeners();
  }

  /// Login dengan email dan password
  Future<LoginResult> login(String email, String password) async {
    if (email.isEmpty || !_isValidEmail(email)) {
      return LoginResult(success: false, message: 'Format email tidak valid');
    }

    if (password.isEmpty) {
      return LoginResult(success: false, message: 'Password tidak boleh kosong');
    }

    if (password.length < 6) {
      return LoginResult(success: false, message: 'Password minimal 6 karakter');
    }

    _isLoading = true;
    notifyListeners();

    // Simulasi delay untuk proses login
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final adminService = AdminService();
      
      // Cek apakah login sebagai admin
      final isAdminLogin = await adminService.validateAdminLogin(email, password);
      
      if (isAdminLogin) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_keyIsLoggedIn, true);
        await prefs.setString(_keyUserEmail, email);
        await prefs.setBool(_keyIsAdmin, true);

        _isLoggedIn = true;
        _userEmail = email;
        _isAdmin = true;
        _isLoading = false;
        notifyListeners();

        return LoginResult(success: true, message: 'Login admin berhasil', isAdmin: true);
      }
      
      // Validasi kredensial karyawan
      final employee = await adminService.validateEmployeeLogin(email, password);
      
      if (employee == null) {
        _isLoading = false;
        notifyListeners();
        return LoginResult(
          success: false, 
          message: 'Email atau password salah, atau akun tidak aktif',
        );
      }
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUserEmail, email);
      await prefs.setBool(_keyIsAdmin, false);

      _isLoggedIn = true;
      _userEmail = email;
      _isAdmin = false;
      _isLoading = false;
      notifyListeners();

      return LoginResult(success: true, message: 'Login berhasil');
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return LoginResult(success: false, message: 'Terjadi kesalahan, coba lagi');
    }
  }

  /// Logout pengguna
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyUserEmail);
    await prefs.setBool(_keyIsAdmin, false);

    _isLoggedIn = false;
    _userEmail = '';
    _isAdmin = false;
    _isLoading = false;
    notifyListeners();
  }

  /// Validasi format email
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

/// Result class untuk login
class LoginResult {
  final bool success;
  final String message;
  final bool isAdmin;

  LoginResult({required this.success, required this.message, this.isAdmin = false});
}
