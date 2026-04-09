import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/components/detail_row.dart';
import 'package:pbl_app_joglo66/components/header_two.dart';

class FieldDetailsAdminScreens extends StatelessWidget {
  const FieldDetailsAdminScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () =>
              Navigator.pop(context), // Kembali ke halaman sebelumnya
        ),
        title: const Text(
          'Data Lapangan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. Container Foto Lapangan
            Container(
              width: double.infinity,
              height: 150,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: const Color(
                  0xFF64B5F6,
                ), // Biru medium agar placeholder foto menonjol
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: const Text(
                'FOTO LAPANGAN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),

            // 2. Container Informasi Lapangan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), // Hijau muda cerah
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  HeaderTwo(title: 'Informasi Lapangan'),
                  const SizedBox(height: 16),
                  // Detail Info (Label : Value)
                  DetailRow(
                    label: 'Nama Lapangan',
                    value: 'Lap. Futsal Inti A',
                  ),
                  const SizedBox(height: 8),
                  DetailRow(label: 'Jenis Lapangan', value: 'Vinyl'),
                  const SizedBox(height: 8),
                  DetailRow(
                    label: 'Harga Jam 00:00 - 00:00',
                    value: 'Rp 150,000',
                  ),
                  const SizedBox(height: 8),
                  DetailRow(label: 'Jam Operasional', value: '08:00 - 22:00'),
                ],
              ),
            ),

            // 3. Container Lokasi Lapangan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD), // Biru muda lembut
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  HeaderTwo(title: 'Lokasi Lapangan'),
                  const SizedBox(height: 16),
                  Text("Banyuwangi"),
                ],
              ),
            ),

            // 4. Container Deskripsi Lapangan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD), // Biru muda lembut
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  HeaderTwo(title: 'Deskripsi Lapangan'),
                  const SizedBox(height: 16),
                  Text("Informasi tambahan lapangan."),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/form_edit_field');
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFFFFCC80,
                    ), // Oranye pastel senada tombol aksi sebelumnya
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Ubah Data Lapangan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
