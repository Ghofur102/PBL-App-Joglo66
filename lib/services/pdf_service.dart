import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pbl_app_joglo66/services/api_client.dart';

class PdfService {
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;
  static SharedPreferences? _prefs;

  static Future<void> _initializePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static String get _token => _prefs?.getString('auth_token') ?? '';

  static Map<String, String> get _headers => {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      };

  static Future<Map<String, dynamic>> fetchPdfPreview(int month, int year) async {
    await _initializePrefs();
    try {
      final url = Uri.parse('$_baseUrl/api/admin/laporan-pdf/preview?bulan=$month&tahun=$year');
      final response = await ApiClient.get(url, headers: _headers);
      final jsonData = json.decode(response.body);
      if (response.statusCode == 200 && jsonData['success'] == true) {
        return jsonData['data'];
      }
      throw Exception(jsonData['message'] ?? 'Gagal memuat preview laporan');
    } catch (e) {
      rethrow;
    }
  }

  static String getDownloadPdfUrl(int month, int year) {
    return '$_baseUrl/api/admin/laporan-pdf/download?bulan=$month&tahun=$year';
  }
}
