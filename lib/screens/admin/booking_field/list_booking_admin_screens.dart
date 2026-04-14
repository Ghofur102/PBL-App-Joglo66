import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbl_app_joglo66/components/cards_booking.dart';
import 'package:pbl_app_joglo66/components/header_one.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/services/dashboard_service.dart';

class ListBookingAdminScreens extends StatefulWidget {
  const ListBookingAdminScreens({super.key});

  @override
  State<ListBookingAdminScreens> createState() =>
      _ListBookingAdminScreensState();
}

class _ListBookingAdminScreensState extends State<ListBookingAdminScreens> {
  // State variables
  List<Map<String, dynamic>> todayBookings = [];
  List<Map<String, dynamic>> upcomingBookings = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBookingData();
  }

  /// Fetch booking data dari API
  Future<void> _loadBookingData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final data = await DashboardService.fetchBookings();
      
      setState(() {
        todayBookings = List<Map<String, dynamic>>.from(data['today'] ?? []);
        upcomingBookings = List<Map<String, dynamic>>.from(data['upcoming'] ?? []);
        isLoading = false;
      });

      print('[ListBooking] Data loaded successfully');
    } catch (e) {
      print('[ListBooking] Error loading data: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

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
        body: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Memuat data booking...'),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView(
                  children: [
                    // Error message jika ada
                    if (errorMessage != null)
                      Container(
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(top: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Peringatan',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              errorMessage ?? '',
                              style: TextStyle(fontSize: 12),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _loadBookingData,
                              icon: Icon(Icons.refresh, size: 16),
                              label: Text('Coba Lagi'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Search dan Filter
                    const SizedBox(height: 20),
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
                    if (todayBookings.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HeaderOne(title: 'Hari Ini'),
                          const SizedBox(height: 8),
                          ...todayBookings.map(
                            (booking) => CardsBooking(
                              booking: {
                                'detailBookingId': booking['id'].toString(),
                                'date': booking['date'],
                                'month': booking['month'],
                                'year': booking['year'],
                                'title': booking['title'],
                                'time': booking['time'],
                                'description': booking['description'],
                                'status': booking['status'],
                              },
                              onTap: () {
                                context.push(
                                  '/admin/booking-detail/${booking['id']}',
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),

                    // Section Booking Mendatang
                    if (upcomingBookings.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HeaderOne(title: 'Mendatang'),
                          const SizedBox(height: 8),
                          ...upcomingBookings.map(
                            (booking) => CardsBooking(
                              booking: {
                                'detailBookingId': booking['id'].toString(),
                                'date': booking['date'],
                                'month': booking['month'],
                                'year': booking['year'],
                                'title': booking['title'],
                                'time': booking['time'],
                                'description': booking['description'],
                                'status': booking['status'],
                              },
                              onTap: () {
                                context.push(
                                  '/admin/booking-detail/${booking['id']}',
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),

                    // Empty state
                    if (todayBookings.isEmpty && upcomingBookings.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Tidak ada booking',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
