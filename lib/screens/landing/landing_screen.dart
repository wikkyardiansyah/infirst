import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/brutalism_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/brutal_widgets.dart';
import '../login/login_screen.dart';

/// Landing Screen
/// Halaman pembuka yang menarik untuk memperkenalkan aplikasi
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<LandingContent> _contents = [
    LandingContent(
      icon: Icons.fingerprint,
      title: 'ABSENSI MUDAH',
      subtitle: 'Check-in & Check-out dengan satu ketukan',
      description: 'Lakukan absensi harian dengan cepat dan praktis. '
          'Tidak perlu antri atau menggunakan mesin absensi.',
      color: BrutalismTheme.accentYellow,
    ),
    LandingContent(
      icon: Icons.history,
      title: 'RIWAYAT LENGKAP',
      subtitle: 'Pantau kehadiran Anda setiap saat',
      description: 'Lihat riwayat absensi lengkap dengan filter bulan. '
          'Semua data tersimpan dengan aman di perangkat Anda.',
      color: BrutalismTheme.accentBlue,
    ),
    LandingContent(
      icon: Icons.analytics,
      title: 'STATISTIK DETAIL',
      subtitle: 'Analisis performa kehadiran',
      description: 'Dapatkan insight tentang kehadiran Anda. '
          'Persentase hadir dan keterlambatan dalam satu tampilan.',
      color: BrutalismTheme.successGreen,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    // Tandai sudah melihat landing page
    context.read<AuthProvider>().markLandingSeen();
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor:
          isDark ? BrutalismTheme.primaryBlack : BrutalismTheme.primaryWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Padding(
              padding: const EdgeInsets.all(BrutalismTheme.spacingM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(BrutalismTheme.spacingXS),
                        color: BrutalismTheme.accentYellow,
                        child: const Icon(
                          Icons.fingerprint,
                          size: 24,
                          color: BrutalismTheme.primaryBlack,
                        ),
                      ),
                      const SizedBox(width: BrutalismTheme.spacingS),
                      Text(
                        'INFIRST',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: isDark
                              ? BrutalismTheme.primaryWhite
                              : BrutalismTheme.primaryBlack,
                        ),
                      ),
                    ],
                  ),
                  // Skip Button
                  GestureDetector(
                    onTap: _navigateToLogin,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: BrutalismTheme.spacingM,
                        vertical: BrutalismTheme.spacingS,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDark
                              ? BrutalismTheme.primaryWhite
                              : BrutalismTheme.primaryBlack,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        'LEWATI',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          color: isDark
                              ? BrutalismTheme.primaryWhite
                              : BrutalismTheme.primaryBlack,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _contents.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(_contents[index], isDark, screenHeight);
                },
              ),
            ),

            // Bottom Section
            Container(
              padding: const EdgeInsets.all(BrutalismTheme.spacingL),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _contents.length,
                      (index) => _buildIndicator(index, isDark),
                    ),
                  ),

                  const SizedBox(height: BrutalismTheme.spacingL),

                  // Action Buttons
                  Row(
                    children: [
                      // Previous Button
                      if (_currentPage > 0)
                        Expanded(
                          child: BrutalButton(
                            text: 'KEMBALI',
                            icon: Icons.arrow_back,
                            isOutlined: true,
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                      if (_currentPage > 0)
                        const SizedBox(width: BrutalismTheme.spacingM),

                      // Next / Get Started Button
                      Expanded(
                        flex: _currentPage == 0 ? 1 : 1,
                        child: BrutalButton(
                          text: _currentPage == _contents.length - 1
                              ? 'MULAI SEKARANG'
                              : 'LANJUT',
                          icon: _currentPage == _contents.length - 1
                              ? Icons.rocket_launch
                              : Icons.arrow_forward,
                          onPressed: () {
                            if (_currentPage == _contents.length - 1) {
                              _navigateToLogin();
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          backgroundColor: _contents[_currentPage].color,
                          textColor: BrutalismTheme.primaryBlack,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(LandingContent content, bool isDark, double screenHeight) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BrutalismTheme.spacingL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Container with Animation
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(BrutalismTheme.spacingXL),
              decoration: BoxDecoration(
                color: content.color,
                border: Border.all(
                  color: BrutalismTheme.primaryBlack,
                  width: BrutalismTheme.borderWidthThick,
                ),
                boxShadow: [
                  BoxShadow(
                    color: BrutalismTheme.primaryBlack,
                    offset: const Offset(6, 6),
                  ),
                ],
              ),
              child: Icon(
                content.icon,
                size: 100,
                color: BrutalismTheme.primaryBlack,
              ),
            ),
          ),

          const SizedBox(height: BrutalismTheme.spacingXL),

          // Title
          Text(
            content.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: isDark
                  ? BrutalismTheme.primaryWhite
                  : BrutalismTheme.primaryBlack,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: BrutalismTheme.spacingS),

          // Subtitle with accent
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: BrutalismTheme.spacingM,
              vertical: BrutalismTheme.spacingXS,
            ),
            color: content.color,
            child: Text(
              content.subtitle,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: BrutalismTheme.primaryBlack,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: BrutalismTheme.spacingL),

          // Description
          Container(
            padding: const EdgeInsets.all(BrutalismTheme.spacingM),
            decoration: BoxDecoration(
              color: isDark
                  ? BrutalismTheme.darkGrey
                  : BrutalismTheme.lightGrey,
              border: Border.all(
                color: isDark
                    ? BrutalismTheme.primaryWhite
                    : BrutalismTheme.primaryBlack,
                width: 2,
              ),
            ),
            child: Text(
              content.description,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.6,
                color: isDark
                    ? BrutalismTheme.lightGrey
                    : BrutalismTheme.darkGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index, bool isDark) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive
            ? _contents[_currentPage].color
            : (isDark ? BrutalismTheme.darkGrey : BrutalismTheme.lightGrey),
        border: Border.all(
          color: isDark
              ? BrutalismTheme.primaryWhite
              : BrutalismTheme.primaryBlack,
          width: 2,
        ),
      ),
    );
  }
}

/// Model untuk konten landing page
class LandingContent {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;

  LandingContent({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
  });
}
