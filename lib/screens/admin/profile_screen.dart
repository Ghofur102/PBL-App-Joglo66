import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/router/app_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      // Memanggil API Profil
      final data = await authService.fetchProfile(); 
      
      if (mounted) {
        setState(() {
          userData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString().replaceAll('Exception: ', '');
          isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    // Tampilkan dialog konfirmasi sebelum logout
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => isLoading = true);
      try {
        await authService.logout();
        if (mounted) {
          // Arahkan ke halaman login (sesuaikan rutenya dengan router Anda)
          context.go('/login'); 
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal logout: $e'), backgroundColor: Colors.red),
          );
          setState(() => isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      appBar: AppBar(
        title: const Text('Profil Saya', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF406093)))
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 50, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(errorMessage, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProfileData,
                        child: const Text('Coba Lagi'),
                      )
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // --- KARTU PROFIL UTAMA ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Avatar Lingkaran dengan Inisial Nama
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: const Color(0xFF406093),
                              child: Text(
                                userData!['name'].toString().substring(0, 1).toUpperCase(),
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              userData!['name'] ?? 'Admin',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                (userData!['role'] ?? 'Unknown').toString().toUpperCase(),
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- KARTU INFORMASI DETAIL ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Informasi Akun', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            const Divider(height: 30),
                            _buildInfoRow(Icons.email_outlined, 'Email', userData!['email'] ?? '-'),
                            const SizedBox(height: 16),
                            _buildInfoRow(Icons.phone_outlined, 'Telepon', userData!['phone'] ?? '-'),
                            const SizedBox(height: 16),
                            if (userData!['role'] == 'worker')
                              _buildInfoRow(
                                Icons.sports_soccer, 
                                'Admin Lapangan', 
                                userData!['managed_fields'] ?? 'Belum ditugaskan'
                              )
                            else
                              _buildInfoRow(
                                Icons.groups_outlined, 
                                'Nama Tim', 
                                userData!['team_name'] ?? '-'
                              ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),

                      // --- TOMBOL LOGOUT ---
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _handleLogout,
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text(
                            'Keluar Akun',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.red.shade200),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  // Widget pembantu untuk merender baris informasi
  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey.shade600, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
            ],
          ),
        ),
      ],
    );
  }
}