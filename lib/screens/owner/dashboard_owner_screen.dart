import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';

class DashboardOwnerScreen extends StatelessWidget {
  const DashboardOwnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeConstants.bgLight,
      appBar: AppBar(
        title: const Text('Owner Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppThemeConstants.primaryBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: AppThemeConstants.lightBlue, child: Icon(Icons.star, color: AppThemeConstants.primaryBlue)),
                title: const Text('Selamat Datang,', style: TextStyle(fontSize: 12, color: AppThemeConstants.textSecondary)),
                subtitle: const Text('Owner Joglo66', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary)),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              title: const Text('Manajemen Karyawan', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Tambah, edit, dan hapus data karyawan.'),
              leading: const Icon(Icons.people_alt_outlined, color: Colors.blue),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/owner/karyawan'),
            ),
            ListTile(
              title: const Text('Laporan Bulanan', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Preview neraca dan unduh PDF.'),
              leading: const Icon(Icons.picture_as_pdf_outlined, color: Colors.red),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/laporan-bulanan'),
            ),
          ],
        ),
      ),
    );
  }
}
