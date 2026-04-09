import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_details_admin_screens.dart';

class ListBookingAdminScreens extends StatefulWidget {
  const ListBookingAdminScreens({super.key});

  @override
  State<ListBookingAdminScreens> createState() => _ListBookingAdminScreensState();
}

class _ListBookingAdminScreensState extends State<ListBookingAdminScreens> {
  // Dummy data untuk booking
  final List<Map<String, String>> todayBookings = [
    {
      'date': '06',
      'month': 'Mar',
      'year': '2026',
      'title': 'Putra Zeus (Danil)',
      'time': '13.00 - 15.00',
      'description': 'Booking lapangan mini soccer A dengan durasi 2 jam',
    },
    {
      'date': '06',
      'month': 'Mar',
      'year': '2026',
      'title': 'Byteforce (Stefano)',
      'time': '19.00 - 21.00',
      'description': 'Booking lapangan mini soccer B dengan durasi 2 jam',
    },
  ];

  final List<Map<String, String>> upcomingBookings = [
    {
      'date': '07',
      'month': 'Mar',
      'year': '2026',
      'title': 'JBI (Nunun)',
      'time': '13.00 - 15.00',
      'description': 'Booking lapangan mini soccer A dengan durasi 2 jam',
    },
    {
      'date': '08',
      'month': 'Mar',
      'year': '2026',
      'title': 'PAIPAMA (Vicky)',
      'time': '19.00 - 21.00',
      'description': 'Booking lapangan mini soccer C dengan durasi 2 jam',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFEEEEEE),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              // Header text
              const SizedBox(height: 16),
              Text(
                'Halaman daftar booking zami',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),

              // Search dan Filter
              Row(
                children: [
                  // Search field
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari booking...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          prefixIcon: const Icon(Icons.search, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Calendar filter icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFDADADA),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: const Color(0xFF4A6FA5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section Booking Hari Ini
              SectionTitle(title: 'Hari Ini'),
              const SizedBox(height: 8),
              ...todayBookings
                  .map((booking) => BookingItem(
                        booking: booking,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BookingDetailsAdminScreen(),
                            ),
                          );
                        },
                      ))
                  ,

              const SizedBox(height: 24),

              // Section Booking Mendatang
              SectionTitle(title: 'Mendatang'),
              const SizedBox(height: 8),
              ...upcomingBookings
                  .map((booking) => BookingItem(
                        booking: booking,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BookingDetailsAdminScreen(),
                            ),
                          );
                        },
                      ))
                  ,

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ==============================================================================
// SECTION TITLE - Reusable widget untuk judul section
// ==============================================================================
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}

// ==============================================================================
// BOOKING ITEM - Reusable widget untuk card booking
// ==============================================================================
class BookingItem extends StatelessWidget {
  final Map<String, String> booking;
  final VoidCallback onTap;

  const BookingItem({
    super.key,
    required this.booking,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFDADADA),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Kiri: Tanggal
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${booking['date']} ${booking['month']}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF757575),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  booking['year']!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF757575),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),

            // Tengah: Title dan Time
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking['title']!,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking['time']!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFFE53935),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Kanan: Arrow icon
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF9E9E9E),
            ),
          ],
        ),
      ),
    );
  }
}