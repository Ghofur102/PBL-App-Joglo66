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
  final TextEditingController _emailController = TextEditingController(); // Kontroler email aktif
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
    print('========= MEMULAI VALIDASI FORM BOOKING =========');
    print('Nama Penyewa : "${_nameController.text}" (Kosong? ${_nameController.text.trim().isEmpty})');
    print('Email Penyewa: "${_emailController.text}" (Kosong? ${_emailController.text.trim().isEmpty})');
    print('Opsi Pembayaran: "$_paymentStatusOption" (Kosong? ${_paymentStatusOption.isEmpty})');
    print('Centang Validasi: $_isAgreed (Disetujui? $_isAgreed)');
    print('==================================================');

    if (_nameController.text.trim().isEmpty) {
      print('⚠️ WARN: Input Nama Penyewa kosong.');
      _showWarningSnackBar('Nama tim atau penyewa wajib diisi!');
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      print('⚠️ WARN: Input Email Penyewa kosong.');
      _showWarningSnackBar('Email penyewa wajib diisi untuk keperluan data sewa!');
      return;
    }

    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(_emailController.text.trim())) {
      print('⚠️ WARN: Format email tidak sesuai standar.');
      _showWarningSnackBar('Format email penyewa tidak valid!');
      return;
    }

    if (_paymentStatusOption.isEmpty) {
      print('⚠️ WARN: Opsi jenis pembayaran belum dipilih.');
      _showWarningSnackBar('Silakan pilih metode pembayaran (Lunas/DP)!');
      return;
    }

    if (!_isAgreed) {
      print('⚠️ WARN: Kotak centang belum dicentang.');
      _showWarningSnackBar('Anda harus mencentang konfirmasi validitas data!');
      return;
    }

    print('✅ SUCCESS: Seluruh validasi UI lolos. Masuk ke blok pemrosesan data...');

    setState(() => _isLoading = true);
    try {
      final int totalHarga = widget.duration * widget.fieldPrice;
      final int dpHarga = (totalHarga * 0.5).toInt();
      final int paymentAmount = _paymentStatusOption == 'DP' ? dpHarga : totalHarga;

      final String currentBookingDate = DateTime.now().toString().split(' ')[0];
      final String formattedPlayDate = widget.selectedDate.toString().split(' ')[0];

      List<Map<String, dynamic>> bookingDetailsArray = [];
      List<String> selectedSlots = widget.hours.split(', ');

      print('ℹ️ DIAGNOSTIK: Memproses konversi string jam sesi: ${widget.hours}');
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

      if (currentUserId == null) {
        throw const FormatException('Sesi internal user ID kosong. Silakan login kembali.');
      }

      print('🚀 MENEMBAK API KE BACKEND: BookingService.createBooking()...');

      final bookingResult = await BookingService.createBooking(
        userId: currentUserId,
        fieldId: widget.fieldId,
        teamName: _nameController.text.trim(),
        bookingDate: currentBookingDate,
        details: bookingDetailsArray,
        customerPhone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        customerEmail: _emailController.text.trim(),
        notes: _noteController.text.isNotEmpty ? _noteController.text : null,
      );

      print('📥 KELUARAN API BERHASIL DITERIMA: $bookingResult');

      final bool isSuccess = bookingResult['success'] == true || bookingResult['status'] == 'success';

      if (isSuccess) {
        print('🎉 EXCELLENT: Booking terekam di DB. Mengalihkan route screen...');
        if (mounted) {
          final dynamic rawBookingId = bookingResult['data']?['booking_id'] ?? bookingResult['data']?['id'];

          context.push('/admin/payment-details', extra: {
            'nameField': widget.nameField,
            'nameTenant': _nameController.text,
            'selectedDate': widget.selectedDate,
            'hours': widget.hours,
            'duration': widget.duration,
            'totalPrice': totalHarga,
            'downPaymentPrice': dpHarga,
            'statusEarly': _paymentStatusOption,
            'bookingId': int.tryParse(rawBookingId.toString()) ?? 0,
            'paymentAmount': paymentAmount,
          });
        }
      } else {
        print('❌ REJECTED: Server merespon gagal. Isi pesan: ${bookingResult['message']}');
        _showWarningSnackBar(bookingResult['message'] ?? 'Ditolak oleh sistem server.');
      }
    } catch (e, stacktrace) {
      print('🔴 CRITICAL ERROR DI DALAM TRY-BLOCK: $e');
      print('📜 STACKTRACE LENGKAP: $stacktrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eror internal: $e'), backgroundColor: AppThemeConstants.errorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
      print('🏁 PROCESS ENDED: Status loading dimatikan.');
    }
  }

  void _showWarningSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppThemeConstants.warningAmber,
        duration: const Duration(seconds: 3),
      ),
    );
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
              // 🟢 UI BARU: Menampilkan kolom input Email Penyewa di tengah form data sewa
              AppInputField(
                label: 'Email Penyewa',
                controller: _emailController,
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
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
                  ? const CircularProgressIndicator(color: AppThemeConstants.primaryBlue)
                  : SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: 'Konfirmasi Selanjutnya',
                        onPressed: _nextPage,
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
