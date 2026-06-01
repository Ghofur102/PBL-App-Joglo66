import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pbl_app_joglo66/services/api_client.dart';

class GajiService {
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;
  static SharedPreferences? _prefs;

  static Future<void> _initializePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static String get _token => _prefs?.getString('auth_token') ?? '';

  static Map<String, String> get _headers => {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  static Future<Map<String, dynamic>> storeGaji(Map<String, dynamic> payload) async {
    await _initializePrefs();
    if (_token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }
    try {
      final url = Uri.parse('$_baseUrl/api/admin/gaji');
      final response = await ApiClient.post(url, headers: _headers, body: jsonEncode(payload));
      final jsonData = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) && jsonData['success'] == true) {
        return jsonData['data'] ?? {};
      }

      if (response.statusCode == 422) {
        final errors = jsonData['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          throw Exception(errors.values.first[0]);
        }
        throw Exception('Validasi gagal');
      }

      throw Exception(jsonData['message'] ?? 'Gagal menyimpan data gaji');
    } catch (e) {
      rethrow;
    }
  }
}
