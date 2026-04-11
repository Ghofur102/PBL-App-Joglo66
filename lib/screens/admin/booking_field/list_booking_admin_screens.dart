import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbl_app_joglo66/components/cards_booking.dart';
import 'package:pbl_app_joglo66/components/header_one.dart';
import 'package:go_router/go_router.dart';

class ListBookingAdminScreens extends StatefulWidget {
  const ListBookingAdminScreens({super.key});

  @override
  State<ListBookingAdminScreens> createState() =>
      _ListBookingAdminScreensState();
}

class _ListBookingAdminScreensState extends State<ListBookingAdminScreens> {
  // Dummy data untuk booking
  final List<Map<String, String>> todayBookings = [
    {
      'detailBookingId': '1',
      'date': '06',
      'month': 'Mar',
      'year': '2026',
      'title': 'Putra Zeus (Danil)',
      'time': '13.00 - 15.00',
      'description': 'Booking lapangan mini soccer A dengan durasi 2 jam',
    },
  ];

  final List<Map<String, String>> upcomingBookings = [
    {
      'detailBookingId': '2',
      'date': '07',
      'month': 'Mar',
      'year': '2026',
      'title': 'JBI (Nunun)',
      'time': '13.00 - 15.00',
      'description': 'Booking lapangan mini soccer A dengan durasi 2 jam',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
          title: Text(
            'List Booking',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFEEEEEE),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              // Search dan Filter
              const SizedBox(height: 20,),
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
              HeaderOne(title: 'Hari Ini'),
              const SizedBox(height: 8),
              ...todayBookings.map(
                (booking) => CardsBooking(
                  booking: booking,
                  onTap: () {
                    context.push(
                      '/admin/booking-detail/${booking['detailBookingId']}',
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Section Booking Mendatang
              HeaderOne(title: 'Mendatang'),
              const SizedBox(height: 8),
              ...upcomingBookings.map(
                (booking) => CardsBooking(
                  booking: booking,
                  onTap: () {
                    context.push(
                      '/admin/booking-detail/${booking['detailBookingId']}',
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
