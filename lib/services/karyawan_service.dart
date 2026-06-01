import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pbl_app_joglo66/services/api_client.dart';

class KaryawanService {
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

  static Future<List<dynamic>> getAllKaryawan() async {
    await _initializePrefs();
    try {
      final url = Uri.parse('$_baseUrl/api/admin/karyawan');
      final response = await ApiClient.get(url, headers: _headers);
      final jsonData = json.decode(response.body);
      if (response.statusCode == 200 && jsonData['success'] == true) {
        return jsonData['data'] as List<dynamic>;
      }
      throw Exception(jsonData['message'] ?? 'Gagal memuat data karyawan');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createKaryawan(Map<String, dynamic> data) async {
    await _initializePrefs();
    if (_token.isEmpty) throw Exception('Token tidak ditemukan. Silakan login ulang.');
    try {
      final url = Uri.parse('$_baseUrl/api/admin/karyawan');
      final response = await ApiClient.post(url, headers: _headers, body: jsonEncode(data));
      final jsonData = json.decode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) && jsonData['success'] == true) {
        return jsonData['data'];
      }
      if (response.statusCode == 422) {
        final errors = jsonData['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) throw Exception(errors.values.first[0]);
        throw Exception('Validasi gagal');
      }
      throw Exception(jsonData['message'] ?? 'Gagal menambah karyawan');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateKaryawan(int id, Map<String, dynamic> data) async {
    await _initializePrefs();
    if (_token.isEmpty) throw Exception('Token tidak ditemukan. Silakan login ulang.');
    try {
      final url = Uri.parse('$_baseUrl/api/admin/karyawan/$id');
      data['_method'] = 'PUT';
      final response = await ApiClient.post(url, headers: _headers, body: jsonEncode(data));
      final jsonData = json.decode(response.body);
      if (response.statusCode == 200 && jsonData['success'] == true) {
        return jsonData['data'];
      }
      if (response.statusCode == 422) {
        final errors = jsonData['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) throw Exception(errors.values.first[0]);
        throw Exception('Validasi gagal');
      }
      throw Exception(jsonData['message'] ?? 'Gagal memperbarui karyawan');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteKaryawan(int id) async {
    await _initializePrefs();
    if (_token.isEmpty) throw Exception('Token tidak ditemukan. Silakan login ulang.');
    try {
      final url = Uri.parse('$_baseUrl/api/admin/karyawan/$id');
      final response = await ApiClient.post(
        url,
        headers: _headers,
        body: jsonEncode({'_method': 'DELETE'}),
      );
      final jsonData = json.decode(response.body);
      if (response.statusCode == 200 && jsonData['success'] == true) {
        return;
      }
      throw Exception(jsonData['message'] ?? 'Gagal menghapus karyawan');
    } catch (e) {
      rethrow;
    }
  }
}
