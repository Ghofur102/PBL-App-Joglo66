import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
      String baseUrl = dotenv.env['API_BASE_URL']!;
      final String apiUrl = '$baseUrl/api/admin/detail-field/${widget.fieldId}';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          fieldData = jsonResponse['data'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage =
              'Gagal memuat data (Error Code: ${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage =
            'Tidak dapat terhubung ke server Laravel.\nPastikan php artisan serve sudah berjalan.\nDetail: $e';
        isLoading = false;
      });
    }
  }

  int _getPrice() {
    if (fieldData != null &&
        fieldData!['field_prices'] != null &&
        fieldData!['field_prices'].isNotEmpty) {
      return int.tryParse(fieldData!['field_prices'][0]['price'].toString()) ??
          0;
    }
    return 0; // Harga default jika kosong
  }

  String _getOperationalHours() {
    if (fieldData != null &&
        fieldData!['field_prices'] != null &&
        fieldData!['field_prices'].isNotEmpty) {
      final firstPrice = fieldData!['field_prices'][0];
      // Memotong string "08:00:00" menjadi "08:00"
      final start = firstPrice['start_time'].toString().substring(0, 5);
      final end = firstPrice['end_time'].toString().substring(0, 5);
      return '$start - $end';
    }
    return 'Belum diatur';
  }

  @override
  Widget build(BuildContext context) {
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
                      image: DecorationImage(
                        image: NetworkImage(fieldData!['image_url'] ?? ''),
                        fit: BoxFit.cover,
                      ),
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
                        const SizedBox(height: 8),
                        DetailRow(
                          label: 'Price Per Hour',
                          value: formatRp.format(_getPrice()), // Harga otomatis
                        ),
                        const SizedBox(height: 8),
                        DetailRow(
                          label: 'Operational Hours',
                          value: _getOperationalHours(), // Jam otomatis
                        ),
                      ],
                    ),
                  ),

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
                          'Banyuwangi, East Java', // Di-hardcode karena tidak ada kolom di database
                          style: TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                  ),

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

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.push(
                            '/admin/edit-field-details/${widget.fieldId}',
                          );
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
