import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/services/booking_service.dart';
class ListClosedBookingAdminScreens extends StatefulWidget {
  const ListClosedBookingAdminScreens({super.key});

  @override
  State<ListClosedBookingAdminScreens> createState() =>
      _ListClosedBookingAdminScreensState();
}

class _ListClosedBookingAdminScreensState
    extends State<ListClosedBookingAdminScreens> {
  String _activeTab = 'needs_action';

  List<dynamic> _allBookings = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchClosedBookings();
  }

  // Fungsi untuk memanggil API Laravel
  Future<void> _fetchClosedBookings() async {
    try {
      // Cukup panggil 1 baris dari Service!
      final responseData = await BookingService.fetchClosedBookings();

      if (mounted) {
        setState(() {
          // Ambil array 'data' dari hasil paginasi
          _allBookings = responseData['data']; 
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

  // Fungsi Pemisah Kategori: Needs Action vs History
  String _determineStatus(String playDateStr) {
    try {
      final playDate = DateTime.parse(playDateStr);
      final today = DateTime.now();
      
      // Kita hilangkan jam/menit/detik dari today agar perbandingan tanggalnya akurat
      final todayDateOnly = DateTime(today.year, today.month, today.day);
      final playDateOnly = DateTime(playDate.year, playDate.month, playDate.day);

      // Jika tanggal main sudah lewat, masuk History. Jika hari ini atau besok, Needs Action.
      if (playDateOnly.isBefore(todayDateOnly)) {
        return 'history';
      } else {
        return 'needs_action';
      }
    } catch (e) {
      return 'history'; // Fallback jika format tanggal salah
    }
  }

  // Fungsi untuk membuat item list
  Widget bookingItem({
    required String id,
    required String date,
    required String name,
    required String fieldName,
    String? time,
  }) {
    return InkWell(
      onTap: () {
        // Mengarahkan ke halaman detail spesifik
        context.push('/admin/booking-detail/$id');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                date,
                style: const TextStyle(
                  fontSize: 12, 
                  color: Colors.black54,
                  fontWeight: FontWeight.w600
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF406093),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Menampilkan nama lapangan agar admin tidak bingung
                  Text(
                    fieldName,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  if (time != null)
                    Text(
                      time,
                      style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Filter data berdasarkan Tab yang sedang aktif
    final filteredBookings = _allBookings.where((booking) {
      final status = _determineStatus(booking['play_date']);
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
          color: Color(0xFFF5F7FA), // Warna background yang lebih modern
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Icon Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, size: 40, color: Colors.red),
              ),
              const SizedBox(height: 20),

              // Tab Section
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

              // List Section
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
                                  
                                  // Formatting Date (YYYY-MM-DD to DD MMM YYYY)
                                  String formattedDate = booking['play_date'];
                                  try {
                                    final dateObj = DateTime.parse(booking['play_date']);
                                    formattedDate = DateFormat('dd MMM yyyy').format(dateObj);
                                  } catch (e) {}

                                  // Formatting Time
                                  String time = '${booking['start_play_time'].toString().substring(0,5)} - ${booking['end_play_time'].toString().substring(0,5)}';

                                  // Ambil nama user dari relasi (bisa menyesuaikan jika relasinya null)
                                  String userName = booking['booking']?['user']?['name'] ?? 'Penyewa Anonim';
                                  
                                  // Ambil nama lapangan dari relasi
                                  String fieldName = booking['booking']?['field']?['name'] ?? 'Lapangan Tidak Diketahui';

                                  return bookingItem(
                                    id: booking['id'].toString(),
                                    date: formattedDate,
                                    name: userName,
                                    fieldName: fieldName,
                                    time: time,
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