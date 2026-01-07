import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/brutalism_theme.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/brutal_widgets.dart';

/// Pengaturan Screen
/// Menampilkan pengaturan aplikasi seperti tema dan informasi aplikasi
class PengaturanScreen extends StatelessWidget {
  const PengaturanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PENGATURAN'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(BrutalismTheme.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pengaturan Tema
            _buildThemeSettings(context, isDark),

            const SizedBox(height: BrutalismTheme.spacingL),

            // Informasi Aplikasi
            _buildAppInfo(isDark),

            const SizedBox(height: BrutalismTheme.spacingL),

            // Reset Data
            _buildDataSettings(context, isDark),

            const SizedBox(height: BrutalismTheme.spacingL),

            // Logout
            _buildLogoutSection(context, isDark),

            const SizedBox(height: BrutalismTheme.spacingL),

            // Credits
            _buildCredits(isDark),
          ],
        ),
      ),
    );
  }

  /// Pengaturan tema
  Widget _buildThemeSettings(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TAMPILAN',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: isDark ? BrutalismTheme.lightGrey : BrutalismTheme.darkGrey,
          ),
        ),
        const SizedBox(height: BrutalismTheme.spacingS),
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return BrutalCard(
              child: Column(
                children: [
                  // Toggle Dark Mode
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(BrutalismTheme.spacingS),
                            color: BrutalismTheme.accentYellow,
                            child: Icon(
                              themeProvider.isDarkMode
                                  ? Icons.dark_mode
                                  : Icons.light_mode,
                              size: 24,
                              color: BrutalismTheme.primaryBlack,
                            ),
                          ),
                          const SizedBox(width: BrutalismTheme.spacingM),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MODE GELAP',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? BrutalismTheme.primaryWhite
                                      : BrutalismTheme.primaryBlack,
                                ),
                              ),
                              Text(
                                themeProvider.isDarkMode
                                    ? 'Aktif'
                                    : 'Tidak Aktif',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? BrutalismTheme.lightGrey
                                      : BrutalismTheme.darkGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Switch Custom
                      GestureDetector(
                        onTap: () => themeProvider.toggleTheme(),
                        child: Container(
                          width: 60,
                          height: 32,
                          decoration: BoxDecoration(
                            color: themeProvider.isDarkMode
                                ? BrutalismTheme.accentYellow
                                : BrutalismTheme.lightGrey,
                            border: Border.all(
                              color: BrutalismTheme.primaryBlack,
                              width: 3,
                            ),
                          ),
                          child: Stack(
                            children: [
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 200),
                                left: themeProvider.isDarkMode ? 28 : 0,
                                child: Container(
                                  width: 26,
                                  height: 26,
                                  color: BrutalismTheme.primaryBlack,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// Informasi aplikasi
  Widget _buildAppInfo(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INFORMASI APLIKASI',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: isDark ? BrutalismTheme.lightGrey : BrutalismTheme.darkGrey,
          ),
        ),
        const SizedBox(height: BrutalismTheme.spacingS),
        BrutalCard(
          child: Column(
            children: [
              _buildInfoItem(
                icon: Icons.apps,
                label: 'NAMA APLIKASI',
                value: AppConstants.appName,
                isDark: isDark,
              ),
              const Divider(height: BrutalismTheme.spacingL),
              _buildInfoItem(
                icon: Icons.info_outline,
                label: 'VERSI',
                value: AppConstants.appVersion,
                isDark: isDark,
              ),
              const Divider(height: BrutalismTheme.spacingL),
              _buildInfoItem(
                icon: Icons.description,
                label: 'DESKRIPSI',
                value: AppConstants.appDescription,
                isDark: isDark,
              ),
              const Divider(height: BrutalismTheme.spacingL),
              _buildInfoItem(
                icon: Icons.palette,
                label: 'TEMA DESAIN',
                value: 'BRUTALISM',
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Item informasi
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(BrutalismTheme.spacingS),
          color: isDark ? BrutalismTheme.darkGrey : BrutalismTheme.lightGrey,
          child: Icon(
            icon,
            size: 20,
            color: isDark
                ? BrutalismTheme.primaryWhite
                : BrutalismTheme.primaryBlack,
          ),
        ),
        const SizedBox(width: BrutalismTheme.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: isDark
                      ? BrutalismTheme.lightGrey
                      : BrutalismTheme.darkGrey,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? BrutalismTheme.primaryWhite
                      : BrutalismTheme.primaryBlack,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Pengaturan data
  Widget _buildDataSettings(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATA',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: isDark ? BrutalismTheme.lightGrey : BrutalismTheme.darkGrey,
          ),
        ),
        const SizedBox(height: BrutalismTheme.spacingS),
        BrutalCard(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(BrutalismTheme.spacingS),
                    color: BrutalismTheme.errorRed,
                    child: const Icon(
                      Icons.delete_forever,
                      size: 20,
                      color: BrutalismTheme.primaryWhite,
                    ),
                  ),
                  const SizedBox(width: BrutalismTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RESET DATA ABSENSI',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? BrutalismTheme.primaryWhite
                                : BrutalismTheme.primaryBlack,
                          ),
                        ),
                        Text(
                          'Menghapus semua riwayat absensi',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? BrutalismTheme.lightGrey
                                : BrutalismTheme.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: BrutalismTheme.spacingM),
              BrutalButton(
                text: 'RESET DATA',
                icon: Icons.warning,
                onPressed: () => _showResetDialog(context),
                backgroundColor: BrutalismTheme.errorRed,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Dialog konfirmasi reset
  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text(
          'KONFIRMASI RESET',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus semua data absensi? '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'BATAL',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: BrutalismTheme.primaryBlack,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AttendanceProvider>().resetAllData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data berhasil direset'),
                  backgroundColor: BrutalismTheme.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BrutalismTheme.errorRed,
              shape: const RoundedRectangleBorder(),
            ),
            child: const Text(
              'RESET',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: BrutalismTheme.primaryWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Section Logout
  Widget _buildLogoutSection(BuildContext context, bool isDark) {
    final authProvider = context.watch<AuthProvider>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AKUN',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: isDark ? BrutalismTheme.lightGrey : BrutalismTheme.darkGrey,
          ),
        ),
        const SizedBox(height: BrutalismTheme.spacingS),
        BrutalCard(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(BrutalismTheme.spacingS),
                    color: BrutalismTheme.accentBlue,
                    child: const Icon(
                      Icons.person,
                      size: 20,
                      color: BrutalismTheme.primaryWhite,
                    ),
                  ),
                  const SizedBox(width: BrutalismTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EMAIL TERDAFTAR',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: isDark
                                ? BrutalismTheme.lightGrey
                                : BrutalismTheme.darkGrey,
                          ),
                        ),
                        Text(
                          authProvider.userEmail,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? BrutalismTheme.primaryWhite
                                : BrutalismTheme.primaryBlack,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: BrutalismTheme.spacingM),
              const Divider(height: 1),
              const SizedBox(height: BrutalismTheme.spacingM),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(BrutalismTheme.spacingS),
                    color: BrutalismTheme.warningOrange,
                    child: const Icon(
                      Icons.logout,
                      size: 20,
                      color: BrutalismTheme.primaryWhite,
                    ),
                  ),
                  const SizedBox(width: BrutalismTheme.spacingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KELUAR DARI APLIKASI',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? BrutalismTheme.primaryWhite
                                : BrutalismTheme.primaryBlack,
                          ),
                        ),
                        Text(
                          'Anda akan diminta login kembali',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? BrutalismTheme.lightGrey
                                : BrutalismTheme.darkGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: BrutalismTheme.spacingM),
              BrutalButton(
                text: 'LOGOUT',
                icon: Icons.logout,
                onPressed: () => _showLogoutDialog(context),
                backgroundColor: BrutalismTheme.warningOrange,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Dialog konfirmasi logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: const Text(
          'KONFIRMASI LOGOUT',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi? '
          'Anda harus login kembali untuk mengakses aplikasi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'BATAL',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: BrutalismTheme.primaryBlack,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              // Clear attendance data saat logout
              await context.read<AttendanceProvider>().clearOnLogout();
              await context.read<AuthProvider>().logout();
              // Navigasi ke login screen
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BrutalismTheme.warningOrange,
              shape: const RoundedRectangleBorder(),
            ),
            child: const Text(
              'LOGOUT',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: BrutalismTheme.primaryWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Credits
  Widget _buildCredits(bool isDark) {
    return BrutalCard(
      backgroundColor: BrutalismTheme.primaryBlack,
      child: Column(
        children: [
          const Text(
            'BRUTALISM DESIGN',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: BrutalismTheme.accentYellow,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: BrutalismTheme.spacingS),
          const Text(
            'Aplikasi absensi dengan desain Brutalism.\n'
            'Karakteristik: kontras tinggi, border tebal,\n'
            'typography besar, minim dekorasi.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: BrutalismTheme.lightGrey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: BrutalismTheme.spacingM),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: BrutalismTheme.spacingM,
              vertical: BrutalismTheme.spacingXS,
            ),
            color: BrutalismTheme.primaryWhite,
            child: const Text(
              '© 2024',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: BrutalismTheme.primaryBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
