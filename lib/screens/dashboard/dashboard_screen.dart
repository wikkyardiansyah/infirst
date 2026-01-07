import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/brutalism_theme.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/brutal_widgets.dart';

/// Dashboard Screen
/// Menampilkan ringkasan kehadiran dan aksi cepat untuk presensi
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Load data saat screen pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().initialize();
      _requestLocationPermission();
    });
  }

  /// Request izin lokasi saat pertama kali masuk dashboard
  Future<void> _requestLocationPermission() async {
    try {
      // Cek apakah layanan lokasi aktif
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Layanan lokasi tidak aktif, tampilkan dialog
        if (mounted) {
          _showLocationServiceDialog();
        }
        return;
      }

      // Cek izin lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // Minta izin lokasi
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Izin ditolak
          if (mounted) {
            _showPermissionDeniedSnackbar();
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Izin ditolak permanen, arahkan ke pengaturan
        if (mounted) {
          _showPermissionPermanentlyDeniedDialog();
        }
        return;
      }

      // Izin diberikan
      debugPrint('Location permission granted');
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
    }
  }

  /// Dialog jika layanan lokasi tidak aktif
  void _showLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Container(
          padding: const EdgeInsets.all(BrutalismTheme.spacingS),
          color: BrutalismTheme.warningOrange,
          child: const Row(
            children: [
              Icon(Icons.location_off, color: BrutalismTheme.primaryBlack),
              SizedBox(width: 8),
              Text(
                'LOKASI NONAKTIF',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: BrutalismTheme.primaryBlack,
                ),
              ),
            ],
          ),
        ),
        content: const Text(
          'Layanan lokasi pada perangkat Anda tidak aktif. Aktifkan layanan lokasi untuk dapat melakukan presensi.',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('NANTI'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Geolocator.openLocationSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BrutalismTheme.accentYellow,
              foregroundColor: BrutalismTheme.primaryBlack,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('AKTIFKAN'),
          ),
        ],
      ),
    );
  }

  /// Snackbar jika izin ditolak
  void _showPermissionDeniedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: BrutalismTheme.errorRed,
        content: const Text(
          'Izin lokasi diperlukan untuk fitur presensi',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        action: SnackBarAction(
          label: 'COBA LAGI',
          textColor: BrutalismTheme.accentYellow,
          onPressed: _requestLocationPermission,
        ),
      ),
    );
  }

  /// Dialog jika izin ditolak permanen
  void _showPermissionPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Container(
          padding: const EdgeInsets.all(BrutalismTheme.spacingS),
          color: BrutalismTheme.errorRed,
          child: const Row(
            children: [
              Icon(Icons.location_disabled, color: BrutalismTheme.primaryWhite),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'IZIN LOKASI DITOLAK',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: BrutalismTheme.primaryWhite,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: const Text(
          'Izin lokasi telah ditolak secara permanen. Buka pengaturan aplikasi untuk mengaktifkan izin lokasi.',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Geolocator.openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BrutalismTheme.accentBlue,
              foregroundColor: BrutalismTheme.primaryWhite,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('BUKA PENGATURAN'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('DASHBOARD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AttendanceProvider>().initialize();
            },
          ),
        ],
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 4,
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.initialize(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(BrutalismTheme.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header - Tanggal Hari Ini
                  _buildDateHeader(context, isDark),

                  const SizedBox(height: BrutalismTheme.spacingL),

                  // Status Presensi Hari Ini
                  _buildTodayStatus(context, provider, isDark),

                  const SizedBox(height: BrutalismTheme.spacingL),

                  // Ringkasan Bulan Ini
                  _buildMonthlySummary(context, provider, isDark),

                  const SizedBox(height: BrutalismTheme.spacingL),

                  // Pesan sukses/error
                  if (provider.successMessage != null)
                    _buildMessage(
                      provider.successMessage!,
                      BrutalismTheme.successGreen,
                    ),
                  if (provider.errorMessage != null)
                    _buildMessage(
                      provider.errorMessage!,
                      BrutalismTheme.errorRed,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Header dengan tanggal hari ini
  Widget _buildDateHeader(BuildContext context, bool isDark) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm');

    return BrutalCard(
      backgroundColor: BrutalismTheme.accentYellow,
      borderColor: BrutalismTheme.primaryBlack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HARI INI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: BrutalismTheme.primaryBlack.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: BrutalismTheme.spacingXS),
          Text(
            dateFormat.format(now).toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: BrutalismTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: BrutalismTheme.spacingS),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 18,
                color: BrutalismTheme.primaryBlack,
              ),
              const SizedBox(width: BrutalismTheme.spacingXS),
              StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) {
                  return Text(
                    timeFormat.format(DateTime.now()),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: BrutalismTheme.primaryBlack,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Status presensi hari ini
  Widget _buildTodayStatus(
    BuildContext context,
    AttendanceProvider provider,
    bool isDark,
  ) {
    final attendance = provider.todayAttendance;
    final timeFormat = DateFormat('HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STATUS HARI INI',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: isDark ? BrutalismTheme.lightGrey : BrutalismTheme.darkGrey,
          ),
        ),
        const SizedBox(height: BrutalismTheme.spacingS),
        BrutalCard(
          child: Row(
            children: [
              // Check-in Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.login,
                          size: 20,
                          color: provider.sudahCheckIn
                              ? BrutalismTheme.successGreen
                              : BrutalismTheme.grey,
                        ),
                        const SizedBox(width: BrutalismTheme.spacingXS),
                        Text(
                          'CHECK-IN',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? BrutalismTheme.lightGrey
                                : BrutalismTheme.darkGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: BrutalismTheme.spacingXS),
                    Text(
                      attendance?.waktuCheckIn != null
                          ? timeFormat.format(attendance!.waktuCheckIn!)
                          : '--:--',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? BrutalismTheme.primaryWhite
                            : BrutalismTheme.primaryBlack,
                      ),
                    ),
                  ],
                ),
              ),
              // Divider
              Container(
                width: 3,
                height: 60,
                color: isDark
                    ? BrutalismTheme.primaryWhite
                    : BrutalismTheme.primaryBlack,
              ),
              // Check-out Status
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: BrutalismTheme.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.logout,
                            size: 20,
                            color: provider.sudahCheckOut
                                ? BrutalismTheme.successGreen
                                : BrutalismTheme.grey,
                          ),
                          const SizedBox(width: BrutalismTheme.spacingXS),
                          Text(
                            'CHECK-OUT',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? BrutalismTheme.lightGrey
                                  : BrutalismTheme.darkGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: BrutalismTheme.spacingXS),
                      Text(
                        attendance?.waktuCheckOut != null
                            ? timeFormat.format(attendance!.waktuCheckOut!)
                            : '--:--',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? BrutalismTheme.primaryWhite
                              : BrutalismTheme.primaryBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Status Badge
        if (attendance != null)
          Padding(
            padding: const EdgeInsets.only(top: BrutalismTheme.spacingS),
            child: Row(
              children: [
                BrutalBadge(
                  text: attendance.status.label,
                  backgroundColor: _getStatusColor(attendance.status),
                ),
                if (attendance.durasiKerjaFormatted != '-') ...[
                  const SizedBox(width: BrutalismTheme.spacingS),
                  BrutalBadge(
                    text: 'Durasi: ${attendance.durasiKerjaFormatted}',
                    backgroundColor: BrutalismTheme.accentBlue,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  /// Ringkasan kehadiran bulan ini
  Widget _buildMonthlySummary(
    BuildContext context,
    AttendanceProvider provider,
    bool isDark,
  ) {
    final summary = provider.summary;
    final now = DateTime.now();
    final monthFormat = DateFormat('MMMM yyyy', 'id_ID');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RINGKASAN ${monthFormat.format(now).toUpperCase()}',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: isDark ? BrutalismTheme.lightGrey : BrutalismTheme.darkGrey,
          ),
        ),
        const SizedBox(height: BrutalismTheme.spacingS),
        Row(
          children: [
            Expanded(
              child: BrutalStatCard(
                label: 'Hadir',
                value: '${summary.totalHadir}',
                accentColor: BrutalismTheme.successGreen,
                icon: Icons.check_circle_outline,
              ),
            ),
            Expanded(
              child: BrutalStatCard(
                label: 'Alfa',
                value: '${summary.totalAlfa}',
                accentColor: BrutalismTheme.errorRed,
                icon: Icons.cancel_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Widget untuk menampilkan pesan
  Widget _buildMessage(String message, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: BrutalismTheme.spacingM),
      child: BrutalCard(
        backgroundColor: color,
        borderColor: BrutalismTheme.primaryBlack,
        child: Row(
          children: [
            Icon(
              color == BrutalismTheme.successGreen
                  ? Icons.check_circle
                  : Icons.error,
              color: BrutalismTheme.primaryWhite,
            ),
            const SizedBox(width: BrutalismTheme.spacingS),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: BrutalismTheme.primaryWhite,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.close,
                color: BrutalismTheme.primaryWhite,
              ),
              onPressed: () {
                context.read<AttendanceProvider>().clearMessages();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Mendapatkan warna berdasarkan status
  Color _getStatusColor(dynamic status) {
    switch (status.toString().split('.').last) {
      case 'hadir':
        return BrutalismTheme.successGreen;
      case 'izin':
        return BrutalismTheme.warningOrange;
      case 'alfa':
        return BrutalismTheme.errorRed;
      case 'terlambat':
        return BrutalismTheme.accentYellow;
      default:
        return BrutalismTheme.grey;
    }
  }
}
