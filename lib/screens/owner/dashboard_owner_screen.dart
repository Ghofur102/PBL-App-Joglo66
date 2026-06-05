import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DashboardOwnerScreen extends StatelessWidget {
  const DashboardOwnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Owner Dashboard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B4F8A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 30, backgroundColor: Color(0xFFE6F1FB), child: Icon(Icons.star, color: Color(0xFF1B4F8A), size: 30)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Selamat Datang,', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text('Owner Joglo66', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2A))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text('Menu Utama', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2A))),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              title: 'Manajemen Karyawan',
              subtitle: 'Tambah, edit, dan hapus data karyawan.',
              icon: Icons.people_alt_outlined,
              color: Colors.blue,
              onTap: () => context.push('/owner/karyawan'),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              title: 'Laporan Bulanan',
              subtitle: 'Preview neraca dan unduh PDF.',
              icon: Icons.picture_as_pdf_outlined,
              color: Colors.red,
              onTap: () => context.push('/owner/preview-pdf'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}