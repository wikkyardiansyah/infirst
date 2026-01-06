import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/theme/brutalism_theme.dart';
import '../../widgets/brutal_widgets.dart';

/// Tipe presensi untuk membedakan check-in dan check-out
enum PresensiType {
  checkIn,
  checkOut,
}

/// Screen untuk mengambil foto selfie saat check-in/check-out
/// Mendukung kamera laptop di Windows/Desktop dan mobile
class SelfieCameraScreen extends StatefulWidget {
  final PresensiType presensiType;

  const SelfieCameraScreen({
    super.key,
    required this.presensiType,
  });

  @override
  State<SelfieCameraScreen> createState() => _SelfieCameraScreenState();
}

class _SelfieCameraScreenState extends State<SelfieCameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitializing = true;
  bool _isCapturing = false;
  bool _isProcessing = false;
  String? _errorMessage;
  XFile? _capturedImage;
  Uint8List? _capturedImageBytes; // Untuk mendukung Web

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  /// Inisialisasi kamera
  Future<void> _initializeCamera() async {
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      // Dapatkan daftar kamera yang tersedia
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'Tidak ada kamera yang tersedia di perangkat ini';
          _isInitializing = false;
        });
        return;
      }

      // Cari kamera depan (front camera) untuk selfie
      // Jika tidak ada, gunakan kamera pertama yang tersedia
      CameraDescription selectedCamera = _cameras!.first;
      
      for (final camera in _cameras!) {
        if (camera.lensDirection == CameraLensDirection.front) {
          selectedCamera = camera;
          break;
        }
      }

      // Inisialisasi controller kamera
      _cameraController = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal mengakses kamera: ${e.toString()}';
          _isInitializing = false;
        });
      }
    }
  }

  /// Mengambil foto
  Future<void> _takePicture() async {
    if (_cameraController == null || 
        !_cameraController!.value.isInitialized ||
        _isCapturing) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile image = await _cameraController!.takePicture();
      
      // Baca bytes untuk mendukung Web
      final Uint8List imageBytes = await image.readAsBytes();
      
      if (mounted) {
        setState(() {
          _capturedImage = image;
          _capturedImageBytes = imageBytes;
          _isCapturing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil foto: $e'),
            backgroundColor: BrutalismTheme.errorRed,
          ),
        );
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  /// Menyimpan foto ke direktori aplikasi dan mengembalikan path
  Future<String?> _savePhoto() async {
    if (_capturedImage == null) return null;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Untuk Web, kembalikan path asli dari XFile
      if (kIsWeb) {
        return _capturedImage!.path;
      }
      
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String selfieDirPath = '${appDir.path}${Platform.pathSeparator}selfies';
      
      // Buat folder selfies jika belum ada
      final Directory selfieDir = Directory(selfieDirPath);
      if (!await selfieDir.exists()) {
        await selfieDir.create(recursive: true);
      }

      // Generate nama file unik
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String type = widget.presensiType == PresensiType.checkIn 
          ? 'checkin' 
          : 'checkout';
      final String fileName = 'selfie_${type}_$timestamp.jpg';
      final String newPath = '$selfieDirPath${Platform.pathSeparator}$fileName';

      // Salin file ke lokasi baru
      final File originalFile = File(_capturedImage!.path);
      await originalFile.copy(newPath);

      return newPath;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan foto: $e'),
            backgroundColor: BrutalismTheme.errorRed,
          ),
        );
      }
      return null;
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  /// Konfirmasi dan kirim foto
  Future<void> _confirmPhoto() async {
    final String? savedPath = await _savePhoto();
    if (savedPath != null && mounted) {
      Navigator.of(context).pop(savedPath);
    }
  }

  /// Mengambil ulang foto
  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
      _capturedImageBytes = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCheckIn = widget.presensiType == PresensiType.checkIn;
    final accentColor = isCheckIn 
        ? BrutalismTheme.successGreen 
        : BrutalismTheme.errorRed;

    return Scaffold(
      backgroundColor: isDark 
          ? BrutalismTheme.primaryBlack 
          : BrutalismTheme.lightGrey,
      appBar: AppBar(
        title: Text(
          isCheckIn ? 'FOTO CHECK-IN' : 'FOTO CHECK-OUT',
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(isDark, accentColor),
    );
  }

  Widget _buildBody(bool isDark, Color accentColor) {
    // Jika ada foto yang diambil, tampilkan preview
    if (_capturedImage != null) {
      return _buildPhotoPreview(isDark, accentColor);
    }

    // Jika sedang inisialisasi
    if (_isInitializing) {
      return _buildLoading(isDark);
    }

    // Jika ada error
    if (_errorMessage != null) {
      return _buildError(isDark);
    }

    // Tampilkan kamera
    return _buildCameraView(isDark, accentColor);
  }

  /// Widget loading saat kamera diinisialisasi
  Widget _buildLoading(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? BrutalismTheme.accentYellow : BrutalismTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: BrutalismTheme.spacingL),
          Text(
            'MEMPERSIAPKAN KAMERA...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: isDark 
                  ? BrutalismTheme.primaryWhite 
                  : BrutalismTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: BrutalismTheme.spacingS),
          Text(
            'Mohon tunggu sebentar',
            style: TextStyle(
              fontSize: 14,
              color: isDark 
                  ? BrutalismTheme.grey 
                  : BrutalismTheme.darkGrey,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget error
  Widget _buildError(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BrutalismTheme.spacingL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: isDark 
                  ? BrutalismTheme.grey 
                  : BrutalismTheme.darkGrey,
            ),
            const SizedBox(height: BrutalismTheme.spacingL),
            Text(
              'KAMERA TIDAK TERSEDIA',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: isDark 
                    ? BrutalismTheme.primaryWhite 
                    : BrutalismTheme.primaryBlack,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: BrutalismTheme.spacingS),
            Text(
              _errorMessage ?? 'Terjadi kesalahan saat mengakses kamera',
              style: TextStyle(
                fontSize: 14,
                color: isDark 
                    ? BrutalismTheme.grey 
                    : BrutalismTheme.darkGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: BrutalismTheme.spacingXL),
            BrutalButton(
              text: 'COBA LAGI',
              icon: Icons.refresh,
              onPressed: _initializeCamera,
              isFullWidth: false,
            ),
            const SizedBox(height: BrutalismTheme.spacingM),
            BrutalButton(
              text: 'KEMBALI',
              icon: Icons.arrow_back,
              onPressed: () => Navigator.of(context).pop(),
              isOutlined: true,
              isFullWidth: false,
            ),
          ],
        ),
      ),
    );
  }

  /// Widget tampilan kamera live
  Widget _buildCameraView(bool isDark, Color accentColor) {
    final isCheckIn = widget.presensiType == PresensiType.checkIn;

    return Column(
      children: [
        // Info header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(BrutalismTheme.spacingM),
          color: accentColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCheckIn ? Icons.login : Icons.logout,
                color: BrutalismTheme.primaryWhite,
              ),
              const SizedBox(width: BrutalismTheme.spacingS),
              const Text(
                'POSISIKAN WAJAH ANDA',
                style: TextStyle(
                  color: BrutalismTheme.primaryWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),

        // Camera preview
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(BrutalismTheme.spacingM),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark 
                    ? BrutalismTheme.primaryWhite 
                    : BrutalismTheme.primaryBlack,
                width: BrutalismTheme.borderWidth,
              ),
            ),
            child: ClipRect(
              child: _cameraController != null && 
                     _cameraController!.value.isInitialized
                  ? CameraPreview(_cameraController!)
                  : Container(
                      color: BrutalismTheme.primaryBlack,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: BrutalismTheme.accentYellow,
                        ),
                      ),
                    ),
            ),
          ),
        ),

        // Tombol ambil foto
        Padding(
          padding: const EdgeInsets.all(BrutalismTheme.spacingM),
          child: BrutalButton(
            text: _isCapturing ? 'MENGAMBIL FOTO...' : 'AMBIL FOTO',
            icon: Icons.camera_alt,
            onPressed: _isCapturing ? null : _takePicture,
            backgroundColor: accentColor,
            isFullWidth: true,
            isLoading: _isCapturing,
          ),
        ),
      ],
    );
  }

  /// Widget preview foto yang sudah diambil
  Widget _buildPhotoPreview(bool isDark, Color accentColor) {
    final isCheckIn = widget.presensiType == PresensiType.checkIn;

    return Column(
      children: [
        // Info header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(BrutalismTheme.spacingM),
          color: accentColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCheckIn ? Icons.login : Icons.logout,
                color: BrutalismTheme.primaryWhite,
              ),
              const SizedBox(width: BrutalismTheme.spacingS),
              Text(
                isCheckIn ? 'SELFIE CHECK-IN' : 'SELFIE CHECK-OUT',
                style: const TextStyle(
                  color: BrutalismTheme.primaryWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),

        // Preview foto
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(BrutalismTheme.spacingM),
            decoration: BoxDecoration(
              border: Border.all(
                color: isDark 
                    ? BrutalismTheme.primaryWhite 
                    : BrutalismTheme.primaryBlack,
                width: BrutalismTheme.borderWidth,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Gunakan Image.memory untuk mendukung Web dan Desktop
                _capturedImageBytes != null
                    ? Image.memory(
                        _capturedImageBytes!,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: BrutalismTheme.grey,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: BrutalismTheme.primaryWhite,
                          ),
                        ),
                      ),
                // Overlay timestamp
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(BrutalismTheme.spacingM),
                    color: BrutalismTheme.primaryBlack.withValues(alpha: 0.7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDateTime(DateTime.now()),
                          style: const TextStyle(
                            color: BrutalismTheme.primaryWhite,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isCheckIn 
                              ? 'Foto akan disimpan sebagai bukti check-in'
                              : 'Foto akan disimpan sebagai bukti check-out',
                          style: TextStyle(
                            color: BrutalismTheme.primaryWhite.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Tombol aksi
        Padding(
          padding: const EdgeInsets.all(BrutalismTheme.spacingM),
          child: Row(
            children: [
              // Tombol Ulangi
              Expanded(
                child: BrutalButton(
                  text: 'ULANGI',
                  icon: Icons.refresh,
                  onPressed: _isProcessing ? null : _retakePhoto,
                  isOutlined: true,
                  isFullWidth: true,
                ),
              ),
              const SizedBox(width: BrutalismTheme.spacingM),
              // Tombol Konfirmasi
              Expanded(
                child: BrutalButton(
                  text: 'KONFIRMASI',
                  icon: Icons.check,
                  onPressed: _isProcessing ? null : _confirmPhoto,
                  backgroundColor: accentColor,
                  isFullWidth: true,
                  isLoading: _isProcessing,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Format datetime untuk ditampilkan
  String _formatDateTime(DateTime dateTime) {
    final days = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    
    final day = days[dateTime.weekday % 7];
    final date = dateTime.day;
    final month = months[dateTime.month - 1];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    
    return '$day, $date $month $year - $hour:$minute:$second';
  }
}
