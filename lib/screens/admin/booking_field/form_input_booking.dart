import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:pbl_app_joglo66/services/booking_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormInputBooking extends StatefulWidget {
  final String nameField;
  final int fieldId;
  final DateTime selectedDate;
  final String hours;
  final int duration;
  final int fieldPrice; // Harga per jam dari layar sebelumnya

  const FormInputBooking({
    super.key,
    required this.nameField,
    required this.fieldId,
    required this.selectedDate,
    required this.hours,
    required this.duration,
    required this.fieldPrice,
  });

  @override
  State<FormInputBooking> createState() => _FormInputBookingPageState();
}

class _FormInputBookingPageState extends State<FormInputBooking> {
  String statusPembayaran = '';
  bool agree = false;
  bool isLoading = false;

  final TextEditingController namaController = TextEditingController();
  final TextEditingController waController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();

  late final int hargaPerJam;

  @override
  void initState() {
    super.initState();
    hargaPerJam = widget.fieldPrice;
    print('[FormInputBooking] Using price: $hargaPerJam per hour');
  }

  @override
  void dispose() {
    namaController.dispose();
    waController.dispose();
    emailController.dispose();
    catatanController.dispose();
    super.dispose();
  }

  /// Parse time string tunggal (misal: "08:00:00-09:00:00") ke start dan end time
  Map<String, String> parseTimeRange(String timeRange) {
    String cleanStr = timeRange.trim();
    List<String> parts = [];

    if (cleanStr.contains(' - ')) {
      parts = cleanStr.split(' - ');
    } else if (cleanStr.contains('-')) {
      parts = cleanStr.split('-');
    }

    if (parts.length == 2) {
      String start = parts[0].trim().replaceAll('.', ':');
      String end = parts[1].trim().replaceAll('.', ':');

      // ===============================================================
      // OBAT ANTI VALIDATION FAILED: POTONG DETIKNYA!
      // Mengubah "08:00:00" menjadi "08:00" agar sesuai format H:i Laravel
      // ===============================================================
      if (start.length >= 5) start = start.substring(0, 5);
      if (end.length >= 5) end = end.substring(0, 5);

      return {
        'start': start,
        'end': end,
      };
    }

    throw FormatException('Format jam tidak dikenali: $timeRange');
  }

  Future<void> nextPage() async {
    if (namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi Nama Tim terlebih dahulu')),
      );
      return;
    }

