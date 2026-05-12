import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/components/cards_booking.dart';
import 'package:pbl_app_joglo66/components/header_one.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/services/booking_service.dart';

class ListBookingAdminScreens extends StatefulWidget {
  const ListBookingAdminScreens({super.key});

  @override
  State<ListBookingAdminScreens> createState() =>
      _ListBookingAdminScreensState();
}

class _ListBookingAdminScreensState extends State<ListBookingAdminScreens> {
  List<Map<String, dynamic>> todayBookings = [];
  List<Map<String, dynamic>> upcomingBookings = [];
  bool isLoading = true;
  String? errorMessage;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  
  // --- MENGGUNAKAN DATETIMERANGE BUKAN DATETIME ---
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _loadBookingData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadBookingData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // --- PECAH RENTANG TANGGAL MENJADI START DAN END ---
      String? startDateStr = _selectedDateRange != null 
          ? DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start) 
          : null;
      String? endDateStr = _selectedDateRange != null 
          ? DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end) 
          : null;

      final data = await BookingService.fetchListBooking(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        startDate: startDateStr,
        endDate: endDateStr,
      );

      if (mounted) {
        setState(() {
          todayBookings = List<Map<String, dynamic>>.from(data['today'] ?? []);
          upcomingBookings = List<Map<String, dynamic>>.from(
            data['upcoming'] ?? [],
          );
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString().replaceAll('Exception: ', '');
          isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _loadBookingData();
    });
  }

  // --- MEMANGGIL RENTANG TANGGAL (DATE RANGE PICKER) ---
  Future<void> _pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF406093),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _loadBookingData();
    }
  }

  // Fungsi dinamis untuk mencetak Header Text
  String _getHeaderTitle() {
    if (_selectedDateRange == null) return 'Hari Ini';
    
    // Jika hanya milih 1 tanggal di kalender (misal: 12 Apr - 12 Apr)
    if (_selectedDateRange!.start == _selectedDateRange!.end) {
      return DateFormat('dd MMM yyyy').format(_selectedDateRange!.start);
    }
    
    // Jika milih rentang (misal: 12 Apr - 16 Apr 2026)
    String startStr = DateFormat('dd MMM').format(_selectedDateRange!.start);
    String endStr = DateFormat('dd MMM yyyy').format(_selectedDateRange!.end);
    return '$startStr - $endStr';
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
            // 1. Tambahkan 'async' di sini
            onPressed: () async { 
              // Bersihkan snackbar
              ScaffoldMessenger.of(context).clearSnackBars();

              // 2. Gunakan 'await' pada Future.delayed
              await Future.delayed(const Duration(milliseconds: 50));

              // 3. INI KUNCI PENGHILANG GARIS BIRU: Cek context.mounted
              if (!context.mounted) return;

              // Sekarang aman memanggil context apapun
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/admin/dashboard'); 
              }
            },
          ),
          title: const Text(
            'List Booking',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: const Color(0xFFEEEEEE),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Cari nama tim/penyewa...',
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
                  
                  if (_selectedDateRange != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDateRange = null; 
                        });
                        _loadBookingData(); 
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.shade300, width: 1),
                        ),
                        child: const Center(
                          child: Icon(Icons.close, size: 20, color: Colors.red),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(width: 8),

                  GestureDetector(
                    onTap: _pickDateRange, // Panggil pop-up Date Range Picker
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _selectedDateRange != null ? const Color(0xFF406093) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _selectedDateRange != null ? const Color(0xFF406093) : const Color(0xFFDADADA),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.date_range, // Icon juga diubah agar lebih merepresentasikan Range
                          size: 20,
                          color: _selectedDateRange != null ? Colors.white : const Color(0xFF4A6FA5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Memuat data booking...'),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        if (errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Peringatan',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  errorMessage ?? '',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: _loadBookingData,
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text('Coba Lagi'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (todayBookings.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HeaderOne(
                                title: _getHeaderTitle(), // Judul dinamis (Rentang Tanggal)
                              ),
                              const SizedBox(height: 8),
                              ...todayBookings.map(
                                (booking) => CardsBooking(
                                  booking: {
                                    'date': booking['date']?.toString() ?? '',
                                    'month': booking['month']?.toString() ?? '',
                                    'year': booking['year']?.toString() ?? '',
                                    'title': booking['title']?.toString() ?? '',
                                    'time': booking['time']?.toString() ?? '',
                                    'description':
                                        booking['description']?.toString() ??
                                        '',
                                    'status':
                                        booking['status']?.toString() ??
                                        'Unknown',
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

                        if (upcomingBookings.isNotEmpty && _selectedDateRange == null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              HeaderOne(title: 'Mendatang'),
                              const SizedBox(height: 8),
                              ...upcomingBookings.map(
                                (booking) => CardsBooking(
                                  booking: {
                                    'date': booking['date']?.toString() ?? '',
                                    'month': booking['month']?.toString() ?? '',
                                    'year': booking['year']?.toString() ?? '',
                                    'title': booking['title']?.toString() ?? '',
                                    'time': booking['time']?.toString() ?? '',
                                    'description':
                                        booking['description']?.toString() ??
                                        '',
                                    'status':
                                        booking['status']?.toString() ??
                                        'Unknown',
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

                        if (todayBookings.isEmpty && upcomingBookings.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.search_off_rounded,
                                    size: 60,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchController.text.isEmpty && _selectedDateRange == null
                                        ? 'Belum ada jadwal booking'
                                        : 'Booking tidak ditemukan',
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
          ],
        ),
      ),
    );
  }
}