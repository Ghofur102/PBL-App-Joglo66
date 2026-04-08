import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardAdminScreens extends StatefulWidget {
  const DashboardAdminScreens({super.key});

  @override
  State<DashboardAdminScreens> createState() => _DashboardAdminScreensState();
}

class _DashboardAdminScreensState extends State<DashboardAdminScreens> {
  // State untuk bottom navigation bar
  int _currentNavIndex = 0;

  // Dummy data - mudah untuk diganti dengan API nanti
  final Map<String, dynamic> dashboardData = {
    'name': 'Joglo66',
    'slotTerisi': 4,
    'totalSlot': 17,
    'totalBooking': 4,
    'slotKosong': 13,
  };

  final List<Map<String, dynamic>> miniSoccerMenu = [
    {
      'icon': Icons.list_alt,
      'label': 'Daftar Booking',
      'color': Colors.blue,
    },
    {
      'icon': Icons.info_outline,
      'label': 'Detail Lapangan',
      'color': Colors.green,
    },
    {
      'icon': Icons.image,
      'label': 'Galeri',
      'color': Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                      const SizedBox(height: 16),

                      // Menu Grid
                      MenuGrid(menuItems: miniSoccerMenu),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Custom floating button dengan star shape
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: StarPlusButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddBookingPage(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar - SIMETRIS TANPA FAB GAP
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, "Home", 0),
              _buildNavItem(Icons.calendar_today, "Jadwal", 1),
              _buildNavItem(Icons.history, "Riwayat", 2),
              _buildNavItem(Icons.person, "Profil", 3),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk nav item
  Widget _buildNavItem(IconData icon, String label, int index) {
    final active = _currentNavIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentNavIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: active ? const Color(0xFF4A6FA5) : Colors.grey),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: active ? const Color(0xFF4A6FA5) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}


// ==============================================================================
// SEPERTI WIDGET - Header Section
// ==============================================================================
/// Widget untuk menampilkan header dengan info dashboard
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

// ==============================================================================
// INFO CIRCLE - Widget untuk menampilkan info dalam bentuk OVAL (bukan bulat)
// ==============================================================================
/// Widget oval untuk menampilkan statistik dengan warna biru cerah
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

// ==============================================================================
// MENU GRID - Widget untuk menampilkan grid menu
// ==============================================================================
/// Widget GridView untuk menu mini soccer
class MenuGrid extends StatelessWidget {
  final List<Map<String, dynamic>> menuItems;

  const MenuGrid({
    super.key,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return MenuGridItem(
          icon: item['icon'],
          label: item['label'],
          color: item['color'],
          onTap: () {
            // Handle tap untuk setiap menu
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Anda memilih ${item['label']}'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        );
      },
    );
  }
}

// ==============================================================================
// MENU GRID ITEM - Widget untuk item individual di grid
// ==============================================================================
/// Widget individual item dalam grid menu
class MenuGridItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const MenuGridItem({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),

            // Label
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ==============================================================================
// STAR PLUS BUTTON - Custom widget dengan star shape decorator
// ==============================================================================
/// Widget button berbentuk star dengan plus sign di tengah dan teks di bawah
class StarPlusButton extends StatelessWidget {
  final VoidCallback onPressed;

  const StarPlusButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Star shape background - WARNA BIRU
              CustomPaint(
                painter: StarPainter(
                  color: const Color(0xFF4A6FA5),
                  size: 100,
                ),
                size: const Size(100, 100),
              ),
              // Plus icon
              Text(
                '+',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Teks Tambah Booking
          Text(
            'Tambah Booking',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4A6FA5),
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================================================
// STAR PAINTER - CustomPainter untuk membentuk star shape dengan concave sides
// ==============================================================================
/// Custom painter untuk menggambar star shape 4-pointed dengan concave sides
class StarPainter extends CustomPainter {
  final Color color;
  final double size;

  StarPainter({
    required this.color,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    // Membuat 4-pointed star dengan concave sides
    // Top point
    path.moveTo(centerX, centerY - radius);

    // Top right curve
    path.quadraticBezierTo(
      centerX + radius * 0.4,
      centerY - radius * 0.4,
      centerX + radius,
      centerY,
    );

    // Right bottom curve
    path.quadraticBezierTo(
      centerX + radius * 0.4,
      centerY + radius * 0.4,
      centerX,
      centerY + radius,
    );

    // Bottom left curve
    path.quadraticBezierTo(
      centerX - radius * 0.4,
      centerY + radius * 0.4,
      centerX - radius,
      centerY,
    );

    // Left top curve
    path.quadraticBezierTo(
      centerX - radius * 0.4,
      centerY - radius * 0.4,
      centerX,
      centerY - radius,
    );

    path.close();

    canvas.drawPath(path, paint);

    // Optional: Draw border
    final borderPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(StarPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.size != size;
}

// ==============================================================================
// ADD BOOKING PAGE - Halaman dummy untuk tambah booking
// ==============================================================================
/// Halaman dummy untuk tambah booking
class AddBookingPage extends StatelessWidget {
  const AddBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A6FA5),
        title: Text(
          'Tambah Booking',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Form Booking Lapangan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Halaman ini masih dalam pengembangan. Silakan kembali ke dashboard.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A6FA5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Kembali ke Dashboard',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}    