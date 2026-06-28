import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/components/booking_card.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/booking_service.dart';

class ListBookingAdminScreen extends StatefulWidget {
  const ListBookingAdminScreen({super.key});

  @override
  State<ListBookingAdminScreen> createState() => _ListBookingAdminScreensState();
}

class _ListBookingAdminScreensState extends State<ListBookingAdminScreen> {
  List<Map<String, dynamic>> _todayBookings = [];
  List<Map<String, dynamic>> _upcomingBookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
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
        _isLoading = true;
        _errorMessage = null;
      });

      final String? startDateStr = _selectedDateRange != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDateRange!.start)
          : null;
      final String? endDateStr = _selectedDateRange != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDateRange!.end)
          : null;

      final data = await BookingService.fetchListBooking(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        startDate: startDateStr,
        endDate: endDateStr,
      );

      if (mounted) {
        setState(() {
          _todayBookings = List<Map<String, dynamic>>.from(data['today'] ?? []);
          _upcomingBookings = List<Map<String, dynamic>>.from(data['upcoming'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
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

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppThemeConstants.accentBlue,
            onPrimary: Colors.white,
            onSurface: AppThemeConstants.textPrimary,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _loadBookingData();
    }
  }

  String _getHeaderTitle() {
    if (_selectedDateRange == null) return 'Hari Ini';
    if (_selectedDateRange!.start == _selectedDateRange!.end) {
      return DateFormat('dd MMM yyyy').format(_selectedDateRange!.start);
    }
    final String startStr = DateFormat('dd MMM').format(_selectedDateRange!.start);
    final String endStr = DateFormat('dd MMM yyyy').format(_selectedDateRange!.end);
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
            icon: const Icon(Icons.arrow_back, color: AppThemeConstants.textPrimary),
            onPressed: () async {
              ScaffoldMessenger.of(context).clearSnackBars();
              await Future.delayed(const Duration(milliseconds: 50));
              if (!context.mounted) return;
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/admin/dashboard');
              }
            },
          ),
          title: const Text('List Booking', style: TextStyle(color: AppThemeConstants.textPrimary, fontWeight: FontWeight.bold)),
        ),
        backgroundColor: AppThemeConstants.bgLight,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(AppThemeConstants.radiusMedium),
                        border: Border.all(color: AppThemeConstants.borderGrey),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Cari nama tim/penyewa...',
                          hintStyle: GoogleFonts.poppins(fontSize: 12, color: AppThemeConstants.textSecondary),
                          prefixIcon: const Icon(Icons.search, size: 20, color: AppThemeConstants.textSecondary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                        ),
                        style: GoogleFonts.poppins(fontSize: 12, color: AppThemeConstants.textPrimary),
                      ),
                    ),
                  ),
                  if (_selectedDateRange != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() { _selectedDateRange = null; });
                        _loadBookingData();
                      },
                      child: Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: AppThemeConstants.lightRed,
                          borderRadius: BorderRadius.circular(AppThemeConstants.radiusMedium),
                          border: Border.all(color: AppThemeConstants.errorRed.withOpacity(0.3)),
                        ),
                        child: const Center(child: Icon(Icons.close, size: 20, color: AppThemeConstants.errorRed)),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _pickDateRange,
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: _selectedDateRange != null ? AppThemeConstants.accentBlue : Colors.white,
                        borderRadius: BorderRadius.circular(AppThemeConstants.radiusMedium),
                        border: Border.all(color: _selectedDateRange != null ? AppThemeConstants.accentBlue : AppThemeConstants.borderGrey),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.date_range,
                          size: 20,
                          color: _selectedDateRange != null ? Colors.white : AppThemeConstants.accentBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue))
                  : _buildBookingList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingList() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: AppThemeConstants.lightAmber, borderRadius: BorderRadius.circular(8)),
            child: Text(_errorMessage!, style: const TextStyle(color: AppThemeConstants.warningAmber, fontSize: 13)),
          ),
        if (_todayBookings.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_getHeaderTitle(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary)),
              const SizedBox(height: 8),
              ..._todayBookings.map((booking) => BookingCard(
                    booking: booking,
                    onTap: () => context.push('/admin/booking-detail/${booking['id']}'),
                  )),
              const SizedBox(height: 24),
            ],
          ),
        if (_upcomingBookings.isNotEmpty && _selectedDateRange == null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mendatang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary)),
              const SizedBox(height: 8),
              ..._upcomingBookings.map((booking) => BookingCard(
                    booking: booking,
                    onTap: () => context.push('/admin/booking-detail/${booking['id']}'),
                  )),
              const SizedBox(height: 32),
            ],
          ),
        if (_todayBookings.isEmpty && _upcomingBookings.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isEmpty && _selectedDateRange == null
                        ? 'Belum ada jadwal booking'
                        : 'Booking tidak ditemukan',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
