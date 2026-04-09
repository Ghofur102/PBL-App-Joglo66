import 'package:flutter/material.dart';
import '../../../components/button.dart';

class DetailPesananPage extends StatefulWidget {
  const DetailPesananPage({super.key});

  @override
  State<DetailPesananPage> createState() => _DetailPesananPageState();
}

class _DetailPesananPageState extends State<DetailPesananPage> {
  String metodePembayaran = 'Cash';
  String statusPembayaran = 'DP';

  @override
  Widget build(BuildContext context) {
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
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _InfoRow(label: 'Nama Tim', value: 'Sportify FC'),
                    _InfoRow(label: 'Nama Pemesan', value: 'Andi Saputra'),
                    _InfoRow(label: 'Hari & Tanggal Main', value: 'Selasa, 25 April 2024'),
                    _InfoRow(label: 'Jam Main', value: '14:00 - 16:00'),
                    _InfoRow(label: 'Durasi', value: '2 Jam'),
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
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    _InfoRow(label: 'Total Harga Sewa (2 jam)', value: 'Rp 500.000'),
                    _InfoRow(label: 'Total Harga DP', value: 'Rp 200.000'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // METODE & STATUS (SEBELAHAN)
            Row(
              children: [
                // METODE
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Metode Pembayaran',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            RadioListTile(
                              title: const Text('Cash'),
                              value: 'Cash',
                              groupValue: metodePembayaran,
                              onChanged: (value) {
                                setState(() {
                                  metodePembayaran = value!;
                                });
                              },
                            ),
                            RadioListTile(
                              title: const Text('Transfer'),
                              value: 'Transfer',
                              groupValue: metodePembayaran,
                              onChanged: (value) {
                                setState(() {
                                  metodePembayaran = value!;
                                });
                              },
                            ),
                          ],
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
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            RadioListTile(
                              title: const Text('DP'),
                              value: 'DP',
                              groupValue: statusPembayaran,
                              onChanged: (value) {
                                setState(() {
                                  statusPembayaran = value!;
                                });
                              },
                            ),
                            RadioListTile(
                              title: const Text('Lunas'),
                              value: 'Lunas',
                              groupValue: statusPembayaran,
                              onChanged: (value) {
                                setState(() {
                                  statusPembayaran = value!;
                                });
                              },
                            ),
                          ],
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
                width: 180,
                child: Button(
                  label: 'Konfirmasi Pembayaran',
                  backgroundColor: Colors.blue,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Metode: $metodePembayaran | Status: $statusPembayaran',
                        ),
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
              '*Silakan pilih "Konfirmasi Pembayaran" setelah customer menyelesaikan pembayaran DP.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
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
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}