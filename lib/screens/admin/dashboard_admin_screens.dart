import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbl_app_joglo66/components/header_one.dart';
import 'package:pbl_app_joglo66/components/info_card_circle.dart';
import 'package:pbl_app_joglo66/components/menu_grid.dart';

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
    
    final List<Map<String, dynamic>> fieldMenu = [
      {
        'icon': Icons.list_alt,
        'label': 'Daftar Booking',
        'color': Colors.blue,
        'onTap': () {
          context.push('/admin/list-booking');
        },
      },
      {
        'icon': Icons.info_outline,
        'label': 'Daftar Lapangan',
        'color': Colors.green,
        'onTap': () {
          context.push('/admin/list-field');
        },

      },
      {
        'icon': Icons.money,
        'label': 'Pengeluaran',
        'color': Colors.orange,
        'onTap': () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Menuju Halaman Pengeluaran')),
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
                      HeaderOne(title: dashboardData['name']),
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
                  // Slot Terisi (atas kiri)
                  InfoCardCircle(
                    title: 'Slot Terisi',
                    value: '${dashboardData['slotTerisi']}/${dashboardData['totalSlot']}',
                    icon: Icons.check_circle,
                  ),
                  // Slot Kosong (atas kanan)
                  InfoCardCircle(
                    title: 'Slot Kosong',
                    value: '${dashboardData['slotKosong']}/${dashboardData['totalSlot']}',
                    icon: Icons.open_in_full,
                  ),
                ],
              ),
              // Total Booking (bawah tengah)
              Center(
                child: InfoCardCircle(
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