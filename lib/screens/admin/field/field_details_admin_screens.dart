import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // <-- Jangan lupa import ini
import 'package:pbl_app_joglo66/services/field_service.dart';
import 'package:pbl_app_joglo66/components/detail_row.dart';
import 'package:pbl_app_joglo66/components/header_two.dart';

class FieldDetailsAdminScreens extends StatefulWidget {
  final String fieldId;

  const FieldDetailsAdminScreens({super.key, required this.fieldId});

  @override
  State<FieldDetailsAdminScreens> createState() =>
      _FieldDetailsAdminScreensState();
}

class _FieldDetailsAdminScreensState extends State<FieldDetailsAdminScreens> {
  Map<String, dynamic>? fieldData;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchFieldDetail();
  }

  Future<void> _fetchFieldDetail() async {
    try {
      final data = await FieldService.fetchFieldDetail(widget.fieldId);

      if (mounted) {
        setState(() {
          fieldData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString().replaceAll('Exception: ', '');
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatRp = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    // ========================================================
    // LOGIKA PINTAR UNTUK URL GAMBAR (Bisa baca dari .env)
    // ========================================================
    String baseUrl = dotenv.env['API_BASE_URL'] ?? '';
    String rawImageUrl = fieldData?['image_url'] ?? '';
    String finalImageUrl = '';

    if (rawImageUrl.isNotEmpty) {
      if (rawImageUrl.startsWith('http')) {
        finalImageUrl = rawImageUrl; // Jika data lama masih pakai HTTP utuh, biarkan
      } else {
        // Jika data baru (hanya path relatif seperti storage/fields/xxx), gabungkan dengan Base URL
        finalImageUrl = baseUrl.endsWith('/') 
            ? '$baseUrl$rawImageUrl' 
            : '$baseUrl/$rawImageUrl';
      }
    }
    // ========================================================

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
          'Field Details',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // --- Container Foto Lapangan ---
                  Container(
                    width: double.infinity,
                    height: 150,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF64B5F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    // Menggunakan ClipRRect agar gambar yang dimuat mengikuti border radius container
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      // Gunakan finalImageUrl hasil olahan dari .env
                      child: finalImageUrl.isEmpty
                        ? const Center(
                            child: Text(
                              'FIELD PHOTO',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : Image.network(
                            finalImageUrl, // <--- Ini Kuncinya
                            fit: BoxFit.cover,
                            // --- TAMBAHAN: Error Builder jika gambar gagal dimuat ---
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image, color: Colors.grey, size: 40),
                                      SizedBox(height: 8),
                                      Text('Gagal memuat gambar', style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                    ),
                  ),

                  // --- Container Field Information ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const HeaderTwo(title: 'Field Information'),
                        const SizedBox(height: 16),
                        DetailRow(
                          label: 'Field Name',
                          value: fieldData!['name'] ?? '-',
                        ),
                        const SizedBox(height: 8),
                        DetailRow(
                          label: 'Field Type',
                          value: fieldData!['category'] ?? '-',
                        ),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Divider(color: Colors.white, thickness: 2),
                        ),
                        
                        const Text(
                          'Pricing & Schedule:',
                          style: TextStyle(
                            fontSize: 14, 
                            fontWeight: FontWeight.bold, 
                            color: Colors.black54
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        if (fieldData!['field_prices'] == null || (fieldData!['field_prices'] as List).isEmpty)
                          const Text(
                            'Belum ada jadwal dan harga yang diatur.',
                            style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
                          )
                        else
                          ...((fieldData!['field_prices'] as List).map((priceItem) {
                            String day = priceItem['day_type'].toString().toUpperCase();
                            String st = priceItem['start_time'].toString().substring(0, 5);
                            String et = priceItem['end_time'].toString().substring(0, 5);
                            String price = formatRp.format(int.parse(priceItem['price'].toString()));
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 14, color: Colors.black54),
                                      const SizedBox(width: 6),
                                      Text(
                                        '$day ($st - $et)',
                                        style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    price,
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                                  ),
                                ],
                              ),
                            );
                          }).toList()),
                      ],
                    ),
                  ),

                  // --- Container Location ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HeaderTwo(title: 'Location'),
                        SizedBox(height: 16),
                        Text(
                          'Banyuwangi, East Java', 
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),

                  // --- Container Description ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const HeaderTwo(title: 'Description'),
                        const SizedBox(height: 16),
                        Text(
                          fieldData!['description'] ?? 'Tidak ada deskripsi',
                          style: const TextStyle(
                            height: 1.5,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- Tombol Edit ---
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async { 
                          await context.push(
                            '/admin/edit-field-details/${widget.fieldId}',
                          );
                          _fetchFieldDetail(); 
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFCC80),
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Edit Field Data',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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