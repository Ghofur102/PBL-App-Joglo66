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

  // VARIABEL DEBUGGING
  String debugRole = 'Mengecek...';
  String debugToken = 'Mengecek...';

  @override
  void initState() {
    super.initState();
    // Cek memori HP saat halaman login dibuka
    _checkClearedAuth();
  }

  // FUNGSI UNTUK MENGECEK MEMORI HP
  Future<void> _checkClearedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // Jika null (kosong), tampilkan tulisan "KOSONG"
      debugRole = prefs.getString('user_role') ?? 'KOSONG (Sudah Terhapus)';
      debugToken = prefs.getString('auth_token') ?? 'KOSONG (Sudah Terhapus)';
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      
      setState(() {
        _isLoading = true;
      });

      final result = await authService.login(
        _usernameController.text, 
        _passwordController.text
      );

      // 1. TAMBAHKAN BARIS INI: Cegah crash jika layar sudah keburu pindah
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (result['success'] == true) {
        // 2. BUNGKUS DENGAN MICROTASK agar tidak bertabrakan dengan GoRouter
        Future.microtask(() {
          if (mounted) context.go('/admin/dashboard'); 
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  String? _validateField(String? value, String field) {
    if (value == null || value.isEmpty) {
      return '$field wajib diisi';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

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
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
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
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: (value) =>
                                  _validateField(value, 'Email'),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: _validatePassword,
                            ),
                            const SizedBox(height: 32),
                            
                            SizedBox(
                              width: double.infinity, 
                              height: 50, 
                              child: _isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Button(label: 'Masuk', onPressed: _submit),
                            ),
                            
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () =>
                                  context.go('/register'), 
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