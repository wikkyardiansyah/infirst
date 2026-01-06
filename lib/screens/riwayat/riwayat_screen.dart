import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/brutalism_theme.dart';
import '../../models/attendance.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/brutal_widgets.dart';

/// Riwayat Screen
/// Menampilkan daftar riwayat presensi dengan filter berdasarkan bulan
class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().loadAttendanceHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RIWAYAT'),
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // Filter Bulan
              _buildMonthFilter(context, provider, isDark),

              const Divider(height: 0),

              // Daftar Riwayat
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.attendanceHistory.isEmpty
                        ? _buildEmptyState(isDark)
                        : _buildHistoryList(provider, isDark),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Filter bulan
  Widget _buildMonthFilter(
    BuildContext context,
    AttendanceProvider provider,
    bool isDark,
  ) {
    final monthFormat = DateFormat('MMMM yyyy', 'id_ID');
    final selectedDate = provider.selectedFilterDate;

    return Container(
      padding: const EdgeInsets.all(BrutalismTheme.spacingM),
      color: isDark ? BrutalismTheme.darkGrey : BrutalismTheme.lightGrey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Tombol Bulan Sebelumnya
          IconButton(
            onPressed: () {
              final newDate = DateTime(
                selectedDate.year,
                selectedDate.month - 1,
              );
              provider.filterByMonth(newDate);
            },
            icon: Icon(
              Icons.chevron_left,
              size: 32,
              color: isDark
                  ? BrutalismTheme.primaryWhite
                  : BrutalismTheme.primaryBlack,
            ),
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? BrutalismTheme.primaryBlack
                  : BrutalismTheme.primaryWhite,
              shape: const RoundedRectangleBorder(),
              side: BorderSide(
                color: isDark
                    ? BrutalismTheme.primaryWhite
                    : BrutalismTheme.primaryBlack,
                width: 2,
              ),
            ),
          ),

          // Label Bulan
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: BrutalismTheme.spacingL,
              vertical: BrutalismTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: BrutalismTheme.accentYellow,
              border: Border.all(
                color: BrutalismTheme.primaryBlack,
                width: 3,
              ),
            ),
            child: Text(
              monthFormat.format(selectedDate).toUpperCase(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: BrutalismTheme.primaryBlack,
              ),
            ),
          ),

          // Tombol Bulan Berikutnya
          IconButton(
            onPressed: () {
              final newDate = DateTime(
                selectedDate.year,
                selectedDate.month + 1,
              );
              provider.filterByMonth(newDate);
            },
            icon: Icon(
              Icons.chevron_right,
              size: 32,
              color: isDark
                  ? BrutalismTheme.primaryWhite
                  : BrutalismTheme.primaryBlack,
            ),
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? BrutalismTheme.primaryBlack
                  : BrutalismTheme.primaryWhite,
              shape: const RoundedRectangleBorder(),
              side: BorderSide(
                color: isDark
                    ? BrutalismTheme.primaryWhite
                    : BrutalismTheme.primaryBlack,
                width: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// State kosong
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: isDark ? BrutalismTheme.grey : BrutalismTheme.lightGrey,
          ),
          const SizedBox(height: BrutalismTheme.spacingM),
          Text(
            'BELUM ADA RIWAYAT',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isDark ? BrutalismTheme.grey : BrutalismTheme.darkGrey,
            ),
          ),
          const SizedBox(height: BrutalismTheme.spacingS),
          Text(
            'Riwayat presensi akan muncul di sini',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? BrutalismTheme.grey : BrutalismTheme.darkGrey,
            ),
          ),
        ],
      ),
    );
  }

  /// Daftar riwayat
  Widget _buildHistoryList(AttendanceProvider provider, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(BrutalismTheme.spacingM),
      itemCount: provider.attendanceHistory.length,
      itemBuilder: (context, index) {
        final attendance = provider.attendanceHistory[index];
        return _buildHistoryItem(attendance, isDark);
      },
    );
  }

  /// Item riwayat
  Widget _buildHistoryItem(Attendance attendance, bool isDark) {
    final dateFormat = DateFormat('EEEE, dd MMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm');

    return BrutalCard(
      margin: const EdgeInsets.only(bottom: BrutalismTheme.spacingS),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tanggal dan Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateFormat.format(attendance.tanggal).toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? BrutalismTheme.primaryWhite
                      : BrutalismTheme.primaryBlack,
                ),
              ),
              BrutalBadge(
                text: attendance.status.label,
                backgroundColor: _getStatusColor(attendance.status),
              ),
            ],
          ),

          const Divider(height: BrutalismTheme.spacingL),

          // Waktu Check-in dan Check-out
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.login,
                      size: 18,
                      color: BrutalismTheme.successGreen,
                    ),
                    const SizedBox(width: BrutalismTheme.spacingXS),
                    Text(
                      'IN: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? BrutalismTheme.lightGrey
                            : BrutalismTheme.darkGrey,
                      ),
                    ),
                    Text(
                      attendance.waktuCheckIn != null
                          ? timeFormat.format(attendance.waktuCheckIn!)
                          : '--:--',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? BrutalismTheme.primaryWhite
                            : BrutalismTheme.primaryBlack,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    const Icon(
                      Icons.logout,
                      size: 18,
                      color: BrutalismTheme.errorRed,
                    ),
                    const SizedBox(width: BrutalismTheme.spacingXS),
                    Text(
                      'OUT: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? BrutalismTheme.lightGrey
                            : BrutalismTheme.darkGrey,
                      ),
                    ),
                    Text(
                      attendance.waktuCheckOut != null
                          ? timeFormat.format(attendance.waktuCheckOut!)
                          : '--:--',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? BrutalismTheme.primaryWhite
                            : BrutalismTheme.primaryBlack,
                      ),
                    ),
                  ],
                ),
              ),
              // Durasi
              if (attendance.durasiKerjaFormatted != '-')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: BrutalismTheme.spacingS,
                    vertical: BrutalismTheme.spacingXS,
                  ),
                  color: BrutalismTheme.accentBlue,
                  child: Text(
                    attendance.durasiKerjaFormatted,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: BrutalismTheme.primaryWhite,
                    ),
                  ),
                ),
            ],
          ),

          // Keterangan (jika ada)
          if (attendance.keterangan != null &&
              attendance.keterangan!.isNotEmpty) ...[
            const SizedBox(height: BrutalismTheme.spacingS),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(BrutalismTheme.spacingS),
              color: isDark
                  ? BrutalismTheme.primaryBlack
                  : BrutalismTheme.lightGrey,
              child: Text(
                'Keterangan: ${attendance.keterangan}',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: isDark
                      ? BrutalismTheme.lightGrey
                      : BrutalismTheme.darkGrey,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Mendapatkan warna berdasarkan status
  Color _getStatusColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.hadir:
        return BrutalismTheme.successGreen;
      case AttendanceStatus.alfa:
        return BrutalismTheme.errorRed;
    }
  }
}
