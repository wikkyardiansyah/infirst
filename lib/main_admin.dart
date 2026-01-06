import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

// Core
import 'core/theme/brutalism_theme.dart';

// Providers
import 'providers/admin_provider.dart';

// Screens
import 'screens/admin/admin_dashboard_screen.dart';

/// Entry point khusus untuk Admin Web Dashboard
/// Jalankan dengan: flutter run -d chrome -t lib/main_admin.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi format tanggal Indonesia
  await initializeDateFormatting('id_ID', null);
  
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'INFIRST Admin Panel',
        debugShowCheckedModeBanner: false,
        theme: BrutalismTheme.lightTheme,
        darkTheme: BrutalismTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const AdminLoginScreen(),
      ),
    );
  }
}
