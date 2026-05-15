import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pbl_app_joglo66/services/api_client.dart';

class AttributeService {
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

  static Future<List<dynamic>> fetchListAttribute({String? search}) async {
    await _initializePrefs();
    try {
      String urlString = '$_baseUrl/api/admin/list-attribute';
      if (search != null && search.isNotEmpty) {
        urlString += '?search=$search';
      }
      final url = Uri.parse(urlString);
      final response = await ApiClient.get(url, headers: _headers);
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        return jsonData['data'] ?? [];
      } else {
        throw Exception(jsonData['message'] ?? 'Gagal memuat data atribut');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> fetchDetailAttribute(int id) async {
    await _initializePrefs();
    try {
      final url = Uri.parse('$_baseUrl/api/admin/detail-attribute/$id');
      final response = await ApiClient.get(url, headers: _headers);
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        return jsonData['data'];
      } else {
        throw Exception(jsonData['message'] ?? 'Data atribut tidak ditemukan');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createAttribute({
    required int fkFieldId,
    required String name,
    required String type,
    required int stock,
    required int priceHour,
  }) async {
    await _initializePrefs();
    try {
      final url = Uri.parse('$_baseUrl/api/admin/create-attribute');
      final response = await ApiClient.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'fk_field_id': fkFieldId,
          'name': name,
          'type': type,
          'stock': stock,
          'price_hour': priceHour,
        }),
      );

      final jsonData = json.decode(response.body);

      if (response.statusCode == 201 && jsonData['success'] == true) {
        return jsonData['data'];
      }

      if (response.statusCode == 422) {
        throw Exception(jsonData['message'] ?? 'Validasi gagal');
      }

      throw Exception(jsonData['message'] ?? 'Gagal menyimpan data atribut');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateAttribute({
    required int id,
    String? name,
    String? type,
    int? stock,
    int? priceHour,
    String? status,
  }) async {
    await _initializePrefs();
    try {
      final url = Uri.parse('$_baseUrl/api/admin/update-attribute/$id');
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (type != null) body['type'] = type;
      if (stock != null) body['stock'] = stock;
      if (priceHour != null) body['price_hour'] = priceHour;
      if (status != null) body['status'] = status;

      final response = await ApiClient.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );

      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        return jsonData['data'];
      }

      if (response.statusCode == 422) {
        throw Exception(jsonData['message'] ?? 'Validasi gagal');
      }

      throw Exception(jsonData['message'] ?? 'Gagal memperbarui data atribut');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteAttribute(int id) async {
    await _initializePrefs();
    try {
      final url = Uri.parse('$_baseUrl/api/admin/delete-attribute/$id');
      final response = await ApiClient.post(url, headers: _headers);
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        return;
      }

      throw Exception(jsonData['message'] ?? 'Gagal menghapus data atribut');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> toggleStatus(int id) async {
    await _initializePrefs();
    try {
      final url = Uri.parse('$_baseUrl/api/admin/toggle-attribute-status/$id');
      final response = await ApiClient.post(url, headers: _headers);
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        return jsonData['data'];
      }

      throw Exception(jsonData['message'] ?? 'Gagal mengubah status atribut');
    } catch (e) {
      rethrow;
    }
  }
}
