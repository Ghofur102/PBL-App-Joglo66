import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/components/detail_row.dart';
import 'package:pbl_app_joglo66/components/app_button.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/payment_service.dart';

class PaymentDetailsAdminScreen extends StatefulWidget {
  final String nameField;
  final String nameTenant;
  final DateTime selectedDate;
  final String hours;
  final int duration;
  final int totalPrice;
  final int downPaymentPrice;
  final String statusEarly;
  final int bookingId;
  final int? bookingDetailId;
  final int paymentAmount;

  const PaymentDetailsAdminScreen({
    super.key,
    required this.nameField,
    required this.nameTenant,
    required this.selectedDate,
    required this.hours,
    required this.duration,
    required this.totalPrice,
    required this.downPaymentPrice,
    required this.statusEarly,
    required this.bookingId,
    this.bookingDetailId,
    required this.paymentAmount,
  });

  @override
  State<PaymentDetailsAdminScreen> createState() => _PaymentDetailsAdminScreenState();
}

class _PaymentDetailsAdminScreenState extends State<PaymentDetailsAdminScreen> {
  bool _isLoading = false;

  Future<void> _handlePaymentConfirmation() async {
    setState(() => _isLoading = true);
    try {
      final String paymentType = widget.statusEarly == 'DP' ? 'down payment' : 'final payment';

      await PaymentService.processPayment(
        method: 'cash',
        bookingId: widget.bookingId,
        bookingDetailId: widget.bookingDetailId,
        amount: widget.paymentAmount,
        paymentType: paymentType,
      );

      if (mounted) {
        context.push(
          '/admin/payment-status',
          extra: {
            'isSuccess': true,
            'message': 'Pembayaran dari customer telah dikonfirmasi dengan sukses! Anda dapat mengecek di daftar penyewaan lapangan.',
          },
        );
      }
    } catch (e) {
      if (mounted) {
        final String cleanErrorMessage = e is FormatException ? e.message : e.toString().replaceAll('Exception: ', '');
        context.push(
          '/admin/payment-status',
          extra: {
            'isSuccess': false,
            'message': cleanErrorMessage,
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(widget.selectedDate);
    final formatRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppThemeConstants.bgLight,
      appBar: AppBar(
        title: const Text('Detail Invoice Pesanan', style: TextStyle(color: AppThemeConstants.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppThemeConstants.textPrimary), onPressed: () => context.pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informasi Pemesanan Lapangan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppThemeConstants.radiusLarge),
                border: Border.all(color: AppThemeConstants.borderGrey),
              ),
              child: Column(
                children: [
                  DetailRow(label: 'Nama Lapangan', value: widget.nameField),
                  DetailRow(label: 'Nama Pemesan', value: widget.nameTenant),
                  DetailRow(label: 'Tanggal Main', value: formattedDate),
                  DetailRow(label: 'Sesi Jam', value: widget.hours),
                  DetailRow(label: 'Total Durasi', value: '${widget.duration} Jam'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(color: AppThemeConstants.lightGreen, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Ringkasan Finansial', style: TextStyle(fontWeight: FontWeight.bold, color: AppThemeConstants.successGreen)),
                  const SizedBox(height: 10),
                  DetailRow(label: 'Total Harga Sewa', value: formatRp.format(widget.totalPrice)),
                  DetailRow(label: 'Total Harga DP', value: formatRp.format(widget.downPaymentPrice)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildBadgeInfoBox('Metode Pembayaran', 'CASH')),
                const SizedBox(width: 12),
                Expanded(child: _buildBadgeInfoBox('Status Pilihan', widget.statusEarly)),
              ],
            ),
            const SizedBox(height: 40),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: 'Konfirmasi Pembayaran Kasir',
                        backgroundColor: AppThemeConstants.accentBlue,
                        onPressed: _handlePaymentConfirmation,
                      ),
                    ),
                  ),
            const SizedBox(height: 12),
            const Text(
              '*Silakan pilih "Konfirmasi Pembayaran" setelah pelanggan menyerahkan uang fisik secara tunai di lokasi.',
              style: TextStyle(fontSize: 12, color: AppThemeConstants.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeInfoBox(String title, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppThemeConstants.textSecondary)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppThemeConstants.borderGrey)),
          child: Text(
            val,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppThemeConstants.primaryBlue),
          ),
        ),
      ],
    );
  }
}
