import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/brutalism_theme.dart';
import '../../models/employee.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/brutal_widgets.dart';

/// Profil Screen
/// Menampilkan informasi profil karyawan dengan fitur edit
class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PROFIL'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditProfileDialog(context),
          ),
        ],
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          final employee = provider.employee;
          final summary = provider.summary;
          final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

          if (employee == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_off,
                    size: 64,
                    color: isDark 
                        ? BrutalismTheme.lightGrey 
                        : BrutalismTheme.darkGrey,
                  ),
                  const SizedBox(height: BrutalismTheme.spacingM),
                  Text(
                    'Data profil belum tersedia',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark 
                          ? BrutalismTheme.lightGrey 
                          : BrutalismTheme.darkGrey,
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(BrutalismTheme.spacingM),
            child: Column(
              children: [
                // Foto dan Nama
                _buildProfileHeader(context, employee, isDark),

                const SizedBox(height: BrutalismTheme.spacingL),

                // Informasi Detail
                _buildProfileInfo(employee, dateFormat, isDark),

                const SizedBox(height: BrutalismTheme.spacingL),

                // Statistik Kehadiran
                _buildAttendanceStats(summary, isDark),

                // Pesan sukses/error
                if (provider.successMessage != null) ...[
                  const SizedBox(height: BrutalismTheme.spacingM),
                  _buildMessage(
                    provider.successMessage!,
                    BrutalismTheme.successGreen,
                  ),
                ],
                if (provider.errorMessage != null) ...[
                  const SizedBox(height: BrutalismTheme.spacingM),
                  _buildMessage(
                    provider.errorMessage!,
                    BrutalismTheme.errorRed,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  /// Pesan sukses/error
  Widget _buildMessage(String message, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BrutalismTheme.spacingM),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: BrutalismTheme.primaryBlack,
          width: 2,
        ),
      ),
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
        ],
      ),
    );
  }

  /// Dialog edit profil
  void _showEditProfileDialog(BuildContext context) {
    final provider = context.read<AttendanceProvider>();
    final employee = provider.employee;
    
    if (employee == null) return;

    final namaController = TextEditingController(text: employee.nama);
    final jabatanController = TextEditingController(text: employee.jabatan);

    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: const Text(
            'EDIT PROFIL',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(
                  controller: namaController,
                  label: 'NAMA LENGKAP',
                  icon: Icons.person,
                  isDark: isDark,
                ),
                const SizedBox(height: BrutalismTheme.spacingM),
                _buildTextField(
                  controller: jabatanController,
                  label: 'JABATAN',
                  icon: Icons.work,
                  isDark: isDark,
                ),
              ],
            ),
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
                await provider.updateProfile(
                  nama: namaController.text.trim(),
                  jabatan: jabatanController.text.trim(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: BrutalismTheme.accentYellow,
                shape: const RoundedRectangleBorder(),
              ),
              child: const Text(
                'SIMPAN',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: BrutalismTheme.primaryBlack,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Text field untuk dialog edit
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark 
              ? BrutalismTheme.primaryWhite 
              : BrutalismTheme.primaryBlack,
          width: 2,
        ),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark 
              ? BrutalismTheme.primaryWhite 
              : BrutalismTheme.primaryBlack,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 1,
            color: isDark 
                ? BrutalismTheme.lightGrey 
                : BrutalismTheme.darkGrey,
          ),
          prefixIcon: Icon(
            icon,
            color: isDark 
                ? BrutalismTheme.lightGrey 
                : BrutalismTheme.darkGrey,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(BrutalismTheme.spacingM),
        ),
      ),
    );
  }

  /// Header profil dengan foto
  Widget _buildProfileHeader(
    BuildContext context,
    Employee employee,
    bool isDark,
  ) {
    return BrutalCard(
      backgroundColor: BrutalismTheme.primaryBlack,
      child: Column(
        children: [
          // Avatar
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: BrutalismTheme.accentYellow,
              border: Border.all(
                color: BrutalismTheme.primaryWhite,
                width: 4,
              ),
            ),
            child: employee.fotoUrl != null
                ? Image.network(
                    employee.fotoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildAvatarPlaceholder(employee.nama);
                    },
                  )
                : _buildAvatarPlaceholder(employee.nama),
          ),

          const SizedBox(height: BrutalismTheme.spacingM),

          // Nama
          Text(
            employee.nama.toUpperCase(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: BrutalismTheme.primaryWhite,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: BrutalismTheme.spacingXS),

          // Jabatan
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: BrutalismTheme.spacingM,
              vertical: BrutalismTheme.spacingXS,
            ),
            color: BrutalismTheme.accentYellow,
            child: Text(
              employee.jabatan.toUpperCase(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: BrutalismTheme.primaryBlack,
              ),
            ),
          ),

          const SizedBox(height: BrutalismTheme.spacingS),

          // ID Karyawan
          Text(
            'ID: ${employee.id}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: BrutalismTheme.lightGrey,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// Placeholder avatar dengan inisial
  Widget _buildAvatarPlaceholder(String nama) {
    final initials = nama
        .split(' ')
        .take(2)
        .map((word) => word.isNotEmpty ? word[0] : '')
        .join()
        .toUpperCase();

    return Center(
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w900,
          color: BrutalismTheme.primaryBlack,
        ),
      ),
    );
  }

  /// Informasi profil detail
  Widget _buildProfileInfo(
    Employee employee,
    DateFormat dateFormat,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'INFORMASI KARYAWAN',
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
              _buildInfoRow(
                icon: Icons.email,
                label: 'EMAIL',
                value: employee.email,
                isDark: isDark,
              ),
              const Divider(height: BrutalismTheme.spacingL),
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'BERGABUNG SEJAK',
                value: dateFormat.format(employee.tanggalBergabung).toUpperCase(),
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Baris informasi
  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(BrutalismTheme.spacingS),
          color: BrutalismTheme.accentYellow,
          child: Icon(
            icon,
            size: 20,
            color: BrutalismTheme.primaryBlack,
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
              const SizedBox(height: BrutalismTheme.spacingXS),
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

  /// Statistik kehadiran
  Widget _buildAttendanceStats(dynamic summary, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STATISTIK KEHADIRAN BULAN INI',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: isDark ? BrutalismTheme.lightGrey : BrutalismTheme.darkGrey,
          ),
        ),
        const SizedBox(height: BrutalismTheme.spacingS),

        // Progress Bar Kehadiran
        BrutalCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PERSENTASE KEHADIRAN',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? BrutalismTheme.lightGrey
                          : BrutalismTheme.darkGrey,
                    ),
                  ),
                  Text(
                    '${summary.persentaseKehadiran.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? BrutalismTheme.primaryWhite
                          : BrutalismTheme.primaryBlack,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: BrutalismTheme.spacingS),
              // Progress Bar
              Container(
                height: 20,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? BrutalismTheme.primaryBlack
                      : BrutalismTheme.lightGrey,
                  border: Border.all(
                    color: isDark
                        ? BrutalismTheme.primaryWhite
                        : BrutalismTheme.primaryBlack,
                    width: 2,
                  ),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: summary.persentaseKehadiran / 100,
                  child: Container(
                    color: BrutalismTheme.successGreen,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Grid Statistik
        Row(
          children: [
            Expanded(
              child: BrutalStatCard(
                label: 'Total Hadir',
                value: '${summary.totalHadir}',
                accentColor: BrutalismTheme.successGreen,
                icon: Icons.check_circle,
              ),
            ),
            Expanded(
              child: BrutalStatCard(
                label: 'Total Alfa',
                value: '${summary.totalAlfa}',
                accentColor: BrutalismTheme.errorRed,
                icon: Icons.cancel,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: BrutalStatCard(
                label: 'Hari Kerja',
                value: '${summary.totalHariKerja}',
                accentColor: BrutalismTheme.accentBlue,
                icon: Icons.calendar_month,
              ),
            ),
            const Expanded(child: SizedBox()), // Placeholder untuk layout seimbang
          ],
        ),
      ],
    );
  }
}
