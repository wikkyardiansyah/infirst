import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/brutalism_theme.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../login/login_screen.dart';

/// Admin Login Screen
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<AdminProvider>();
      final success = await provider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrutalismTheme.primaryBlack,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(BrutalismTheme.spacingL),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(BrutalismTheme.spacingL),
                    decoration: BoxDecoration(
                      color: BrutalismTheme.accentYellow,
                      border: Border.all(
                        color: BrutalismTheme.primaryWhite,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings,
                      size: 60,
                      color: BrutalismTheme.primaryBlack,
                    ),
                  ),

                  const SizedBox(height: BrutalismTheme.spacingL),

                  const Text(
                    'ADMIN PANEL',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: BrutalismTheme.primaryWhite,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: BrutalismTheme.spacingS),

                  const Text(
                    'INFIRST ATTENDANCE SYSTEM',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: BrutalismTheme.lightGrey,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: BrutalismTheme.spacingXL),

                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(BrutalismTheme.spacingL),
                    decoration: BoxDecoration(
                      color: BrutalismTheme.primaryWhite,
                      border: Border.all(
                        color: BrutalismTheme.primaryBlack,
                        width: 3,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LOGIN ADMIN',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),

                        const SizedBox(height: BrutalismTheme.spacingM),

                        // Email Field
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email Admin',
                          icon: Icons.email_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: BrutalismTheme.spacingM),

                        // Password Field
                        _buildTextField(
                          controller: _passwordController,
                          label: 'Password',
                          icon: Icons.lock_outline,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            return null;
                          },
                        ),

                        // Error Message
                        Consumer<AdminProvider>(
                          builder: (context, provider, _) {
                            if (provider.errorMessage != null) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  top: BrutalismTheme.spacingM,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(
                                    BrutalismTheme.spacingS,
                                  ),
                                  color: BrutalismTheme.errorRed,
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.error,
                                        color: BrutalismTheme.primaryWhite,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          provider.errorMessage!,
                                          style: const TextStyle(
                                            color: BrutalismTheme.primaryWhite,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),

                        const SizedBox(height: BrutalismTheme.spacingL),

                        // Login Button
                        Consumer<AdminProvider>(
                          builder: (context, provider, _) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: provider.isLoading
                                    ? null
                                    : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: BrutalismTheme.primaryBlack,
                                  foregroundColor: BrutalismTheme.accentYellow,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: BrutalismTheme.spacingM,
                                  ),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                ),
                                child: provider.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            BrutalismTheme.accentYellow,
                                          ),
                                        ),
                                      )
                                    : const Text(
                                        'MASUK',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: BrutalismTheme.spacingL),

                  // Info
                  Container(
                    padding: const EdgeInsets.all(BrutalismTheme.spacingS),
                    color: BrutalismTheme.accentYellow,
                    child: const Text(
                      'Default: admin@infirst.com / admin123',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: BrutalismTheme.primaryBlack,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: BrutalismTheme.primaryBlack,
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? _obscurePassword : false,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: Icon(icon),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(BrutalismTheme.spacingM),
        ),
        validator: validator,
      ),
    );
  }
}

