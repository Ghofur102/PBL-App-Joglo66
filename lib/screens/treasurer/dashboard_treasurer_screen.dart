import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';

class DashboardTreasurerScreen extends StatelessWidget {
  const DashboardTreasurerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeConstants.bgLight,
      appBar: AppBar(
        title: const Text('Treasurer Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppThemeConstants.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: AppThemeConstants.lightAmber, child: Icon(Icons.account_balance_wallet, color: AppThemeConstants.warningAmber)),
                title: const Text('Selamat Datang,', style: TextStyle(fontSize: 12, color: AppThemeConstants.textSecondary)),
                subtitle: const Text('Bendahara Joglo66', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary)),
              ),
            ),
            const SizedBox(height: 24),
            _buildActionCard(context, 'Penggajian Karyawan', 'Catat dan kelola pengeluaran gaji.', Icons.payments_outlined, Colors.green, '/treasurer/gaji'),
            const SizedBox(height: 12),
            _buildActionCard(context, 'Laporan Keuangan', 'Pantau neraca, laba, dan unduh PDF.', Icons.analytics_outlined, Colors.orange, '/laporan-bulanan'),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String sub, IconData icon, Color col, String path) {
    return Card(
      child: ListTile(
        onTap: () => context.push(path),
        leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: col.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: col)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