    if (!agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon setujui syarat & ketentuan')),
      );
      return;
    }

    if (statusPembayaran.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih opsi pembayaran')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final int totalHarga = widget.duration * hargaPerJam;
      final int dpHarga = (totalHarga * 0.5).toInt();
      final int paymentAmount = statusPembayaran == 'DP' ? dpHarga : totalHarga;

      final String currentBookingDate = DateTime.now().toString().split(' ')[0];
      final String formattedPlayDate = widget.selectedDate.toString().split(' ')[0];

      List<Map<String, dynamic>> bookingDetailsArray = [];

      // Memecah teks "08:00:00-09:00:00, 09:00:00-10:00:00" menjadi list
      List<String> selectedSlots = widget.hours.split(', ');

      for (String slot in selectedSlots) {
        final timeRange = parseTimeRange(slot);
        bookingDetailsArray.add({
          'play_date': formattedPlayDate,
          'start_play_time': timeRange['start']!, // Sekarang isinya pasti "08:00"
          'end_play_time': timeRange['end']!,     // Pasti "09:00"
          'price': hargaPerJam, 
        });
      }

      final prefs = await SharedPreferences.getInstance();
      final int? currentUserId = prefs.getInt('user_id');

      if (currentUserId == null) {
        throw Exception('Sesi login tidak valid (User ID kosong). Silakan Logout dan Login kembali.');
      }

      print('[FormInputBooking] Creating booking for ${bookingDetailsArray.length} slots...');

      final bookingResult = await BookingService.createBooking(
        userId: currentUserId, 
        fieldId: widget.fieldId,
        teamName: namaController.text,
        bookingDate: currentBookingDate,
        details: bookingDetailsArray, 
        customerPhone: waController.text.isNotEmpty ? waController.text : null,
        customerEmail: emailController.text.isNotEmpty ? emailController.text : null,
        notes: catatanController.text.isNotEmpty ? catatanController.text : null,
      );

      if (bookingResult['success'] == true) {
        final responseData = bookingResult['data'];
        
        if (responseData == null) throw Exception('Data JSON dari server kosong.');

        final rawBookingId = responseData['booking_id'];
        if (rawBookingId == null) throw Exception('Server tidak mengembalikan ID Booking.');

        final int safeBookingId = rawBookingId is int 
            ? rawBookingId 
            : int.parse(rawBookingId.toString());

        print('[FormInputBooking] Booking created: $safeBookingId');

        if (mounted) {
          context.push(
            '/admin/payment-details',
            extra: {
              'nameField': widget.nameField,
              'nameTenant': namaController.text,
              'selectedDate': widget.selectedDate,
              'hours': widget.hours,
              'duration': widget.duration,
              'totalPrice': totalHarga,
              'downPaymentPrice': dpHarga,
              'statusEarly': statusPembayaran,
              'bookingId': safeBookingId,
              'paymentAmount': paymentAmount,
            },
          );
        }
      }
    } catch (e) {
      print('[FormInputBooking] Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // Widget ReadOnly
  Widget readOnlyField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(icon, color: Colors.grey[600]),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Widget Input Field
  Widget inputField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            if (label == 'Nama Tim')
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.black87, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Masukkan $label',
            hintStyle: TextStyle(color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF406093), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  // Widget Payment Option
  Widget paymentOption(String title, int price, String valueStr) {
    final formatPrice = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(price);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: RadioListTile(
        value: valueStr,
        groupValue: statusPembayaran,
        onChanged: (value) {
          setState(() {
            statusPembayaran = value.toString();
          });
        },
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2C3E50),
              ),
            ),
            Text(
              formatPrice,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: statusPembayaran == valueStr
                ? const Color(0xFF406093)
                : Colors.transparent,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        tileColor: Colors.grey.shade50,
        activeColor: const Color(0xFF406093),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final formattedDate = DateFormat('dd MMM yyyy').format(widget.selectedDate);

    final int totalHarga = widget.duration * hargaPerJam;
    final int dpHarga = (totalHarga * 0.5).toInt();

    final formattedHargaPerJam = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(hargaPerJam);
    final formattedTotalHarga = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(totalHarga);

    return Scaffold(
      backgroundColor: const Color(0xFF406093),
      appBar: AppBar(
        title: const Text(
          'Form Booking Lapangan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: 20,
          ),
          child: Center(
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Lengkapi Booking',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'Detail Booking',
                    style: TextStyle(
                      color: Color(0xFF2C3E50),
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  readOnlyField(
                    'Lapangan',
                    widget.nameField,
                    Icons.sports_soccer,
                  ),
                  readOnlyField(
                    'Tanggal',
                    formattedDate,
                    Icons.calendar_today_outlined,
                  ),
                  readOnlyField('Jam', widget.hours, Icons.access_time),
                  readOnlyField(
                    'Durasi',
                    '${widget.duration} Jam',
                    Icons.timer_outlined,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Data Pemesan',
                    style: TextStyle(
                      color: Color(0xFF2C3E50),
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  inputField('Nama Tim', namaController),
                  const SizedBox(height: 16),
                  inputField('No. WhatsApp', waController),
                  const SizedBox(height: 16),
                  inputField('Email', emailController),
                  const SizedBox(height: 16),
                  inputField(
                    'Catatan (opsional)',
                    catatanController,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'Ringkasan Pembayaran',
                    style: TextStyle(
                      color: Color(0xFF2C3E50),
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Harga Sewa / Jam',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            Text(
                              formattedHargaPerJam,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Durasi',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            Text(
                              '${widget.duration} Jam',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          height: 1,
                          color: Colors.grey[300],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Harga',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            Text(
                              formattedTotalHarga,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'Opsi Pembayaran (CASH)',
                    style: TextStyle(
                      color: Color(0xFF2C3E50),
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '*Pembayaran dilakukan secara tunai (Cash) di lokasi. Silakan pilih status pembayaran Anda.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  paymentOption('DP (50%)', dpHarga, 'DP'),
                  paymentOption('Bayar Lunas', totalHarga, 'Lunas'),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: agree,
                        activeColor: const Color(0xFF406093),
                        onChanged: (value) {
                          setState(() {
                            agree = value!;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'Saya setuju dengan syarat & ketentuan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 140,
                        child: ElevatedButton(
                          onPressed:
                              (agree &&
                                      statusPembayaran.isNotEmpty &&
                                      namaController.text.trim().isNotEmpty &&
                                      !isLoading)
                                  ? nextPage
                                  : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF406093),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Next',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward_ios, size: 16),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}