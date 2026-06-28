import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/components/app_button.dart';
import 'package:pbl_app_joglo66/components/app_input_field.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/router/app_router.dart';

class LoginAuthScreen extends StatefulWidget {
  const LoginAuthScreen({super.key});

  @override
  State<LoginAuthScreen> createState() => _LoginAuthScreenState();
}

class _LoginAuthScreenState extends State<LoginAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _togglePasswordVisibility() async {
    setState(() => _obscurePassword = false);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _obscurePassword = true);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final result = await authService.login(_emailController.text.trim(), _passwordController.text);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      context.go('/admin/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: AppThemeConstants.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeConstants.bgLight,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppThemeConstants.radiusLarge)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppThemeConstants.lightBlue,
                      child: const Icon(Icons.lock_person_outlined, size: 44, color: AppThemeConstants.primaryBlue),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Masuk Akun Manajemen',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 32),
                    AppInputField(
                      label: 'Email',
                      hint: 'Masukkan alamat email',
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Email wajib diisi' : null,
                    ),
                    const SizedBox(height: 20),
                    AppInputField(
                      label: 'Password',
                      hint: 'Masukkan kata sandi',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      icon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppThemeConstants.textSecondary),
                        onPressed: _obscurePassword ? _togglePasswordVisibility : null,
                      ),
                      validator: (v) => v == null || v.length < 6 ? 'Password minimal 6 karakter' : null,
                    ),
                    const SizedBox(height: 32),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue))
                        : AppButton(label: 'Masuk', onPressed: _submit),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
