import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/brutalism_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/brutal_widgets.dart';
import '../admin/admin_dashboard_screen.dart';

/// Login Screen
/// Menampilkan form login dengan email
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _errorMessage = null;
      });
      
      final authProvider = context.read<AuthProvider>();
      final result = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (result.success && mounted) {
        // Jika login sebagai admin, arahkan ke admin dashboard
        if (result.isAdmin) {
          // Load data admin
          await context.read<AdminProvider>().loadAllData();
          
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/admin',
              (route) => false,
            );
          }
        } else {
          // Login sebagai karyawan - inisialisasi attendance dan navigasi ke main
          await context.read<AttendanceProvider>().initializeWithEmail(
            _emailController.text.trim(),
          );
          
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/main',
              (route) => false,
            );
          }
        }
      } else if (!result.success && mounted) {
        setState(() {
          _errorMessage = result.message;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark 
          ? BrutalismTheme.primaryBlack 
          : BrutalismTheme.primaryWhite,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(BrutalismTheme.spacingL),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Icon
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
                      size: 80,
                      color: BrutalismTheme.primaryBlack,
                    ),
                  ),

                  const SizedBox(height: BrutalismTheme.spacingL),

                  // Title
                  Text(
                    'INFIRST',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: isDark 
                          ? BrutalismTheme.primaryWhite 
                          : BrutalismTheme.primaryBlack,
                    ),
                  ),

                  const SizedBox(height: BrutalismTheme.spacingS),

                  // Subtitle
                  Text(
                    'APLIKASI ABSENSI KARYAWAN',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      color: isDark 
                          ? BrutalismTheme.lightGrey 
                          : BrutalismTheme.darkGrey,
                    ),
                  ),

                  const SizedBox(height: BrutalismTheme.spacingXL),

                  // Email Input
                  BrutalCard(
                    margin: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MASUK KE AKUN',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            color: isDark 
                                ? BrutalismTheme.primaryWhite 
                                : BrutalismTheme.primaryBlack,
                          ),
                        ),

                        const SizedBox(height: BrutalismTheme.spacingM),

                        // Email Field
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark 
                                  ? BrutalismTheme.primaryWhite 
                                  : BrutalismTheme.primaryBlack,
                              width: 2,
                            ),
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark 
                                  ? BrutalismTheme.primaryWhite 
                                  : BrutalismTheme.primaryBlack,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Masukkan email Anda',
                              hintStyle: TextStyle(
                                color: isDark 
                                    ? BrutalismTheme.lightGrey 
                                    : BrutalismTheme.darkGrey,
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: isDark 
                                    ? BrutalismTheme.lightGrey 
                                    : BrutalismTheme.darkGrey,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(
                                BrutalismTheme.spacingM,
                              ),
                              filled: true,
                              fillColor: isDark 
                                  ? BrutalismTheme.darkGrey 
                                  : BrutalismTheme.primaryWhite,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email tidak boleh kosong';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: BrutalismTheme.spacingM),

                        // Password Field
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark 
                                  ? BrutalismTheme.primaryWhite 
                                  : BrutalismTheme.primaryBlack,
                              width: 2,
                            ),
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark 
                                  ? BrutalismTheme.primaryWhite 
                                  : BrutalismTheme.primaryBlack,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Masukkan password',
                              hintStyle: TextStyle(
                                color: isDark 
                                    ? BrutalismTheme.lightGrey 
                                    : BrutalismTheme.darkGrey,
                                fontWeight: FontWeight.w500,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: isDark 
                                    ? BrutalismTheme.lightGrey 
                                    : BrutalismTheme.darkGrey,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword 
                                      ? Icons.visibility_off 
                                      : Icons.visibility,
                                  color: isDark 
                                      ? BrutalismTheme.lightGrey 
                                      : BrutalismTheme.darkGrey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(
                                BrutalismTheme.spacingM,
                              ),
                              filled: true,
                              fillColor: isDark 
                                  ? BrutalismTheme.darkGrey 
                                  : BrutalismTheme.primaryWhite,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              if (value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _handleLogin(),
                          ),
                        ),

                        // Error Message
                        if (_errorMessage != null) ...[
                          const SizedBox(height: BrutalismTheme.spacingS),
                          Container(
                            padding: const EdgeInsets.all(BrutalismTheme.spacingS),
                            color: BrutalismTheme.errorRed.withOpacity(0.1),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: BrutalismTheme.errorRed,
                                  size: 20,
                                ),
                                const SizedBox(width: BrutalismTheme.spacingS),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: BrutalismTheme.errorRed,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: BrutalismTheme.spacingL),

                        // Login Button
                        Consumer<AuthProvider>(
                          builder: (context, authProvider, child) {
                            return BrutalButton(
                              text: 'MASUK',
                              icon: Icons.login,
                              onPressed: _handleLogin,
                              isFullWidth: true,
                              isLoading: authProvider.isLoading,
                              backgroundColor: BrutalismTheme.accentYellow,
                              textColor: BrutalismTheme.primaryBlack,
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: BrutalismTheme.spacingXL),

                  // Footer
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: BrutalismTheme.spacingM,
                      vertical: BrutalismTheme.spacingS,
                    ),
                    color: BrutalismTheme.primaryBlack,
                    child: const Text(
                      'BRUTALISM DESIGN © 2024',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: BrutalismTheme.accentYellow,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
