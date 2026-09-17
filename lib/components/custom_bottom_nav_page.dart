import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/router/app_router.dart';
import 'package:pbl_app_joglo66/services/booking_service.dart';
import 'package:pbl_app_joglo66/services/notification_service.dart';

class CustomBottomNavPage extends StatefulWidget {
  final Widget child;
  final String currentRole;

  const CustomBottomNavPage({
    super.key,
    required this.child,
    required this.currentRole,
  });

  @override
  State<CustomBottomNavPage> createState() => _CustomBottomNavPageState();
}

class _CustomBottomNavPageState extends State<CustomBottomNavPage> {
  int _affectedBookingCount = 0;
  int _unreadNotificationCount = 0;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    if (widget.currentRole == 'worker') {
      _runPeriodicSync();
      _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _runPeriodicSync());
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _runPeriodicSync() async {
    await Future.wait([
      _checkAffectedBookings(),
      _checkUnreadNotifications(),
    ]);
  }

  Future<void> _checkAffectedBookings() async {
    try {
      final data = await BookingService.fetchListBooking();
      final int count = int.tryParse(data['closed_affected_count']?.toString() ?? '0') ?? 0;
      if (mounted && count != _affectedBookingCount) {
        setState(() {
          _affectedBookingCount = count;
        });
      }
    } catch (_) {}
  }

  Future<void> _checkUnreadNotifications() async {
    try {
      final count = await NotificationService.fetchUnreadCount(role: 'worker');
      if (mounted && count != _unreadNotificationCount) {
        setState(() {
          _unreadNotificationCount = count;
        });
      }
    } catch (_) {}
  }

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/admin/dashboard')) return 0;
    if (location.startsWith('/admin/list-booking')) return 1;
    if (location.startsWith('/admin/notifications')) return 2;
    if (location.startsWith('/admin/profile')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    final bool isWorker = widget.currentRole == 'worker';

    if (isWorker) {
      final List<String> workerPaths = [
        '/admin/dashboard',
        '/admin/list-booking',
        '/admin/notifications',
        '/admin/profile',
      ];
      if (index >= 0 && index < workerPaths.length) {
        context.go(workerPaths[index]);
      }
    } else {
      if (index == 0) {
        context.go('/${widget.currentRole}/dashboard');
      } else if (index == 4) {
        authService.logout();
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = _calculateSelectedIndex(context);
    final bool isWorker = widget.currentRole == 'worker';

    return Scaffold(
      body: widget.child,
      floatingActionButton: isWorker
          ? FloatingActionButton(
              backgroundColor: AppThemeConstants.accentBlue,
              shape: const CircleBorder(),
              elevation: 4,
              onPressed: () => context.push('/admin/check-availability'),
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            )
          : null,
      floatingActionButtonLocation: isWorker ? FloatingActionButtonLocation.centerDocked : null,
      bottomNavigationBar: BottomAppBar(
        shape: isWorker ? const CircularNotchedRectangle() : null,
        notchMargin: 8.0,
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 64,
          child: Row(
            children: isWorker
                ? [
                    Expanded(child: _buildNavItem(context, Icons.dashboard_rounded, 'Dashboard', 0, currentIndex)),
                    Expanded(child: _buildNavItem(context, Icons.book_online_rounded, 'Booking', 1, currentIndex, badgeCount: _affectedBookingCount)),
                    const SizedBox(width: 60),
                    Expanded(child: _buildNavItem(context, Icons.notifications_rounded, 'Notifikasi', 2, currentIndex, badgeCount: _unreadNotificationCount)),
                    Expanded(child: _buildNavItem(context, Icons.person_rounded, 'Profil', 3, currentIndex)),
                  ]
                : [
                    Expanded(child: _buildNavItem(context, Icons.dashboard_rounded, 'Beranda', 0, currentIndex)),
                    Expanded(child: _buildNavItem(context, Icons.logout_rounded, 'Keluar', 4, currentIndex)),
                  ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index, int currentIndex, {int badgeCount = 0}) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppThemeConstants.accentBlue : AppThemeConstants.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onItemTapped(index, context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 22),
                if (badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppThemeConstants.errorRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
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
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
