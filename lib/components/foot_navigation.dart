import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/router/app_router.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/check_slot_availability_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/list_booking_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/admin/dashboard_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/admin/field/list_closed_booking_admin_screens.dart';

class CustomBottomNavPage extends StatefulWidget {
  const CustomBottomNavPage({super.key});

  @override
  State<CustomBottomNavPage> createState() => _CustomBottomNavPageState();
}

class _CustomBottomNavPageState extends State<CustomBottomNavPage> {
  int _currentIndex = 0;

  final List<Widget> _adminPages = const [
    DashboardAdminScreens(),                  // Index 0
    ListClosedBookingAdminScreens(),      // Index 1
    CheckSlotAvailabilityAdminScreens(),      // Index 2 (Tengah/FAB)
    ListBookingAdminScreens(),                // Index 3
    Center(child: Text("Profil Admin")),      // Index 4
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = authService.role == 'admin';
    
    final List<Widget> currentPages = isAdmin ? _adminPages : _adminPages;

    return Scaffold(
      body: currentPages[_currentIndex],

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _item(Icons.home, "Home", 0),
              _item(Icons.calendar_today, isAdmin ? "Booking Tutup" : "Jadwal", 1),

              const SizedBox(width: 40), // Spasi kosong untuk tombol tengah (FAB)

              // Teks menunya bisa diubah dinamis juga!
              _item(Icons.history, isAdmin ? "Daftar Booking" : "Riwayat", 3),
              _item(Icons.person, "Profil", 4),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF406093), // Warna utama aplikasi
        onPressed: () => _onTap(2), // Mengarah ke index 2
        // Ikonnya juga bisa beda tergantung role
        child: Icon(isAdmin ? Icons.add : Icons.sports_soccer, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _item(IconData icon, String label, int index) {
    final active = _currentIndex == index;
    final color = active ? const Color(0xFF406093) : Colors.grey;

    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque, 
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}