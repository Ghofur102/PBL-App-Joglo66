import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pbl_app_joglo66/services/api_client.dart';
class DashboardService {
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;
  static SharedPreferences? _prefs;

  // Inisialisasi SharedPreferences
  static Future<void> _initializePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // Ambil token dari memori
  static String get _token {
    return _prefs?.getString('auth_token') ?? '';
  }

  // Helper untuk Header standar
  static Map<String, String> get _headers {
    return {
      'Authorization': 'Bearer $_token',
      'Accept': 'application/json',
    };
  }

  /// =====================================================================
  /// GET: /api/admin/dashboard
  /// Mengambil data statistik hari ini (slot terisi, kosong, total booking)
  /// =====================================================================
  static Future<Map<String, dynamic>> fetchDashboardData({int? fieldId}) async {
    await _initializePrefs();
    try {
      // Jika fieldId dikirimkan, tambahkan ke ujung URL (Query Parameter)
      String urlString = '$_baseUrl/api/admin/dashboard';
      if (fieldId != null) {
        urlString += '?field_id=$fieldId';
      }

      final url = Uri.parse(urlString);
      print('[DashboardService] Fetching: $url');

      // MENGGUNAKAN API CLIENT (Otomatis handle 401 & Timeout)
      final response = await ApiClient.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          // Kembalikan langsung object 'data' yang berisi name, slotTerisi, dll
          return jsonData['data'] as Map<String, dynamic>;
        } else {
          throw Exception(jsonData['message'] ?? 'Gagal mengambil data dashboard');
        }
      } else {
        throw Exception('Error ${response.statusCode}: Gagal menghubungi server');
      }
    } catch (e) {
      print('[DashboardService] Error: $e');
      rethrow;
    }
  }
}