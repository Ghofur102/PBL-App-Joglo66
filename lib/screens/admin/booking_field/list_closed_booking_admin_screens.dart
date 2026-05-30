import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/services/booking_service.dart';
import 'package:pbl_app_joglo66/components/cards_booking.dart';

class ListClosedBookingAdminScreens extends StatefulWidget {
  const ListClosedBookingAdminScreens({super.key});

  @override
  State<ListClosedBookingAdminScreens> createState() => _ListClosedBookingAdminScreensState();
}

class _ListClosedBookingAdminScreensState extends State<ListClosedBookingAdminScreens> {
  String _activeTab = 'needs_action';
  List<dynamic> _allBookings = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchClosedBookings();
  }

  Future<void> _fetchClosedBookings() async {
    try {
      final responseData = await BookingService.fetchClosedBookings();
      if (mounted) {
        setState(() {
          _allBookings = responseData['data'] ?? responseData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _determineStatus(String status) {
    final s = status.toLowerCase();
    if (s == 'closed field cancelled' || s == 'closed field reschedule') {
      return 'history';
    }
    return 'needs_action';
  }

  @override
  Widget build(BuildContext context) {
    final filteredBookings = _allBookings.where((booking) {
      final status = _determineStatus(booking['status'] ?? '');
      return status == _activeTab;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF406093),
      appBar: AppBar(
        title: const Text(
          "Closed Bookings",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF406093),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/admin/dashboard');
            }
          },
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFFF5F7FA),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.red),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = 'needs_action'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _activeTab == 'needs_action' ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: _activeTab == 'needs_action'
                                ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              "Needs Action",
                              style: TextStyle(
                                color: _activeTab == 'needs_action' ? Colors.black : Colors.black54,
                                fontWeight: _activeTab == 'needs_action' ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _activeTab = 'history'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _activeTab == 'history' ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: _activeTab == 'history'
                                ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                                : [],
                          ),
                          child: Center(
                            child: Text(
                              "History",
                              style: TextStyle(
                                color: _activeTab == 'history' ? Colors.black : Colors.black54,
                                fontWeight: _activeTab == 'history' ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage.isNotEmpty
                        ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center))
                        : filteredBookings.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_circle_outline, size: 60, color: Colors.grey[400]),
                                    const SizedBox(height: 16),
                                    Text(
                                      _activeTab == 'needs_action'
                                          ? "Semua aman! Tidak ada tindakan tertunda."
                                          : "Belum ada riwayat penutupan lapangan.",
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredBookings.length,
                                itemBuilder: (context, index) {
                                  final booking = filteredBookings[index];
                                  String dateDay = '';
                                  String dateMonth = '';
                                  String dateYear = '';

                                  try {
                                    final dateObj = DateTime.parse(booking['play_date']);
                                    dateDay = DateFormat('dd').format(dateObj);
                                    dateMonth = DateFormat('MMM').format(dateObj);
                                    dateYear = DateFormat('yyyy').format(dateObj);
                                  } catch (_) {}

                                  String time = '${booking['start_play_time'].toString().substring(0, 5)} - ${booking['end_play_time'].toString().substring(0, 5)}';
                                  String userName = booking['booking']?['user']?['name'] ?? 'Penyewa';
                                  String teamName = booking['booking']?['team_name'] ?? userName;
                                  String fieldName = booking['booking']?['field']?['name'] ?? 'Lapangan';

                                  final cardData = {
                                    'date': dateDay,
                                    'month': dateMonth,
                                    'year': dateYear,
                                    'title': teamName,
                                    'status': booking['status'].toString(),
                                    'time': time,
                                    'description': fieldName,
                                  };

                                  return CardsBooking(
                                    booking: cardData,
                                    onTap: () {
                                      context.push('/admin/booking-detail/${booking['id']}');
                                    },
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}