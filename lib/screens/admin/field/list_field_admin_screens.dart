import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/services/dashboard_service.dart';
import 'package:pbl_app_joglo66/components/cards_booking.dart';
import 'package:pbl_app_joglo66/components/header_one.dart';

class ListFieldAdminScreens extends StatefulWidget {
  const ListFieldAdminScreens({super.key});

  @override
  State<ListFieldAdminScreens> createState() => _ListFieldAdminScreensState();
}

class _ListFieldAdminScreensState extends State<ListFieldAdminScreens> {
  // State variables
  List<Map<String, dynamic>> todayFields = [];
  List<Map<String, dynamic>> upcomingFields = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFieldData();
  }

  /// Fetch field booking data dari API
  Future<void> _loadFieldData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final data = await DashboardService.fetchFields();
      
      // fetchFields returns List, but we want to split into today/upcoming
      // We'll call fetchBookings instead to get proper structure
      final bookingData = await DashboardService.fetchBookings();
      
      setState(() {
        todayFields = List<Map<String, dynamic>>.from(bookingData['today'] ?? []);
        upcomingFields = List<Map<String, dynamic>>.from(bookingData['upcoming'] ?? []);
        isLoading = false;
      });

      print('[ListField] Data loaded successfully');
    } catch (e) {
      print('[ListField] Error loading data: $e');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Widget cardLapangan(BuildContext context, Map<String, dynamic> data) {
    return CardsBooking(
      booking: {
        'date': data['date']?.toString() ?? '',
        'month': data['month']?.toString() ?? '',
        'year': data['year']?.toString() ?? '',
        'title': data['title']?.toString() ?? '',
        'time': data['time']?.toString() ?? '',
        'description': data['description']?.toString() ?? '',
      },
      onTap: () {
        context.push('/admin/booking-detail/${data['id']}');
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'waiting':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'finish':
        return Colors.blue;
      case 'reschedule':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
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
          'Daftar Lapangan',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data lapangan...'),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  // Error message jika ada
                  if (errorMessage != null)
                    Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 16),
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
                            onPressed: _loadFieldData,
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

                  // Hari Ini Section
                  if (todayFields.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hari Ini',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        ...todayFields.map((field) => cardLapangan(context, field)),
                        SizedBox(height: 24),
                      ],
                    ),

                  // Mendatang Section
                  if (upcomingFields.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mendatang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        ...upcomingFields.map((field) => cardLapangan(context, field)),
                      ],
                    ),

                  // Empty state
                  if (todayFields.isEmpty && upcomingFields.isEmpty)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.sports_soccer,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Tidak ada data lapangan',
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
    );
  }
}