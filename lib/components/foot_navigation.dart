import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavPage extends StatelessWidget {
  // Menerima child dari ShellRoute (Isi layarnya)
  final Widget child;

  const CustomBottomNavPage({super.key, required this.child});

  // Fungsi untuk mengetahui menu ke berapa yang sedang aktif
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/admin/dashboard')) return 0;
    if (location.startsWith('/admin/list-booking')) return 1;
    if (location.startsWith('/admin/list-field')) return 2;
    if (location.startsWith('/admin/profile')) return 3;
    return 0;
  }

  // Fungsi untuk pindah ke tab menu
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/admin/dashboard');
        break;
      case 1:
        context.go('/admin/list-booking');
        break;
      case 2:
        context.go('/admin/list-field');
        break;
      case 3:
        context.go('/admin/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      // --- CHILD INI ADALAH LAYAR YANG BERUBAH-UBAH ---
      body: child, 
      
      // --- TOMBOL PLUS (+) DI TENGAH MENGAMBANG ---
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF406093),
        shape: const CircleBorder(), // Membuatnya bulat sempurna
        elevation: 4,
        onPressed: () {
          // Arahkan ke rute layar Cek Ketersediaan Slot Anda.
          // PASTIKAN nama rutenya sesuai dengan yang ada di app_router.dart Anda
          context.push('/admin/check-availability'); 
        },
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      
      // Mengunci posisi tombol di tengah bawah
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // --- BOTTOM NAVIGATION BAR DENGAN CEKUNGAN ---
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(), // Memberikan efek cekungan untuk tombol plus
        notchMargin: 8.0, // Jarak cekungan dengan tombol
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround, // Meratakan jarak antar ikon
            children: [
              // Bagian Kiri
              _buildNavItem(context, Icons.dashboard, 'Dashboard', 0, currentIndex),
              _buildNavItem(context, Icons.book_online, 'Booking', 1, currentIndex),
              
              // Jarak kosong di tengah untuk memberi ruang pada tombol Plus
              const SizedBox(width: 48), 
              
              // Bagian Kanan
              _buildNavItem(context, Icons.sports_soccer, 'Lapangan', 2, currentIndex),
              _buildNavItem(context, Icons.person, 'Profil', 3, currentIndex),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi helper untuk merender setiap Ikon beserta Text-nya
  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index, int currentIndex) {
    final isSelected = currentIndex == index;
    final color = isSelected ? const Color(0xFF406093) : Colors.grey;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onItemTapped(index, context),
        borderRadius: BorderRadius.circular(50),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: color, 
                  fontSize: 10, 
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}