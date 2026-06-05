import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pbl_app_joglo66/router/app_router.dart';

class CustomBottomNavPage extends StatelessWidget {
  final Widget child;
  final String currentRole;

  const CustomBottomNavPage({
    super.key,
    required this.child,
    required this.currentRole,
  });

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.contains('dashboard')) return 0;
    if (location.contains('list-booking')) return 1;
    if (location.contains('list-field')) return 2;
    if (location.contains('profile')) return 3;
    return 0;
  }

  Future<void> _onItemTapped(int index, BuildContext context) async {
    if (currentRole == 'admin' || currentRole == 'worker') {
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
    } else {
      switch (index) {
        case 0:
          context.go('/$currentRole/dashboard');
          break;
        case 4:
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();

          try {
            await authService.logout();
          } catch (_) {}

          if (context.mounted) {
            context.go('/login');
          }
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = _calculateSelectedIndex(context);
    final bool isAdminOrWorker = currentRole == 'admin' || currentRole == 'worker';

    return Scaffold(
      body: child,
      floatingActionButton: isAdminOrWorker
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF406093),
              shape: const CircleBorder(),
              elevation: 4,
              onPressed: () => context.push('/admin/check-availability'),
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            )
          : null,
      floatingActionButtonLocation:
          isAdminOrWorker ? FloatingActionButtonLocation.centerDocked : null,
      bottomNavigationBar: BottomAppBar(
        shape: isAdminOrWorker ? const CircularNotchedRectangle() : null,
        notchMargin: 8.0,
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: isAdminOrWorker
                ? MainAxisAlignment.spaceAround
                : MainAxisAlignment.spaceEvenly,
            children: isAdminOrWorker
                ? [
                    _buildNavItem(context, Icons.dashboard, 'Dashboard', 0, currentIndex),
                    _buildNavItem(context, Icons.book_online, 'Booking', 1, currentIndex),
                    const SizedBox(width: 48),
                    _buildNavItem(context, Icons.sports_soccer, 'Lapangan', 2, currentIndex),
                    _buildNavItem(context, Icons.person, 'Profil', 3, currentIndex),
                  ]
                : [
                    _buildNavItem(context, Icons.dashboard, 'Beranda', 0, currentIndex),
                    _buildNavItem(context, Icons.logout, 'Keluar', 4, currentIndex),
                  ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index, int currentIndex) {
    final isSelected = currentIndex == index;
    final color = isSelected ? const Color(0xFF406093) : Colors.grey;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onItemTapped(index, context),
        borderRadius: BorderRadius.circular(50),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
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
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}