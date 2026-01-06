import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
    });
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
