import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/components/app_button.dart';
import 'package:pbl_app_joglo66/components/detail_row.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/router/app_router.dart';

class ProfileAdminScreen extends StatefulWidget {
  const ProfileAdminScreen({super.key});

  @override
  State<ProfileAdminScreen> createState() => _ProfileAdminScreenState();
}

class _ProfileAdminScreenState extends State<ProfileAdminScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final data = await authService.fetchProfile();
      if (mounted) {
        setState(() {
          _userData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppThemeConstants.radiusMedium),
        ),
        title: const Text('Konfirmasi Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeConstants.errorRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await authService.logout();
        if (mounted) {
          context.go('/login');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal logout: $e'), backgroundColor: AppThemeConstants.errorRed),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeConstants.bgLight,
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(color: AppThemeConstants.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.accentBlue))
          : _errorMessage.isNotEmpty
              ? _buildErrorState()
              : _buildProfileContent(),
    );
  }

  Widget _buildErrorState() {
    final errorWidget = Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 50, color: AppThemeConstants.errorRed),
            const SizedBox(height: 16),
            Text(_errorMessage, style: const TextStyle(color: AppThemeConstants.errorRed)),
            const SizedBox(height: 16),
            AppButton(label: 'Coba Lagi', onPressed: _loadProfileData),
          ],
        ),
      ),
    );

    return errorWidget;
  }

  Widget _buildProfileContent() {
    final String currentRole = (_userData?['role'] ?? 'Unknown').toString().toUpperCase();
    final bool isWorker = _userData!['role'] == 'worker';

    final contentWidget = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppThemeConstants.radiusLarge),
              border: Border.all(color: AppThemeConstants.borderGrey),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppThemeConstants.accentBlue,
                  child: Text(
                    _userData!['name'].toString().substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _userData!['name'] ?? 'Admin',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppThemeConstants.lightGreen,
                    borderRadius: BorderRadius.circular(AppThemeConstants.radiusCircular),
                    border: Border.all(color: AppThemeConstants.successGreen.withOpacity(0.3)),
                  ),
                  child: Text(
                    currentRole,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppThemeConstants.successGreen),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppThemeConstants.radiusLarge),
              border: Border.all(color: AppThemeConstants.borderGrey),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Informasi Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary)),
                const Divider(height: 30, color: AppThemeConstants.borderGrey),
                DetailRow(label: 'Email', value: _userData!['email'] ?? '-'),
                const Divider(height: 16, color: Color(0xFFF1F5F9)),
                DetailRow(label: 'Telepon', value: _userData!['phone'] ?? '-'),
                const Divider(height: 16, color: Color(0xFFF1F5F9)),
                if (isWorker)
                  DetailRow(label: 'Admin Lapangan', value: _userData!['managed_fields'] ?? 'Belum ditugaskan')
                else
                  DetailRow(label: 'Nama Tim', value: _userData!['team_name'] ?? '-'),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Keluar Akun',
              backgroundColor: AppThemeConstants.lightRed,
              textColor: AppThemeConstants.errorRed,
              onPressed: _handleLogout,
            ),
          ),
        ],
      ),
    );

    return contentWidget;
  }
}
