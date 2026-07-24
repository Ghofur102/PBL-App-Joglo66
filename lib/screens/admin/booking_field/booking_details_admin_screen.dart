import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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

    return RefreshIndicator(
      onRefresh: _fetchBookingDetail,
      color: AppThemeConstants.primaryBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(userInfo, fieldInfo, paymentInfo, formatRp),
            const SizedBox(height: 24),
            const Text('Daftar Sesi Jadwal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary)),
            const SizedBox(height: 4),
            const Text('*Klik pada kartu sesi untuk memproses modifikasi, reschedule, atau pelunasan kasir.', style: TextStyle(fontSize: 11, color: AppThemeConstants.textSecondary, fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),

            ...sessions.map((sessionItem) {
              final session = sessionItem as Map<String, dynamic>;
              return _buildSessionCard(session, formatRp);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session, NumberFormat formatRp) {
    final int remainingPayment = int.tryParse(session['remaining_payment']?.toString() ?? '0') ?? 0;
    final bool isLunas = remainingPayment <= 0;
    final String opStatus = (session['status'] ?? 'WAITING').toString().toUpperCase();

    Color opBadgeColor = AppThemeConstants.warningAmber;
    Color opBgColor = AppThemeConstants.lightAmber;
    if (opStatus == 'ACTIVE') {
      opBadgeColor = AppThemeConstants.successGreen;
      opBgColor = AppThemeConstants.lightGreen;
    } else if (opStatus.contains('CANCEL')) {
      opBadgeColor = AppThemeConstants.errorRed;
      opBgColor = AppThemeConstants.lightRed;
    }

    return InkWell(
      onTap: () {
        context.push('/admin/change-booking/${session['id']}').then((_) => _fetchBookingDetail());
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isLunas ? AppThemeConstants.borderGrey.withOpacity(0.6) : AppThemeConstants.warningAmber.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 15, color: AppThemeConstants.primaryBlue),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              session['play_date'] ?? '-',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 15, color: AppThemeConstants.textSecondary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${session['start_time']} - ${session['end_time']}',
                              style: const TextStyle(color: AppThemeConstants.textSecondary, fontWeight: FontWeight.w500, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatRp.format(int.tryParse(session['price']?.toString() ?? '0') ?? 0),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppThemeConstants.borderGrey),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: opBgColor, borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          opStatus,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: opBadgeColor),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isLunas ? AppThemeConstants.lightGreen : AppThemeConstants.lightRed,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isLunas ? AppThemeConstants.successGreen : AppThemeConstants.errorRed, width: 0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isLunas ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded,
                              size: 13,
                              color: isLunas ? AppThemeConstants.successGreen : AppThemeConstants.errorRed,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                isLunas ? 'LUNAS' : 'BELUM LUNAS (-${formatRp.format(remainingPayment)})',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isLunas ? AppThemeConstants.successGreen : AppThemeConstants.errorRed,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(Map<String, dynamic> user, Map<String, dynamic> field, Map<String, dynamic> payment, NumberFormat formatRp) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppThemeConstants.radiusLarge),
        border: Border.all(color: AppThemeConstants.borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informasi Pelanggan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppThemeConstants.textPrimary)),
          const SizedBox(height: 12),
          _buildInfoItem('Nama', user['name']?.toString() ?? '-'),
          _buildInfoItem('Tim', user['team_name']?.toString() ?? '-'),
          _buildInfoItem('Kontak', user['phone']?.toString() ?? '-'),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: AppThemeConstants.borderGrey)),
          const Text('Informasi Lapangan & Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppThemeConstants.textPrimary)),
          const SizedBox(height: 12),
          _buildInfoItem('Lapangan', field['name']?.toString() ?? '-', isBoldValue: true),
          _buildInfoItem('Total Tagihan', formatRp.format(int.tryParse(payment['total_price']?.toString() ?? '0') ?? 0)),
          _buildInfoItem('Total Dibayar', formatRp.format(int.tryParse(payment['total_paid']?.toString() ?? '0') ?? 0)),
          _buildInfoItem('Metode Pembayaran', payment['payment_method'].toString().toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, {bool isBoldValue = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppThemeConstants.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: AppThemeConstants.textPrimary,
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
