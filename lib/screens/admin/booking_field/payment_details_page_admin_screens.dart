import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/screens/admin/booking_field/waiting_payment_admins_screens.dart';
import '../../../components/button.dart';

class PaymentDetailsPageAdminScreens extends StatefulWidget {
  // Parameter untuk menerima kiriman dari Form Booking
  final String nameField;
  final String nameTenant;
  final DateTime selectedDate;
  final String hours;
  final int duration;
  final int totalPrice;
  final int downPaymentPrice;
  final String statusEarly; // Berisi 'DP' atau 'Lunas'

  const PaymentDetailsPageAdminScreens({
    super.key,
    required this.nameField,
    required this.nameTenant,
    required this.selectedDate,
    required this.hours,
    required this.duration,
    required this.totalPrice,
    required this.downPaymentPrice,
    required this.statusEarly,
  });

  @override
  State<PaymentDetailsPageAdminScreens> createState() =>
      _PaymentDetailsPageAdminScreensState();
}

class _PaymentDetailsPageAdminScreensState
    extends State<PaymentDetailsPageAdminScreens> {
  // Karena Metode Pembayaran hanya diset "Cash" dari form sebelumnya, kita buat konstan
  final String metodePembayaran = 'Cash';

  @override
  Widget build(BuildContext context) {
    // Format tanggal dan mata uang
    final String formattedDate = DateFormat(
      'EEEE, dd MMMM yyyy',
      'id_ID',
    ).format(widget.selectedDate);
    final String strTotal = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(widget.totalPrice);
    final String strDp = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(widget.downPaymentPrice);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Pemesanan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // CARD INFORMASI
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _InfoRow(label: 'Nama Lapangan', value: widget.nameField),
                    _InfoRow(label: 'Nama Pemesan', value: widget.nameTenant),
                    _InfoRow(
                      label: 'Hari & Tanggal Main',
                      value: formattedDate,
                    ),
                    _InfoRow(label: 'Jam Main', value: widget.hours),
                    _InfoRow(label: 'Durasi', value: '${widget.duration} Jam'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // TOTAL PEMBAYARAN
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      label: 'Total Harga Sewa (${widget.duration} jam)',
                      value: strTotal,
                    ),
                    // Jika status lunas, mungkin info DP tidak perlu terlalu ditonjolkan,
                    // tapi kita tetap tampilkan sesuai permintaan awal
                    _InfoRow(label: 'Total Harga DP', value: strDp),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // METODE & STATUS (SEBELAHAN - DIUBAH MENJADI INFO CARD)
            Row(
              children: [
                // METODE
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Metode Pembayaran',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          metodePembayaran,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF406093),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // STATUS
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status Pembayaran',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          widget
                              .statusEarly, // Menampilkan 'DP' atau 'Lunas' dari form sebelumnya
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF406093),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // BUTTON DI TENGAH
            Center(
              child: SizedBox(
                width: 250,
                child: Button(
                  label: 'Konfirmasi Pembayaran',
                  backgroundColor: Colors.blue,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WaitingPaymentAdminsScreen(),
                      ),
                    );
                  },
                  borderRadius: 12,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              '*Silakan pilih "Konfirmasi Pembayaran" setelah customer menyelesaikan pembayaran.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
