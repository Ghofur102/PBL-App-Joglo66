import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/notification_service.dart';

class DashboardOwnerScreen extends StatefulWidget {
  const DashboardOwnerScreen({super.key});

  @override
  State<DashboardOwnerScreen> createState() => _DashboardOwnerScreenState();
}

class _DashboardOwnerScreenState extends State<DashboardOwnerScreen> {
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await NotificationService.fetchUnreadCount(role: 'owner');
      if (mounted && count != _unreadNotificationCount) {
        setState(() {
          _unreadNotificationCount = count;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeConstants.bgLight,
      appBar: AppBar(
        title: const Text(
          'Dasbor Pemilik (Owner)',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined, color: AppThemeConstants.textPrimary),
                if (_unreadNotificationCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppThemeConstants.errorRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        _unreadNotificationCount > 99 ? '99+' : '$_unreadNotificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => context.push('/owner/notifications').then((_) => _loadUnreadCount()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Menu Utama Pengelolaan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              title: 'Notifikasi & Pengajuan',
              subtitle: 'Pantau pengajuan jadwal ulang dan pembatalan sewa',
              icon: Icons.notifications_active_rounded,
              color: Colors.orange,
              badgeCount: _unreadNotificationCount,
              onTap: () => context.push('/owner/notifications').then((_) => _loadUnreadCount()),
            ),
            const SizedBox(height: 12),
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

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    int badgeCount = 0,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
            if (badgeCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppThemeConstants.errorRed, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount Baru',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
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
