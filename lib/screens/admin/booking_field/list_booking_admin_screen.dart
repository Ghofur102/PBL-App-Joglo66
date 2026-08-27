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
  State<ListBookingAdminScreen> createState() => _ListBookingAdminScreenState();
}

class _ListBookingAdminScreenState extends State<ListBookingAdminScreen> {
  List<Map<String, dynamic>> _groupedBookings = [];
  int _closedAffectedCount = 0;
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
        final rawGroups = data['grouped_bookings'] as List<dynamic>? ?? [];
        setState(() {
          _groupedBookings = rawGroups
              .map((g) => Map<String, dynamic>.from(g as Map))
              .toList();
          _closedAffectedCount = int.tryParse(data['closed_affected_count']?.toString() ?? '0') ?? 0;
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
          title: const Text(
            'List Booking',
            style: TextStyle(color: AppThemeConstants.textPrimary, fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: AppThemeConstants.bgLight,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
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
                        setState(() {
                          _selectedDateRange = null;
                        });
                        _loadBookingData();
                      },
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppThemeConstants.lightRed,
                          borderRadius: BorderRadius.circular(AppThemeConstants.radiusMedium),
                          border: Border.all(color: AppThemeConstants.errorRed.withOpacity(0.3)),
                        ),
                        child: const Center(
                          child: Icon(Icons.close, size: 20, color: AppThemeConstants.errorRed),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _pickDateRange,
                    child: Container(
                      width: 42,
                      height: 42,
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
            _buildClosureBanner(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue))
                  : RefreshIndicator(
                      onRefresh: _loadBookingData,
                      color: AppThemeConstants.primaryBlue,
                      child: _buildBookingList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClosureBanner() {
    final bool hasAffected = _closedAffectedCount > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/admin/list-closed-booking').then((_) => _loadBookingData()),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: hasAffected ? AppThemeConstants.lightRed : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasAffected ? AppThemeConstants.errorRed : AppThemeConstants.borderGrey,
                width: hasAffected ? 1.2 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasAffected ? Icons.warning_amber_rounded : Icons.history_toggle_off_rounded,
                  color: hasAffected ? AppThemeConstants.errorRed : AppThemeConstants.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasAffected
                        ? 'Terdampak Penutupan Lapangan'
                        : 'Riwayat Booking Lapangan Tutup',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: hasAffected ? AppThemeConstants.errorRed : AppThemeConstants.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: hasAffected ? AppThemeConstants.errorRed : AppThemeConstants.borderGrey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_closedAffectedCount Booking',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: hasAffected ? Colors.white : AppThemeConstants.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: hasAffected ? AppThemeConstants.errorRed : AppThemeConstants.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingList() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            _errorMessage!,
            style: const TextStyle(color: AppThemeConstants.errorRed),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_groupedBookings.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _searchController.text.isEmpty && _selectedDateRange == null
                        ? 'Belum ada jadwal booking'
                        : 'Booking tidak ditemukan',
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _groupedBookings.length,
      itemBuilder: (context, groupIndex) {
        final group = _groupedBookings[groupIndex];
        final String dateLabel = group['date_label'] ?? '';
        final List<dynamic> bookingsRaw = group['bookings'] ?? [];
        final List<Map<String, dynamic>> bookings = bookingsRaw
            .map((b) => Map<String, dynamic>.from(b as Map))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text(
                dateLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppThemeConstants.textPrimary,
                ),
              ),
            ),
            ...bookings.map(
              (booking) => BookingCard(
                booking: booking,
                onTap: () => context
                    .push('/admin/booking-detail/${booking['id']}')
                    .then((_) => _loadBookingData()),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
