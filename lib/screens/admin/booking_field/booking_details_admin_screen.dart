import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/components/detail_row.dart';
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_rounded, size: 16, color: AppThemeConstants.primaryBlue),
                              const SizedBox(width: 8),
                              Text(session['play_date'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary)),
                            ],
                          ),
                          Text(formatRp.format(int.tryParse(session['price']?.toString() ?? '0') ?? 0), style: const TextStyle(fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 16, color: AppThemeConstants.textSecondary),
                          const SizedBox(width: 8),
                          Text('${session['start_time']} - ${session['end_time']}', style: const TextStyle(color: AppThemeConstants.textSecondary, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: AppThemeConstants.borderGrey),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(color: opBgColor, borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              opStatus,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: opBadgeColor),
                            ),
                          ),
                          const SizedBox(width: 8),

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
                                Text(
                                  isLunas ? 'LUNAS' : 'BELUM LUNAS (-${formatRp.format(remainingPayment)})',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isLunas ? AppThemeConstants.successGreen : AppThemeConstants.errorRed,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
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
