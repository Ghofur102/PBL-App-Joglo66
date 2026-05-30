import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/services/booking_service.dart';
import 'package:pbl_app_joglo66/components/detail_row.dart';
import 'package:pbl_app_joglo66/components/session_card.dart';

class BookingDetailsAdminScreen extends StatefulWidget {
  final String bookingId;
  const BookingDetailsAdminScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailsAdminScreen> createState() => _BookingDetailsAdminScreenState();
}

class _BookingDetailsAdminScreenState extends State<BookingDetailsAdminScreen> {
  Map<String, dynamic>? bookingData;
  bool isLoading = true;
  String errorMessage = '';

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
          bookingData = data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)))
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    final formatRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final sessions = (bookingData!['sessions'] as List?) ?? [];
    final userInfo = bookingData!['user_info'];
    final fieldInfo = bookingData!['field_info'];
    final paymentInfo = bookingData!['payment_details'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(userInfo, fieldInfo, paymentInfo, formatRp),
          const SizedBox(height: 24),
          const Text('Daftar Sesi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...sessions.map((session) => SessionCard(
                session: session,
                fieldName: fieldInfo['name'],
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
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informasi Pelanggan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),
          DetailRow(label: 'Nama', value: user['name']),
          DetailRow(label: 'Tim', value: user['team_name']),
          DetailRow(label: 'Kontak', value: '${user['phone']}'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
          const Text('Informasi Lapangan & Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 12),
          DetailRow(label: 'Lapangan', value: field['name'], isBoldValue: true),
          DetailRow(label: 'Total Tagihan', value: formatRp.format(payment['total_price'])),
          DetailRow(label: 'Total Dibayar', value: formatRp.format(payment['total_paid'])),
          DetailRow(label: 'Metode', value: payment['payment_method'].toString().toUpperCase()),
        ],
      ),
    );
  }
}