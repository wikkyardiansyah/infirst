import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// Core
import 'core/theme/brutalism_theme.dart';

// Providers
import 'providers/attendance_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/admin_provider.dart';

// Screens
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/landing/landing_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/presensi/presensi_screen.dart';
import 'screens/riwayat/riwayat_screen.dart';
import 'screens/profil/profil_screen.dart';
import 'screens/pengaturan/pengaturan_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';

/// Aplikasi Presensi Karyawan dengan Tema Brutalism
/// 
/// Konsep Aplikasi:
/// Aplikasi presensi karyawan sederhana yang memungkinkan karyawan untuk:
/// - Melakukan check-in dan check-out harian
/// - Melihat riwayat presensi
/// - Mengajukan izin
/// - Melihat statistik kehadiran
/// 
/// Arsitektur:
/// - Clean Architecture sederhana dengan pemisahan UI, Logic, dan Data
/// - State Management menggunakan Provider
/// - Local Storage menggunakan SharedPreferences
/// 
/// Tema Desain: BRUTALISM
/// - Warna solid dan kontras tinggi (hitam, putih, kuning)
/// - Border tebal tanpa rounded corners
/// - Typography besar dan tegas
/// - Minim dekorasi dan shadow
/// - Animasi minimal
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi format tanggal Indonesia
  await initializeDateFormatting('id_ID', null);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider untuk mengelola tema aplikasi
        ChangeNotifierProvider(create: (_) => ThemeProvider()..initialize()),

        // Provider untuk mengelola autentikasi
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),

        // Provider untuk mengelola data presensi
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),

        // Provider untuk mengelola admin dashboard
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, child) {
          // Determine which screen to show
          Widget homeScreen;
          if (!authProvider.isInitialized) {
            homeScreen = const _LoadingScreen();
          } else if (!authProvider.isLoggedIn) {
            if (!authProvider.hasSeenLanding) {
              homeScreen = const LandingScreen();
            } else {
              homeScreen = const LoginScreen();
            }
          } else if (authProvider.isAdmin) {
            // Admin sudah login - langsung ke admin dashboard
            homeScreen = const AdminDashboardScreen();
          } else {
            // Karyawan sudah login - langsung ke main navigation
            homeScreen = const MainNavigationWrapper();
          }
          
          return MaterialApp(
            title: 'INFIRST',
            debugShowCheckedModeBanner: false,
            
            // Tema Brutalism
            theme: BrutalismTheme.lightTheme,
            darkTheme: BrutalismTheme.darkTheme,
            themeMode: themeProvider.themeMode,

            home: homeScreen,
            
            // Named routes untuk navigasi setelah login
            routes: {
              '/login': (context) => const LoginScreen(),
              '/main': (context) => const MainNavigationWrapper(),
              '/admin': (context) => const AdminDashboardScreen(),
            },
          );
        },
      ),
    );
  }
}

/// Loading Screen
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark 
          ? BrutalismTheme.primaryBlack 
          : BrutalismTheme.primaryWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(BrutalismTheme.spacingL),
              decoration: BoxDecoration(
                color: BrutalismTheme.accentYellow,
                border: Border.all(
                  color: BrutalismTheme.primaryBlack,
                  width: BrutalismTheme.borderWidth,
                ),
              ),
              child: const Icon(
                Icons.fingerprint,
                size: 60,
                color: BrutalismTheme.primaryBlack,
              ),
            ),
            const SizedBox(height: BrutalismTheme.spacingL),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                BrutalismTheme.accentYellow,
              ),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}

/// Wrapper untuk MainNavigation yang inisialisasi AttendanceProvider
class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  bool _attendanceInitialized = false;

  @override
  void initState() {
    super.initState();
    _initAttendance();
  }

  void _initAttendance() {
    if (_attendanceInitialized) return;
    _attendanceInitialized = true;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      context.read<AttendanceProvider>().initializeWithEmail(
        authProvider.userEmail,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MainNavigationScreen();
  }
}

/// Screen utama dengan Bottom Navigation
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Daftar screen
  final List<Widget> _screens = const [
    DashboardScreen(),
    PresensiScreen(),
    RiwayatScreen(),
    ProfilScreen(),
    PengaturanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark
                  ? BrutalismTheme.primaryWhite
                  : BrutalismTheme.primaryBlack,
              width: 3,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              activeIcon: Icon(Icons.dashboard, size: 28),
              label: 'DASHBOARD',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fingerprint),
              activeIcon: Icon(Icons.fingerprint, size: 28),
              label: 'ABSENSI',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              activeIcon: Icon(Icons.history, size: 28),
              label: 'RIWAYAT',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person, size: 28),
              label: 'PROFIL',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings, size: 28),
              label: 'PENGATURAN',
            ),
          ],
        ),
      ),
    );
  }
}