import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/brutalism_theme.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/brutal_widgets.dart';
import 'selfie_camera_screen.dart';

/// Presensi Screen
/// Menampilkan halaman untuk melakukan check-in/check-out
class PresensiScreen extends StatefulWidget {
  const PresensiScreen({super.key});

  @override
  State<PresensiScreen> createState() => _PresensiScreenState();
}

class _PresensiScreenState extends State<PresensiScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('INFIRST'),
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(BrutalismTheme.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Jam Saat Ini
                _buildCurrentTime(isDark),

                const SizedBox(height: BrutalismTheme.spacingXL),

                // Status Hari Ini
                _buildTodayStatus(provider, isDark),

                const SizedBox(height: BrutalismTheme.spacingXL),

                // Lokasi Check-in/Check-out
                _buildLocationInfo(provider, isDark),

                const SizedBox(height: BrutalismTheme.spacingXL),

                // Tombol Check-in/Check-out
                _buildActionButtons(context, provider),

                // Pesan
                if (provider.successMessage != null ||
                    provider.errorMessage != null)
                  _buildMessageCard(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Jam saat ini
  Widget _buildCurrentTime(bool isDark) {
    return BrutalCard(
      backgroundColor: BrutalismTheme.primaryBlack,
      borderColor: BrutalismTheme.primaryBlack,
      padding: const EdgeInsets.all(BrutalismTheme.spacingXL),
      child: Center(
        child: StreamBuilder(
          stream: Stream.periodic(const Duration(seconds: 1)),
          builder: (context, snapshot) {
            final now = DateTime.now();
            final timeFormat = DateFormat('HH:mm:ss');
            final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');

            return Column(
              children: [
                Text(
                  timeFormat.format(now),
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: BrutalismTheme.accentYellow,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: BrutalismTheme.spacingS),
                Text(
                  dateFormat.format(now).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: BrutalismTheme.primaryWhite,
                    letterSpacing: 1,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Status hari ini
  Widget _buildTodayStatus(AttendanceProvider provider, bool isDark) {
    final attendance = provider.todayAttendance;
    final timeFormat = DateFormat('HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STATUS PRESENSI HARI INI',
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
            // Check-in
            Expanded(
              child: BrutalCard(
                backgroundColor: provider.sudahCheckIn
                    ? BrutalismTheme.successGreen
                    : (isDark
                        ? BrutalismTheme.darkGrey
                        : BrutalismTheme.lightGrey),
                onTap: attendance?.fotoCheckIn != null
                    ? () => _showPhotoDialog(
                          context,
                          attendance!.fotoCheckIn!,
                          'Foto Check-In',
                          attendance.waktuCheckIn!,
                        )
                    : null,
                child: Column(
                  children: [
                    // Tampilkan ikon kamera jika ada foto
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.login,
                          size: 32,
                          color: provider.sudahCheckIn
                              ? BrutalismTheme.primaryWhite
                              : BrutalismTheme.grey,
                        ),
                        if (attendance?.fotoCheckIn != null)
                          Positioned(
                            right: -8,
                            bottom: -4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: BrutalismTheme.accentYellow,
                                border: Border.all(
                                  color: BrutalismTheme.primaryBlack,
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 12,
                                color: BrutalismTheme.primaryBlack,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: BrutalismTheme.spacingS),
                    Text(
                      'CHECK-IN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: provider.sudahCheckIn
                            ? BrutalismTheme.primaryWhite
                            : BrutalismTheme.grey,
                      ),
                    ),
                    const SizedBox(height: BrutalismTheme.spacingXS),
                    Text(
                      attendance?.waktuCheckIn != null
                          ? timeFormat.format(attendance!.waktuCheckIn!)
                          : '--:--',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: provider.sudahCheckIn
                            ? BrutalismTheme.primaryWhite
                            : BrutalismTheme.grey,
                      ),
                    ),
                    // Hint tap untuk lihat foto
                    if (attendance?.fotoCheckIn != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Tap untuk lihat foto',
                          style: TextStyle(
                            fontSize: 10,
                            color: BrutalismTheme.primaryWhite.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: BrutalismTheme.spacingS),
            // Check-out
            Expanded(
              child: BrutalCard(
                backgroundColor: provider.sudahCheckOut
                    ? BrutalismTheme.errorRed
                    : (isDark
                        ? BrutalismTheme.darkGrey
                        : BrutalismTheme.lightGrey),
                onTap: attendance?.fotoCheckOut != null
                    ? () => _showPhotoDialog(
                          context,
                          attendance!.fotoCheckOut!,
                          'Foto Check-Out',
                          attendance.waktuCheckOut!,
                        )
                    : null,
                child: Column(
                  children: [
                    // Tampilkan ikon kamera jika ada foto
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.logout,
                          size: 32,
                          color: provider.sudahCheckOut
                              ? BrutalismTheme.primaryWhite
                              : BrutalismTheme.grey,
                        ),
                        if (attendance?.fotoCheckOut != null)
                          Positioned(
                            right: -8,
                            bottom: -4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: BrutalismTheme.accentYellow,
                                border: Border.all(
                                  color: BrutalismTheme.primaryBlack,
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 12,
                                color: BrutalismTheme.primaryBlack,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: BrutalismTheme.spacingS),
                    Text(
                      'CHECK-OUT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: provider.sudahCheckOut
                            ? BrutalismTheme.primaryWhite
                            : BrutalismTheme.grey,
                      ),
                    ),
                    const SizedBox(height: BrutalismTheme.spacingXS),
                    Text(
                      attendance?.waktuCheckOut != null
                          ? timeFormat.format(attendance!.waktuCheckOut!)
                          : '--:--',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: provider.sudahCheckOut
                            ? BrutalismTheme.primaryWhite
                            : BrutalismTheme.grey,
                      ),
                    ),
                    // Hint tap untuk lihat foto
                    if (attendance?.fotoCheckOut != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Tap untuk lihat foto',
                          style: TextStyle(
                            fontSize: 10,
                            color: BrutalismTheme.primaryWhite.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Tombol aksi
  Widget _buildActionButtons(
    BuildContext context,
    AttendanceProvider provider,
  ) {
    return Column(
      children: [
        // Tombol Check-in
        BrutalButton(
          text: provider.sudahCheckIn ? 'SUDAH CHECK-IN' : 'CHECK-IN SEKARANG',
          icon: Icons.login,
          onPressed: provider.sudahCheckIn
              ? null
              : () async {
                  await _handleCheckIn(context, provider);
                },
          backgroundColor: provider.sudahCheckIn
              ? BrutalismTheme.grey
              : BrutalismTheme.successGreen,
          isFullWidth: true,
          isLoading: provider.isLoading,
        ),

        const SizedBox(height: BrutalismTheme.spacingM),

        // Tombol Check-out
        BrutalButton(
          text: provider.sudahCheckOut
              ? 'SUDAH CHECK-OUT'
              : 'CHECK-OUT SEKARANG',
          icon: Icons.logout,
          onPressed: (!provider.sudahCheckIn || provider.sudahCheckOut)
              ? null
              : () async {
                  await _handleCheckOut(context, provider);
                },
          backgroundColor: (!provider.sudahCheckIn || provider.sudahCheckOut)
              ? BrutalismTheme.grey
              : BrutalismTheme.errorRed,
          isFullWidth: true,
          isLoading: provider.isLoading,
        ),
      ],
    );
  }

  /// Handle check-in dengan selfie
  Future<void> _handleCheckIn(
    BuildContext context,
    AttendanceProvider provider,
  ) async {
    // Buka kamera untuk selfie
    final String? fotoPath = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const SelfieCameraScreen(
          presensiType: PresensiType.checkIn,
        ),
      ),
    );

    // Jika foto berhasil diambil, lakukan check-in
    if (fotoPath != null) {
      await provider.checkIn(fotoPath: fotoPath);
    }
  }

  /// Handle check-out dengan selfie
  Future<void> _handleCheckOut(
    BuildContext context,
    AttendanceProvider provider,
  ) async {
    // Buka kamera untuk selfie
    final String? fotoPath = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const SelfieCameraScreen(
          presensiType: PresensiType.checkOut,
        ),
      ),
    );

    // Jika foto berhasil diambil, lakukan check-out
    if (fotoPath != null) {
      await provider.checkOut(fotoPath: fotoPath);
    }
  }

  /// Widget untuk menampilkan informasi lokasi GPS dengan Map
  Widget _buildLocationInfo(AttendanceProvider provider, bool isDark) {
    final attendance = provider.todayAttendance;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LOKASI PRESENSI',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: isDark ? BrutalismTheme.lightGrey : BrutalismTheme.darkGrey,
          ),
        ),
        const SizedBox(height: BrutalismTheme.spacingS),
        
        // Lokasi Check-in
        _buildLocationCard(
          title: 'LOKASI CHECK-IN',
          alamat: attendance?.alamatCheckIn,
          latitude: attendance?.latitudeCheckIn,
          longitude: attendance?.longitudeCheckIn,
          isActive: provider.sudahCheckIn,
          activeColor: BrutalismTheme.successGreen,
          isDark: isDark,
          placeholder: 'Belum check-in',
        ),
        
        const SizedBox(height: BrutalismTheme.spacingM),
        
        // Lokasi Check-out
        _buildLocationCard(
          title: 'LOKASI CHECK-OUT',
          alamat: attendance?.alamatCheckOut,
          latitude: attendance?.latitudeCheckOut,
          longitude: attendance?.longitudeCheckOut,
          isActive: provider.sudahCheckOut,
          activeColor: BrutalismTheme.errorRed,
          isDark: isDark,
          placeholder: 'Belum check-out',
        ),
      ],
    );
  }

  /// Widget kartu lokasi dengan peta
  Widget _buildLocationCard({
    required String title,
    required String? alamat,
    required double? latitude,
    required double? longitude,
    required bool isActive,
    required Color activeColor,
    required bool isDark,
    required String placeholder,
  }) {
    final hasLocation = latitude != null && longitude != null;
    
    return BrutalCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                color: isActive ? activeColor : BrutalismTheme.grey,
                child: const Icon(
                  Icons.location_on,
                  color: BrutalismTheme.primaryWhite,
                  size: 20,
                ),
              ),
              const SizedBox(width: BrutalismTheme.spacingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark 
                            ? BrutalismTheme.lightGrey 
                            : BrutalismTheme.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alamat ?? (isActive ? 'Lokasi tidak tersedia' : placeholder),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark 
                            ? BrutalismTheme.primaryWhite 
                            : BrutalismTheme.primaryBlack,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Map jika ada lokasi
          if (hasLocation) ...[
            const SizedBox(height: BrutalismTheme.spacingM),
            Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark 
                      ? BrutalismTheme.primaryWhite 
                      : BrutalismTheme.primaryBlack,
                  width: 2,
                ),
              ),
              child: ClipRect(
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(latitude, longitude),
                    initialZoom: 16,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.none, // Disable interactions for preview
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.infirst',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(latitude, longitude),
                          width: 40,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              color: activeColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: BrutalismTheme.primaryWhite,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: BrutalismTheme.primaryBlack.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(2, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person,
                              color: BrutalismTheme.primaryWhite,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: BrutalismTheme.spacingS),
            // Tombol buka di maps
            GestureDetector(
              onTap: () => _openInMaps(latitude, longitude),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BrutalismTheme.spacingM,
                  vertical: BrutalismTheme.spacingS,
                ),
                color: activeColor,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.open_in_new,
                      color: BrutalismTheme.primaryWhite,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'BUKA DI MAPS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: BrutalismTheme.primaryWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Buka lokasi di aplikasi maps eksternal
  void _openInMaps(double latitude, double longitude) {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    // Untuk web, bisa langsung buka URL
    if (kIsWeb) {
      // ignore: avoid_print
      print('Open URL: $url');
      // Implementasi untuk web bisa menggunakan url_launcher
    }
  }

  /// Kartu pesan
  Widget _buildMessageCard(AttendanceProvider provider) {
    final isSuccess = provider.successMessage != null;
    final message = isSuccess ? provider.successMessage! : provider.errorMessage!;
    final color = isSuccess ? BrutalismTheme.successGreen : BrutalismTheme.errorRed;

    return Padding(
      padding: const EdgeInsets.only(top: BrutalismTheme.spacingM),
      child: BrutalCard(
        backgroundColor: color,
        borderColor: BrutalismTheme.primaryBlack,
        child: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
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
                provider.clearMessages();
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Menampilkan dialog foto selfie
  void _showPhotoDialog(
    BuildContext context,
    String fotoPath,
    String title,
    DateTime waktu,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeFormat = DateFormat('HH:mm:ss');
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: const RoundedRectangleBorder(),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? BrutalismTheme.darkGrey
                : BrutalismTheme.primaryWhite,
            border: Border.all(
              color: isDark
                  ? BrutalismTheme.primaryWhite
                  : BrutalismTheme.primaryBlack,
              width: BrutalismTheme.borderWidth,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(BrutalismTheme.spacingM),
                color: BrutalismTheme.primaryBlack,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: const TextStyle(
                        color: BrutalismTheme.primaryWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(
                        Icons.close,
                        color: BrutalismTheme.primaryWhite,
                      ),
                    ),
                  ],
                ),
              ),
              // Foto
              AspectRatio(
                aspectRatio: 1,
                child: _buildPhotoWidget(fotoPath),
              ),
              // Info waktu
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(BrutalismTheme.spacingM),
                color: BrutalismTheme.accentYellow,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeFormat.format(waktu),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: BrutalismTheme.primaryBlack,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(waktu).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: BrutalismTheme.primaryBlack,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget untuk menampilkan foto yang mendukung Web dan Desktop
  Widget _buildPhotoWidget(String fotoPath) {
    // Untuk Web, gunakan Image.network jika path adalah URL
    if (kIsWeb) {
      // Di Web, fotoPath bisa berupa blob URL
      if (fotoPath.startsWith('blob:') || fotoPath.startsWith('http')) {
        return Image.network(
          fotoPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPhotoError(),
        );
      }
      // Jika bukan URL, tampilkan placeholder
      return _buildPhotoError();
    }

    // Untuk Desktop/Mobile, gunakan Image.file
    final file = File(fotoPath);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
      );
    }

    return _buildPhotoError();
  }

  /// Widget error untuk foto tidak tersedia
  Widget _buildPhotoError() {
    return Container(
      color: BrutalismTheme.grey,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              size: 48,
              color: BrutalismTheme.primaryWhite,
            ),
            SizedBox(height: 8),
            Text(
              'Foto tidak tersedia',
              style: TextStyle(
                color: BrutalismTheme.primaryWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
