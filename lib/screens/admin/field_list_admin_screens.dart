import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbl_app_joglo66/components/field_card.dart';

class FieldListAdminScreens extends StatefulWidget {
  const FieldListAdminScreens({super.key});

  @override
  State<FieldListAdminScreens> createState() => _FieldListAdminScreensState();
}

class _FieldListAdminScreensState extends State<FieldListAdminScreens> {
  // Dummy data untuk list lapangan
  final List<Map<String, String>> fieldList = [
    {
      'id': '1',
      'name': 'Lapangan A - Mini Soccer',
      'location': 'Blok A, Lantai 1',
      'capacity': '10 - 12 Orang',
      'status': 'Tersedia',
      'availabilityTime': '08:00 - 22:00',
      'description': 'Lapangan mini soccer dengan ukuran standar dan lighting modern',
    },
    {
      'id': '2',
      'name': 'Lapangan B - Badminton',
      'location': 'Blok B, Lantai 2',
      'capacity': '4 Orang',
      'status': 'Ditutup',
      'availabilityTime': '15:00 - 17:00',
      'description': 'Lapangan badminton official dengan net standar internasional',
    },
    {
      'id': '3',
      'name': 'Lapangan C - Futsal',
      'location': 'Blok C, Lantai 1',
      'capacity': '10 - 12 Orang',
      'status': 'Tersedia',
      'availabilityTime': '08:00 - 23:00',
      'description': 'Lapangan futsal berstandar dengan gawang berkualitas premium',
    },
    {
      'id': '4',
      'name': 'Lapangan D - Basketball',
      'location': 'Blok D, Lantai 3',
      'capacity': '10 Orang',
      'status': 'Maintenance',
      'availabilityTime': 'Tutup sementara',
      'description': 'Lapangan basketball dengan ring standar NBA dan wooden floor',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFEEEEEE),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView(
            children: [
              const SizedBox(height: 16),
              
              // Field List
              SectionTitle(title: 'Semua Lapangan'),
              const SizedBox(height: 12),
              ...fieldList.map((field) {
                return FieldCard(
                  fieldName: field['name']!,
                  status: field['status']!,
                  availabilityTime: field['availabilityTime']!,
                );
              }).toList(),
              const SizedBox(height: 24),
              
              // Tombol Tambah Lapangan
              Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF4A6FA5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // TODO: Implement add field functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur tambah lapangan akan segera hadir'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tambah Lapangan',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable SectionTitle Widget
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }
}
