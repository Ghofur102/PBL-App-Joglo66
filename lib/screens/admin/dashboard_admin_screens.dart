import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbl_app_joglo66/components/menu_grid.dart';
import 'package:pbl_app_joglo66/screens/admin/field/field_details_admin_screens.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/list_booking_admin_screens.dart';

class DashboardAdminScreens extends StatefulWidget {
  const DashboardAdminScreens({super.key});

  @override
  State<DashboardAdminScreens> createState() => _DashboardAdminScreensState();
}

class _DashboardAdminScreensState extends State<DashboardAdminScreens> {
  // Dummy data
  final Map<String, dynamic> dashboardData = {
    'name': 'Joglo66',
    'slotTerisi': 4,
    'totalSlot': 17,
    'totalBooking': 4,
    'slotKosong': 13,
  };

  @override
  Widget build(BuildContext context) {
    
    // PINDAHKAN KE SINI: Agar bisa menggunakan parameter 'context' untuk navigasi
    final List<Map<String, dynamic>> fieldMenu = [
      {
        'icon': Icons.list_alt,
        'label': 'Daftar Booking',
        'color': Colors.blue,
        'onTap': () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ListBookingAdminScreens()));
        },
      },
      {
        'icon': Icons.info_outline,
        'label': 'Detail Lapangan',
        'color': Colors.green,
        'onTap': () {
          Navigator.pushNamed(context, '/list_field');
        },

      },
      {
        'icon': Icons.image,
        'label': 'Galeri',
        'color': Colors.orange,
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menuju Halaman Galeri')),
          );
        },
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Header Section dengan curved bottom
              SliverAppBar(
                expandedHeight: 380,
                automaticallyImplyLeading: false,
                backgroundColor: const Color(0xFF4A6FA5),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: HeaderSection(dashboardData: dashboardData),
                ),
              ),

              // Content Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Mini Soccer
                      Text(
                        'Mini Soccer',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Memanggil Komponen Menu Grid yang sudah dipisah
                      MenuGrid(menuItems: fieldMenu),
                      
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class HeaderSection extends StatelessWidget {
  final Map<String, dynamic> dashboardData;

  const HeaderSection({
    super.key,
    required this.dashboardData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 30,
        left: 24,
        right: 24,
        bottom: 40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title Joglo66 - CENTER ALIGNED
          Text(
            dashboardData['name'] ?? 'Joglo66',
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Subtitle - CENTER ALIGNED
          Text(
            'Ringkasan Hari Ini',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Info Circles Row - MEMBENTUK SEGITIGA TERBALIK
          Column(
            children: [
              // Row atas: Slot Terisi dan Slot Kosong
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 20),
                  // Slot Terisi (atas kiri)
                  InfoCircle(
                    title: 'Slot Terisi',
                    value: '${dashboardData['slotTerisi']}/${dashboardData['totalSlot']}',
                    icon: Icons.check_circle,
                  ),
                  // Slot Kosong (atas kanan)
                  InfoCircle(
                    title: 'Slot Kosong',
                    value: '${dashboardData['slotKosong']}/${dashboardData['totalSlot']}',
                    icon: Icons.open_in_full,
                  ),
                  const SizedBox(width: 20),
                ],
              ),
              const SizedBox(height: 20),
              // Total Booking (bawah tengah)
              Center(
                child: InfoCircle(
                  title: 'Total Booking',
                  value: '${dashboardData['totalBooking']}',
                  icon: Icons.calendar_today,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class InfoCircle extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const InfoCircle({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 115,
      height: 105,
      decoration: BoxDecoration(
        // Oval shape (ellipse) MENYAMPING dengan warna biru cerah
        color: Colors.blue.shade300,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.blue.shade400,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Icon(
            icon,
            color: Colors.white,
            size: 26,
          ),
          const SizedBox(height: 6),

          // Value
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),

          // Title
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 9,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
