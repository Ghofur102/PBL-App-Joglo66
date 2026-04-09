import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// Pastikan path import ini sesuai dengan struktur folder Anda
import 'package:pbl_app_joglo66/screens/admin/booking_field/payment_details_page_admin_screens.dart';

class FormInputBooking extends StatefulWidget {
  final String nameField;
  final DateTime selectedDate;
  final String hours;
  final int duration;

  const FormInputBooking({
    super.key,
    required this.nameField,
    required this.selectedDate,
    required this.hours,
    required this.duration,
  });

  @override
  State<FormInputBooking> createState() => _FormInputBookingPageState();
}

class _FormInputBookingPageState extends State<FormInputBooking> {
  // Status pembayaran default
  String statusPembayaran = ''; 
  bool agree = false;

  final TextEditingController namaController = TextEditingController();
  final TextEditingController waController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController catatanController = TextEditingController();

  // Harga per jam (bisa disesuaikan dengan database nanti)
  final int hargaPerJam = 150000;

  void nextPage() {
    // Menghitung total dan DP untuk dikirim ke halaman selanjutnya
    final int totalHarga = widget.duration * hargaPerJam;
    final int dpHarga = (totalHarga * 0.5).toInt(); // DP 50%

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentDetailsPageAdminScreens(
          nameField: widget.nameField,
          nameTenant: namaController.text.isEmpty ? 'Tanpa Nama' : namaController.text,
          selectedDate: widget.selectedDate,
          hours: widget.hours,
          duration: widget.duration,
          totalPrice: totalHarga,
          downPaymentPrice: dpHarga,
          statusEarly: statusPembayaran,
        ),
      ),
    );
  }

  // Widget baru untuk menampilkan data yang read-only (tidak bisa diedit)
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
            color: Colors.grey[200], // Warna abu-abu menandakan field disabled
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

  Widget inputField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
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

  // Widget khusus untuk pilihan DP atau Lunas
  Widget paymentOption(String title, int price, String valueStr) {
    final formatPrice = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(price);
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
            ),
            Text(
              formatPrice,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: statusPembayaran == valueStr ? const Color(0xFF406093) : Colors.transparent),
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
    final int dpHarga = (totalHarga * 0.5).toInt(); // Setengah harga untuk DP
    
    final formattedHargaPerJam = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(hargaPerJam);
    final formattedTotalHarga = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(totalHarga);

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
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxWidth: 500,
              minWidth: screenWidth * 0.9,
            ),
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
                readOnlyField('Lapangan', widget.nameField, Icons.sports_soccer),
                readOnlyField('Tanggal', formattedDate, Icons.calendar_today_outlined),
                readOnlyField('Jam', widget.hours, Icons.access_time),
                readOnlyField('Durasi', '${widget.duration} Jam', Icons.timer_outlined),

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
                inputField('Nama Lengkap', namaController),
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

                // --- Pembayaran Cash / DP ---
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
                        // Aktif jika setuju dan status pembayaran sudah dipilih
                        onPressed: agree && statusPembayaran.isNotEmpty ? nextPage : null,
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
                        child: const Row(
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
    );
  }
}