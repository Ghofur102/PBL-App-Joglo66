import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pbl_app_joglo66/services/api_client.dart';

class PdfService {
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;

  static Future<Map<String, dynamic>> fetchPdfPreview(int month, int year) async {
    final url = Uri.parse('$_baseUrl/api/owner/laporan-pdf/preview?bulan=$month&tahun=$year');
    final response = await ApiClient.get(url);
    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonData['success'] == true) {
      return jsonData['data'];
    }
    throw Exception(jsonData['message'] ?? 'Gagal memuat preview laporan');
  }
}
