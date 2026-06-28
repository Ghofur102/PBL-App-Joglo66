import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/components/detail_row.dart';
import 'package:pbl_app_joglo66/components/session_card.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/booking_service.dart';

class BookingDetailsAdminScreen extends StatefulWidget {
  final String bookingId;
  const BookingDetailsAdminScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailsAdminScreen> createState() => _BookingDetailsAdminScreenState();
}

class _BookingDetailsAdminScreenState extends State<BookingDetailsAdminScreen> {
  Map<String, dynamic>? _bookingData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchBookingDetail();
  }

  Future<void> _fetchBookingDetail() async {
    try {
      final data = await BookingService.fetchBookingDetail(widget.bookingId);
      if (mounted) {
        setState(() {
          _bookingData = data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeConstants.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppThemeConstants.textPrimary),
          onPressed: () => context.canPop() ? context.pop() : context.go('/admin/dashboard'),
        ),
        title: const Text('Detail Pesanan', style: TextStyle(color: AppThemeConstants.textPrimary, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppThemeConstants.primaryBlue))
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: AppThemeConstants.errorRed)))
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    final formatRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final sessions = (_bookingData!['sessions'] as List?) ?? [];
    final userInfo = _bookingData!['user_info'] as Map<String, dynamic>? ?? {};
    final fieldInfo = _bookingData!['field_info'] as Map<String, dynamic>? ?? {};
    final paymentInfo = _bookingData!['payment_details'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(userInfo, fieldInfo, paymentInfo, formatRp),
          const SizedBox(height: 24),
          const Text('Daftar Sesi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary)),
          const SizedBox(height: 12),
          ...sessions.map((session) => SessionCard(
                session: session as Map<String, dynamic>,
                fieldName: fieldInfo['name']?.toString() ?? '-',
              )),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> user, Map<String, dynamic> field, Map<String, dynamic> payment, NumberFormat formatRp) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppThemeConstants.radiusLarge),
        border: Border.all(color: AppThemeConstants.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informasi Pelanggan', style: TextStyle(fontWeight: FontWeight.bold, color: AppThemeConstants.textSecondary)),
          const SizedBox(height: 12),
          DetailRow(label: 'Nama', value: user['name']?.toString() ?? '-'),
          DetailRow(label: 'Tim', value: user['team_name']?.toString() ?? '-'),
          DetailRow(label: 'Kontak', value: user['phone']?.toString() ?? '-'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: AppThemeConstants.borderGrey)),
          const Text('Informasi Lapangan & Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, color: AppThemeConstants.textSecondary)),
          const SizedBox(height: 12),
          DetailRow(label: 'Lapangan', value: field['name']?.toString() ?? '-', isBoldValue: true),
          DetailRow(label: 'Total Tagihan', value: formatRp.format(int.tryParse(payment['total_price']?.toString() ?? '0') ?? 0)),
          DetailRow(label: 'Total Dibayar', value: formatRp.format(int.tryParse(payment['total_paid']?.toString() ?? '0') ?? 0)),
          DetailRow(label: 'Metode', value: payment['payment_method'].toString().toUpperCase()),
        ],
      ),
    );
  }
}
