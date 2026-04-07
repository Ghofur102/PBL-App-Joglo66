import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/components/detail_row.dart';
import 'package:pbl_app_joglo66/components/header_one.dart';
import 'package:pbl_app_joglo66/components/header_two.dart';
import 'package:pbl_app_joglo66/screens/admin/change_or_cancel_admin_screens.dart';

class BookingDetailsAdminScreen extends StatelessWidget {
  const BookingDetailsAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.arrow_back, color: Colors.black),
        title: const Text(
          'Detail Pesanan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Card Status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), // Warna hijau muda cerah
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Placeholder untuk Icon
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50), // Warna hijau utama
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'icon',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Teks Status & Garis Putus-putus
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HeaderTwo(title: 'Status: Berhasil Booking'),
                        const SizedBox(height: 8),
                        const Text(
                          'tidak ada catatan tambahan.',
                        ), // Widget custom di bawah
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 2. Card Rincian Pemesanan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD), // Warna biru muda lembut
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul Rincian
                  HeaderOne(title: 'Rincian Pemesanan Lapangan'),
                  const SizedBox(height: 16),

                  // Header Lapangan (Foto & Nama)
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        color: const Color(0xFF64B5F6), // Warna biru medium
                        alignment: Alignment.center,
                        child: const Text(
                          'foto\nlapangan',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Lapangan Joglo66 1',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text('Mini Soccer', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),

                  const Divider(),

                  // Bagian Waktu
                  const HeaderTwo(title: 'Waktu'),
                  const DetailRow(
                    label: 'Tanggal main',
                    value: '00/00/00 00:00 - 00:00',
                  ),
                  const DetailRow(
                    label: 'Waktu pesan',
                    value: '00/00/00 00:00 - 00:00',
                  ),

                  const Divider(),

                  // Bagian Layanan
                  const HeaderTwo(title: 'Layanan'),
                  const DetailRow(label: 'Lama Main', value: '0 Jam'),
                  const DetailRow(label: 'Harga Per Jam', value: 'Rp 0, 00'),
                  const DetailRow(label: 'Total Harga', value: 'Rp 0, 00'),
                  const DetailRow(label: 'Total DP', value: 'Rp 0, 00'),

                  const Divider(),

                  // Bagian Rincian Pembayaran
                  const HeaderTwo(title: 'Rincian Pembayaran'),
                  const DetailRow(label: 'Total Harga', value: 'Rp 0, 00'),
                  const DetailRow(label: 'Metode Pembayaran', value: 'Cash'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 3. Tombol Bawah
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangeOrCancelAdminScreens(
                      bookingId: 'BK-123456', 
                      oldDate: '12 April 2026', 
                      oldTime: '14:00 - 16:00', 
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                decoration: BoxDecoration(
                  color: const Color(
                    0xFFFFCC80,
                  ), // Warna oranye pastel untuk tombol aksi
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Ubah/Batalkan Pesanan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
