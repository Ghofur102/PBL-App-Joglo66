import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      'description': 'Lapangan mini soccer dengan ukuran standar dan lighting modern',
    },
    {
      'id': '2',
      'name': 'Lapangan B - Badminton',
      'location': 'Blok B, Lantai 2',
      'capacity': '4 Orang',
      'status': 'Sedang Digunakan',
      'description': 'Lapangan badminton official dengan net standar internasional',
    },
    {
      'id': '3',
      'name': 'Lapangan C - Futsal',
      'location': 'Blok C, Lantai 1',
      'capacity': '10 - 12 Orang',
      'status': 'Tersedia',
      'description': 'Lapangan futsal berstandar dengan gawang berkualitas premium',
    },
    {
      'id': '4',
      'name': 'Lapangan D - Basketball',
      'location': 'Blok D, Lantai 3',
      'capacity': '10 Orang',
      'status': 'Maintenance',
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
              // Header text
              const SizedBox(height: 16),
              Text(
                'Daftar Lapangan',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 12),

              // Search dan Filter
              Row(
                children: [
                  // Search field
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari lapangan...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF9E9E9E),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF9E9E9E),
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Filter button
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color(0xFFDADADA),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.filter_list,
                      color: Color(0xFF9E9E9E),
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Field List
              SectionTitle(title: 'Semua Lapangan'),
              const SizedBox(height: 12),
              ...fieldList.map((field) {
                return FieldItem(
                  fieldData: field,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FieldDetailPage(fieldData: field),
                      ),
                    );
                  },
                );
              }).toList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem('Home', Icons.home),
              _buildNavItem('Lapangan', Icons.sports_soccer),
              _buildNavItem('Jadwal', Icons.calendar_today),
              _buildNavItem('Profil', Icons.person),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF4A6FA5), size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: const Color(0xFF4A6FA5),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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

// Reusable FieldItem Widget
class FieldItem extends StatelessWidget {
  final Map<String, String> fieldData;
  final VoidCallback onTap;

  const FieldItem({
    super.key,
    required this.fieldData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFFDADADA),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon / Status
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getStatusColor(fieldData['status']!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.sports_soccer,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),

            // Field Info (Name, Location)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fieldData['name']!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    fieldData['location']!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF757575),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              color: const Color(0xFF9E9E9E),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Tersedia':
        return const Color(0xFF4CAF50);
      case 'Sedang Digunakan':
        return const Color(0xFFFF9800);
      case 'Maintenance':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}

// Field Detail Page
class FieldDetailPage extends StatelessWidget {
  final Map<String, String> fieldData;

  const FieldDetailPage({
    super.key,
    required this.fieldData,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFEEEEEE),
        appBar: AppBar(
          backgroundColor: const Color(0xFF4A6FA5),
          title: Text(
            'Detail Lapangan',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Field Image Placeholder
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFD0D0D0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.sports_soccer,
                  color: Colors.white,
                  size: 80,
                ),
              ),
              const SizedBox(height: 20),

              // Field Name
              Text(
                fieldData['name']!,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(fieldData['status']!),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  fieldData['status']!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Detail Fields
              _buildDetailField('Lokasi', fieldData['location']!, Icons.location_on),
              const SizedBox(height: 12),
              _buildDetailField('Kapasitas', fieldData['capacity']!, Icons.people),
              const SizedBox(height: 12),
              _buildDetailField('Deskripsi', fieldData['description']!, Icons.description),
              const SizedBox(height: 30),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A6FA5),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Booking Lapangan',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailField(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDADADA)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4A6FA5), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF9E9E9E),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Tersedia':
        return const Color(0xFF4CAF50);
      case 'Sedang Digunakan':
        return const Color(0xFFFF9800);
      case 'Maintenance':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}
