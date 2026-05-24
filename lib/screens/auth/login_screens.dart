import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:pbl_app_joglo66/components/button.dart';
import 'package:pbl_app_joglo66/router/app_router.dart'; 

class LoginScreens extends StatefulWidget {
  const LoginScreens({super.key});

  @override
  State<LoginScreens> createState() => _LoginScreensState();
}

class _LoginScreensState extends State<LoginScreens> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true; // State untuk mengatur visibilitas password

  // VARIABEL DEBUGGING
  String debugRole = 'Mengecek...';
  String debugToken = 'Mengecek...';

  @override
  void initState() {
    super.initState();
    _checkClearedAuth();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- LOGIKA UI & FITUR ---

  // Fungsi untuk menampilkan password selama 2 detik
  Future<void> _togglePasswordVisibility() async {
    setState(() {
      _obscurePassword = false;
    });

    // Tunggu selama 2 detik
    await Future.delayed(const Duration(seconds: 2));

    // Pastikan widget masih ada (mounted) sebelum mengubah state
    if (mounted) {
      setState(() {
        _obscurePassword = true;
      });
    }
  }

  // Helper DRY untuk desain Input Text (Menghindari penulisan kode berulang)
  InputDecoration _buildInputDecoration({
    required String label,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(prefixIcon),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  // --- LOGIKA BISNIS & VALIDASI ---

  Future<void> _checkClearedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      debugRole = prefs.getString('user_role') ?? 'KOSONG (Sudah Terhapus)';
      debugToken = prefs.getString('auth_token') ?? 'KOSONG (Sudah Terhapus)';
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
      
    setState(() {
      _isLoading = true;
    });

    final result = await authService.login(
      _usernameController.text, 
      _passwordController.text
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      Future.microtask(() {
        if (mounted) context.go('/admin/dashboard'); 
      });
    } else {
      _showErrorSnackBar(result['message']);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  String? _validateField(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field wajib diisi';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  // --- BUILD UI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.brown[50]!, Colors.brown[100]!],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1), 
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1), 
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_person_outlined,
                          size: 64,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Masuk Admin',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            
                            // INPUT EMAIL
                            TextFormField(
                              controller: _usernameController,
                              decoration: _buildInputDecoration(
                                label: 'Email', 
                                prefixIcon: Icons.person_outline,
                              ),
                              validator: (value) => _validateField(value, 'Email'),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // INPUT PASSWORD DENGAN FITUR MATA (2 DETIK)
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: _buildInputDecoration(
                                label: 'Password', 
                                prefixIcon: Icons.lock_outline,
                                suffixIcon: IconButton(
                                  // Jika sedang tidak obscure, icon mata terbuka. Jika obscure, mata dicoret.
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: _obscurePassword ? Colors.grey : Colors.blue,
                                  ),
                                  // Mematikan tombol (null) jika password sedang ditampilkan
                                  onPressed: _obscurePassword ? _togglePasswordVisibility : null,
                                ),
                              ),
                              validator: _validatePassword,
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // TOMBOL SUBMIT
                            SizedBox(
                              width: double.infinity, 
                              height: 50, 
                              child: _isLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : Button(label: 'Masuk', onPressed: _submit),
                            ),
                            
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () => context.go('/register'), 
                              child: const Text('Belum punya akun? Daftar'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}