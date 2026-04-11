import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/components/detail_row.dart';
import 'package:pbl_app_joglo66/components/header_two.dart';

class FieldDetailsAdminScreens extends StatelessWidget {
  final String fieldId;

  const FieldDetailsAdminScreens({super.key, required this.fieldId});

  // 2. Sesuaikan Dummy Data khusus untuk Lapangan (Field)
  Map<String, dynamic> _fetchDummyData(String id) {
    final db = {
      '1': {
        'fieldName': 'Joglo66 Field 1',
        'fieldType': 'Mini Soccer',
        'pricePerHour': 150000,
        'operationalHours': '08:00 - 22:00',
        'location': 'Banyuwangi, East Java',
        'description':
            'Premium mini soccer field with high-quality synthetic grass, LED lighting for night matches, and a comfortable waiting area.',
      },
      '2': {
        'fieldName': 'Futsal Field A',
        'fieldType': 'Futsal (Vinyl)',
        'pricePerHour': 100000,
        'operationalHours': '09:00 - 23:00',
        'location': 'Banyuwangi, East Java',
        'description':
            'Standard indoor futsal court with vinyl flooring and digital scoreboard.',
      },
    };

    // Fallback jika ID tidak ditemukan
    return db[id] ??
        {
          'fieldName': 'Unknown Field',
          'fieldType': '-',
          'pricePerHour': 0,
          'operationalHours': '-',
          'location': '-',
          'description': 'No description available.',
        };
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data lapangan berdasarkan ID
    final data = _fetchDummyData(fieldId);

    // Format mata uang
    final formatRp = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // 3. Gunakan go_router untuk tombol kembali
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: const Text(
          'Field Details', // Terjemahan
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
                'FIELD PHOTO',
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
                  const HeaderTwo(title: 'Field Information'),
                  const SizedBox(height: 16),

                  // 4. Hubungkan data dinamis ke UI
                  DetailRow(label: 'Field Name', value: data['fieldName']),
                  const SizedBox(height: 8),
                  DetailRow(label: 'Field Type', value: data['fieldType']),
                  const SizedBox(height: 8),
                  DetailRow(
                    label: 'Price Per Hour',
                    value: formatRp.format(data['pricePerHour']),
                  ),
                  const SizedBox(height: 8),
                  DetailRow(
                    label: 'Operational Hours',
                    value: data['operationalHours'],
                  ),
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
                  const HeaderTwo(title: 'Location'),
                  const SizedBox(height: 16),
                  Text(
                    data['location'],
                    style: const TextStyle(color: Colors.black87),
                  ),
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
                  const HeaderTwo(title: 'Description'),
                  const SizedBox(height: 16),
                  Text(
                    data['description'],
                    style: const TextStyle(height: 1.5, color: Colors.black87),
                  ),
                ],
              ),
            ),

            // 5. Tombol Edit
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 0.0,
                vertical: 8.0,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/admin/edit-field-details/$fieldId');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFFFFCC80,
                    ), // Oranye pastel senada
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Edit Field Data',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24), // Extra padding di bawah
          ],
        ),
      ),
    );
  }
}
