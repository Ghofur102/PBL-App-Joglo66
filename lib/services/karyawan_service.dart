import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pbl_app_joglo66/services/api_client.dart';

class KaryawanService {
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;

  static Future<List<dynamic>> getAllKaryawan() async {
    final url = Uri.parse('$_baseUrl/api/owner/karyawan');
    final response = await ApiClient.get(url);
    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonData['success'] == true) {
      return jsonData['data'] as List<dynamic>;
    }
    throw Exception(jsonData['message'] ?? 'Gagal memuat data karyawan');
  }

  static Future<Map<String, dynamic>> createKaryawan(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/api/owner/karyawan');
    final response = await ApiClient.post(url, body: jsonEncode(data));
    final jsonData = jsonDecode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) && jsonData['success'] == true) {
      return jsonData['data'];
    }

    if (response.statusCode == 422) {
      final errors = jsonData['errors'] as Map<String, dynamic>?;
      if (errors != null && errors.isNotEmpty) throw Exception(errors.values.first[0]);
      throw Exception('Validasi gagal');
    }
    throw Exception(jsonData['message'] ?? 'Gagal menambah karyawan');
  }

  static Future<Map<String, dynamic>> updateKaryawan(int id, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/api/owner/karyawan/$id/update');
    final response = await ApiClient.post(url, body: jsonEncode(data));
    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonData['success'] == true) {
      return jsonData;
    }

    if (response.statusCode == 422) {
      final errors = jsonData['errors'] as Map<String, dynamic>?;
      if (errors != null && errors.isNotEmpty) throw Exception(errors.values.first[0]);
      throw Exception('Validasi gagal');
    }
    throw Exception(jsonData['message'] ?? 'Gagal memperbarui karyawan');
  }

  static Future<void> deleteKaryawan(int id) async {
    final url = Uri.parse('$_baseUrl/api/owner/karyawan/$id/delete');
    final response = await ApiClient.post(url, body: jsonEncode({}));
    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonData['success'] == true) {
      return;
    }
    throw Exception(jsonData['message'] ?? 'Gagal menghapus karyawan');
  }
}