/// Admin Dashboard Screen
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<String> _menuTitles = [
    'Dashboard',
    'Karyawan',
    'Presensi',
    'Laporan',
  ];

  final List<IconData> _menuIcons = [
    Icons.dashboard,
    Icons.people,
    Icons.fingerprint,
    Icons.assessment,
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: isWide ? 250 : 70,
            color: BrutalismTheme.primaryBlack,
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(BrutalismTheme.spacingM),
                  color: BrutalismTheme.accentYellow,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.admin_panel_settings,
                        color: BrutalismTheme.primaryBlack,
                      ),
                      if (isWide) ...[
                        const SizedBox(width: 8),
                        const Text(
                          'ADMIN PANEL',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: BrutalismTheme.primaryBlack,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: BrutalismTheme.spacingM),

                // Menu Items
                Expanded(
                  child: ListView.builder(
                    itemCount: _menuTitles.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedIndex == index;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: BrutalismTheme.spacingM,
                            vertical: BrutalismTheme.spacingM,
                          ),
                          color: isSelected
                              ? BrutalismTheme.accentYellow
                              : Colors.transparent,
                          child: Row(
                            children: [
                              Icon(
                                _menuIcons[index],
                                color: isSelected
                                    ? BrutalismTheme.primaryBlack
                                    : BrutalismTheme.primaryWhite,
                              ),
                              if (isWide) ...[
                                const SizedBox(width: 12),
                                Text(
                                  _menuTitles[index],
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? BrutalismTheme.primaryBlack
                                        : BrutalismTheme.primaryWhite,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Logout
                InkWell(
                  onTap: () {
                    _showLogoutConfirmation(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(BrutalismTheme.spacingM),
                    color: BrutalismTheme.errorRed,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.logout,
                          color: BrutalismTheme.primaryWhite,
                        ),
                        if (isWide) ...[
                          const SizedBox(width: 8),
                          const Text(
                            'LOGOUT',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: BrutalismTheme.primaryWhite,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return const _DashboardContent();
      case 1:
        return const _EmployeeContent();
      case 2:
        return const _AttendanceContent();
      case 3:
        return const _ReportContent();
      default:
        return const _DashboardContent();
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Container(
          padding: const EdgeInsets.all(BrutalismTheme.spacingS),
          color: BrutalismTheme.errorRed,
          child: const Row(
            children: [
              Icon(Icons.logout, color: BrutalismTheme.primaryWhite),
              SizedBox(width: 8),
              Text(
                'KONFIRMASI LOGOUT',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: BrutalismTheme.primaryWhite,
                ),
              ),
            ],
          ),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari Admin Panel?',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'BATAL',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: BrutalismTheme.darkGrey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Logout admin provider
              context.read<AdminProvider>().logout();
              // Logout auth provider juga
              context.read<AuthProvider>().logout();
              // Redirect ke halaman login utama
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BrutalismTheme.errorRed,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text(
              'LOGOUT',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: BrutalismTheme.primaryWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashboard Content
class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(BrutalismTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DASHBOARD OVERVIEW',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: BrutalismTheme.spacingL),

              // Stats Cards
              Wrap(
                spacing: BrutalismTheme.spacingM,
                runSpacing: BrutalismTheme.spacingM,
                children: [
                  _StatCard(
                    title: 'Total Karyawan',
                    value: '${provider.employees.length}',
                    icon: Icons.people,
                    color: BrutalismTheme.accentBlue,
                  ),
                  _StatCard(
                    title: 'Karyawan Aktif',
                    value: '${provider.employees.where((e) => e.isActive).length}',
                    icon: Icons.check_circle,
                    color: BrutalismTheme.successGreen,
                  ),
                  _StatCard(
                    title: 'Total Presensi',
                    value: '${provider.stats['total_hadir'] ?? 0}',
                    icon: Icons.fingerprint,
                    color: BrutalismTheme.accentYellow,
                  ),
                  _StatCard(
                    title: 'Persentase Hadir',
                    value: '${provider.stats['persentase_kehadiran'] ?? 0}%',
                    icon: Icons.percent,
                    color: BrutalismTheme.warningOrange,
                  ),
                ],
              ),

              const SizedBox(height: BrutalismTheme.spacingXL),

              // Recent Employees
              const Text(
                'KARYAWAN TERBARU',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: BrutalismTheme.spacingM),

              if (provider.employees.isEmpty)
                Container(
                  padding: const EdgeInsets.all(BrutalismTheme.spacingL),
                  decoration: BoxDecoration(
                    border: Border.all(width: 2),
                  ),
                  child: const Center(
                    child: Text(
                      'Belum ada karyawan terdaftar',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 2),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.employees.take(5).length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final emp = provider.employees[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: BrutalismTheme.accentYellow,
                          child: Text(
                            emp.nama.isNotEmpty ? emp.nama[0].toUpperCase() : '?',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: BrutalismTheme.primaryBlack,
                            ),
                          ),
                        ),
                        title: Text(
                          emp.nama,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(emp.email),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          color: emp.isActive
                              ? BrutalismTheme.successGreen
                              : BrutalismTheme.errorRed,
                          child: Text(
                            emp.isActive ? 'AKTIF' : 'NONAKTIF',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: BrutalismTheme.primaryWhite,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Stat Card Widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(BrutalismTheme.spacingM),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: BrutalismTheme.primaryBlack,
          width: 3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: BrutalismTheme.primaryBlack, size: 32),
          const SizedBox(height: BrutalismTheme.spacingS),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: BrutalismTheme.primaryBlack,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: BrutalismTheme.primaryBlack,
            ),
          ),
        ],
      ),
    );
  }
}

/// Employee Content
class _EmployeeContent extends StatefulWidget {
  const _EmployeeContent();

  @override
  State<_EmployeeContent> createState() => _EmployeeContentState();
}

class _EmployeeContentState extends State<_EmployeeContent> {
  void _showAddEmployeeDialog() {
    final namaController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final jabatanController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Container(
          padding: const EdgeInsets.all(BrutalismTheme.spacingS),
          color: BrutalismTheme.accentYellow,
          child: const Text(
            'TAMBAH KARYAWAN',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogTextField(controller: namaController, label: 'Nama Lengkap'),
              _DialogTextField(controller: emailController, label: 'Email'),
              _DialogTextField(controller: passwordController, label: 'Password'),
              _DialogTextField(controller: jabatanController, label: 'Jabatan'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('BATAL'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = context.read<AdminProvider>();
              final success = await provider.addEmployee(
                nama: namaController.text,
                email: emailController.text,
                password: passwordController.text,
                jabatan: jabatanController.text,
              );
              if (success && context.mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BrutalismTheme.successGreen,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('SIMPAN', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(BrutalismTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'KELOLA KARYAWAN',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddEmployeeDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('TAMBAH'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BrutalismTheme.successGreen,
                      foregroundColor: BrutalismTheme.primaryWhite,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: BrutalismTheme.spacingL),

              // Success/Error Messages
              if (provider.successMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(BrutalismTheme.spacingS),
                  margin: const EdgeInsets.only(bottom: BrutalismTheme.spacingM),
                  color: BrutalismTheme.successGreen,
                  child: Text(
                    provider.successMessage!,
                    style: const TextStyle(
                      color: BrutalismTheme.primaryWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              if (provider.errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(BrutalismTheme.spacingS),
                  margin: const EdgeInsets.only(bottom: BrutalismTheme.spacingM),
                  color: BrutalismTheme.errorRed,
                  child: Text(
                    provider.errorMessage!,
                    style: const TextStyle(
                      color: BrutalismTheme.primaryWhite,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              // Employee Table
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 2),
                  ),
                  child: provider.employees.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada karyawan terdaftar.\nKlik tombol TAMBAH untuk menambah karyawan baru.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        )
                      : ListView.builder(
                          itemCount: provider.employees.length,
                          itemBuilder: (context, index) {
                            final emp = provider.employees[index];
                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: BrutalismTheme.accentYellow,
                                  child: Text(
                                    emp.nama.isNotEmpty
                                        ? emp.nama[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: BrutalismTheme.primaryBlack,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  emp.nama,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(emp.email),
                                    Text(
                                      emp.jabatan,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Status Toggle
                                    Switch(
                                      value: emp.isActive,
                                      activeColor: BrutalismTheme.successGreen,
                                      onChanged: (_) {
                                        provider.toggleEmployeeStatus(emp);
                                      },
                                    ),
                                    // Delete Button
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: BrutalismTheme.errorRed,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Hapus Karyawan?'),
                                            content: Text(
                                              'Yakin ingin menghapus ${emp.nama}?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: const Text('BATAL'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  provider.deleteEmployee(emp.id);
                                                  Navigator.pop(ctx);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      BrutalismTheme.errorRed,
                                                ),
                                                child: const Text(
                                                  'HAPUS',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Dialog Text Field
class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _DialogTextField({
    required this.controller,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BrutalismTheme.spacingS),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
        ),
      ),
    );
  }
}

/// Attendance Content
class _AttendanceContent extends StatelessWidget {
  const _AttendanceContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.all(BrutalismTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'DATA PRESENSI',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => provider.refresh(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('REFRESH'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: BrutalismTheme.accentBlue,
                      foregroundColor: BrutalismTheme.primaryWhite,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: BrutalismTheme.spacingL),

              // Attendance Records
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 2),
                  ),
                  child: provider.attendanceRecords.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada data presensi',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        )
                      : ListView.builder(
                          itemCount: provider.attendanceRecords.length,
                          itemBuilder: (context, index) {
                            final record = provider.attendanceRecords[index];
                            final status = record['status'] ?? 'alfa';
                            final isHadir = status == 'hadir';

                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  isHadir ? Icons.check_circle : Icons.cancel,
                                  color: isHadir
                                      ? BrutalismTheme.successGreen
                                      : BrutalismTheme.errorRed,
                                ),
                                title: Text(
                                  record['employee_name'] ?? 'Unknown',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                subtitle: Text(
                                  '${record['employee_email'] ?? ''}\n${record['tanggal'] ?? ''}',
                                ),
                                isThreeLine: true,
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  color: isHadir
                                      ? BrutalismTheme.successGreen
                                      : BrutalismTheme.errorRed,
                                  child: Text(
                                    status.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: BrutalismTheme.primaryWhite,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Report Content
class _ReportContent extends StatelessWidget {
  const _ReportContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        final stats = provider.stats;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(BrutalismTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'LAPORAN KEHADIRAN',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: BrutalismTheme.spacingL),

              // Summary Cards
              Wrap(
                spacing: BrutalismTheme.spacingM,
                runSpacing: BrutalismTheme.spacingM,
                children: [
                  _ReportCard(
                    title: 'Total Karyawan Terdaftar',
                    value: '${stats['total_karyawan'] ?? 0}',
                    color: BrutalismTheme.accentBlue,
                  ),
                  _ReportCard(
                    title: 'Total Kehadiran',
                    value: '${stats['total_hadir'] ?? 0}',
                    color: BrutalismTheme.successGreen,
                  ),
                  _ReportCard(
                    title: 'Total Alfa',
                    value: '${stats['total_alfa'] ?? 0}',
                    color: BrutalismTheme.errorRed,
                  ),
                  _ReportCard(
                    title: 'Persentase Kehadiran',
                    value: '${stats['persentase_kehadiran'] ?? 0}%',
                    color: BrutalismTheme.accentYellow,
                  ),
                ],
              ),

              const SizedBox(height: BrutalismTheme.spacingXL),

              // Per Employee Report
              const Text(
                'LAPORAN PER KARYAWAN',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: BrutalismTheme.spacingM),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 2),
                ),
                child: provider.employees.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(BrutalismTheme.spacingL),
                        child: Center(
                          child: Text(
                            'Belum ada data karyawan',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.employees.length,
                        itemBuilder: (context, index) {
                          final emp = provider.employees[index];
                          return FutureBuilder(
                            future: provider.getEmployeeAttendance(emp.email),
                            builder: (context, snapshot) {
                              final attendance = snapshot.data ?? [];
                              final hadir = attendance
                                  .where((a) => a.status.name == 'hadir')
                                  .length;
                              final alfa = attendance
                                  .where((a) => a.status.name == 'alfa')
                                  .length;

                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: BrutalismTheme.accentYellow,
                                    child: Text(
                                      emp.nama.isNotEmpty
                                          ? emp.nama[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: BrutalismTheme.primaryBlack,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    emp.nama,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  subtitle: Text(emp.jabatan),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _MiniStat(
                                        label: 'Hadir',
                                        value: '$hadir',
                                        color: BrutalismTheme.successGreen,
                                      ),
                                      const SizedBox(width: 8),
                                      _MiniStat(
                                        label: 'Alfa',
                                        value: '$alfa',
                                        color: BrutalismTheme.errorRed,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Report Card
class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _ReportCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(BrutalismTheme.spacingL),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(
          color: BrutalismTheme.primaryBlack,
          width: 3,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: BrutalismTheme.primaryBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: BrutalismTheme.primaryBlack,
            ),
          ),
        ],
      ),
    );
  }
}

/// Mini Stat Widget
class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: color,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: BrutalismTheme.primaryWhite,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: BrutalismTheme.primaryWhite,
            ),
          ),
        ],
      ),
    );
  }
}
