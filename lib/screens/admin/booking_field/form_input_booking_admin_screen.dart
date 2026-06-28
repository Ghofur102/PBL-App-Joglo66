import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pbl_app_joglo66/components/app_input_field.dart';
import 'package:pbl_app_joglo66/components/app_button.dart';
import 'package:pbl_app_joglo66/components/detail_row.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/services/booking_service.dart';

class FormInputBookingAdminScreen extends StatefulWidget {
  final String nameField;
  final int fieldId;
  final DateTime selectedDate;
  final String hours;
  final int duration;
  final int fieldPrice;

  const FormInputBookingAdminScreen({
    super.key,
    required this.nameField,
    required this.fieldId,
    required this.selectedDate,
    required this.hours,
    required this.duration,
    required this.fieldPrice,
  });

  @override
  State<FormInputBookingAdminScreen> createState() => _FormInputBookingAdminScreenState();
}

class _FormInputBookingAdminScreenState extends State<FormInputBookingAdminScreen> {
  String _paymentStatusOption = '';
  bool _isAgreed = false;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  Map<String, String> _parseTimeRange(String timeRange) {
    List<String> parts = timeRange.trim().split('-');
    if (parts.length == 2) {
      String start = parts[0].trim().replaceAll('.', ':');
      String end = parts[1].trim().replaceAll('.', ':');
      return {
        'start': start.length >= 5 ? start.substring(0, 5) : start,
        'end': end.length >= 5 ? end.substring(0, 5) : end,
      };
    }
    throw FormatException('Format jam tidak valid: $timeRange');
  }

  Future<void> _nextPage() async {
    if (_nameController.text.trim().isEmpty || !_isAgreed || _paymentStatusOption.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final int totalHarga = widget.duration * widget.fieldPrice;
      final int dpHarga = (totalHarga * 0.5).toInt();
      final int paymentAmount = _paymentStatusOption == 'DP' ? dpHarga : totalHarga;

      final String currentBookingDate = DateTime.now().toString().split(' ')[0];
      final String formattedPlayDate = widget.selectedDate.toString().split(' ')[0];

      List<Map<String, dynamic>> bookingDetailsArray = [];
      List<String> selectedSlots = widget.hours.split(', ');

      for (String slot in selectedSlots) {
        final timeRange = _parseTimeRange(slot);
        bookingDetailsArray.add({
          'play_date': formattedPlayDate,
          'start_play_time': timeRange['start']!,
          'end_play_time': timeRange['end']!,
          'price': widget.fieldPrice,
        });
      }

      final prefs = await SharedPreferences.getInstance();
      final int? currentUserId = prefs.getInt('user_id');

      if (currentUserId == null) throw const FormatException('Sesi internal user ID kosong.');

      final bookingResult = await BookingService.createBooking(
        userId: currentUserId,
        fieldId: widget.fieldId,
        teamName: _nameController.text.trim(),
        bookingDate: currentBookingDate,
        details: bookingDetailsArray,
        customerPhone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        customerEmail: _emailController.text.isNotEmpty ? _emailController.text : null,
        notes: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      if (bookingResult['success'] == true && mounted) {
        context.push('/admin/payment-details', extra: {
          'nameField': widget.nameField,
          'nameTenant': _nameController.text,
          'selectedDate': widget.selectedDate,
          'hours': widget.hours,
          'duration': widget.duration,
          'totalPrice': totalHarga,
          'downPaymentPrice': dpHarga,
          'statusEarly': _paymentStatusOption,
          'bookingId': int.parse(bookingResult['data']['booking_id'].toString()),
          'paymentAmount': paymentAmount,
        });
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppThemeConstants.errorRed));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final int totalHarga = widget.duration * widget.fieldPrice;

    return Scaffold(
      backgroundColor: AppThemeConstants.primaryBlue,
      appBar: AppBar(title: const Text('Formulir Data Sewa', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              DetailRow(label: 'Lapangan', value: widget.nameField),
              DetailRow(label: 'Jam Sesi', value: widget.hours),
              DetailRow(label: 'Total Nominal', value: formatRp.format(totalHarga), isBoldValue: true),
              const Divider(),
              AppInputField(label: 'Nama Tim/Penyewa', controller: _nameController, icon: Icons.person_outline),
              const SizedBox(height: 12),
              AppInputField(label: 'No. WhatsApp', controller: _phoneController, icon: Icons.phone, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              AppInputField(label: 'Catatan Masukan', controller: _noteController, maxLines: 2),
              const SizedBox(height: 16),
              RadioListTile<String>(
                title: const Text('Bayar Lunas (100%)'),
                value: 'Lunas',
                groupValue: _paymentStatusOption,
                onChanged: (v) => setState(() => _paymentStatusOption = v ?? 'Lunas'),
              ),
              RadioListTile<String>(
                title: const Text('Uang Muka (DP 50%)'),
                value: 'DP',
                groupValue: _paymentStatusOption,
                onChanged: (v) => setState(() => _paymentStatusOption = v ?? 'DP'),
              ),
              CheckboxListTile(
                title: const Text('Saya menyatakan data di atas valid.', style: TextStyle(fontSize: 13)),
                value: _isAgreed,
                onChanged: (v) => setState(() => _isAgreed = v ?? false),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(width: double.infinity, child: AppButton(label: 'Konfirmasi Selanjutnya', onPressed: _nextPage))
            ],
          ),
        ),
      ),
    );
  }
}
