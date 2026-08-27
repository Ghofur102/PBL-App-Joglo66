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
        title: const Text('Dasbor Pemilik (Owner)', style: TextStyle(fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Menu Utama Pengelolaan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary)),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              title: 'Manajemen Data Lapangan',
              subtitle: 'Tambah dan perbarui profil unit lapangan olahraga',
              icon: Icons.sports_soccer_rounded,
              color: Colors.green,
              onTap: () => context.push('/owner/fields'),
            ),
            const SizedBox(height: 12),
            _buildMenuCard(
              context,
              title: 'Manajemen Karyawan & Otorisasi',
              subtitle: 'Kelola data karyawan dan penugasan akses sistem',
              icon: Icons.people_alt_rounded,
              color: AppThemeConstants.accentBlue,
              onTap: () => context.push('/owner/karyawan'),
            ),
            const SizedBox(height: 12),
            _buildMenuCard(
              context,
              title: 'Rekap Laporan Keuangan',
              subtitle: 'Pantau arus kas, laba bersih, dan histori transaksi',
              icon: Icons.analytics_rounded,
              color: Colors.purple,
              onTap: () => context.push('/laporan-bulanan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppThemeConstants.textSecondary)),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
