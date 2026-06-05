import 'dart:convert';
import 'package:pbl_app_joglo66/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GajiService {
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;

  static Future<List<dynamic>> fetchGaji(int month, int year) async {
    final uri = Uri.parse('$_baseUrl/api/treasurer/gaji').replace(queryParameters: {
      'bulan': month.toString(),
      'tahun': year.toString(),
    });

    final response = await ApiClient.get(uri);
    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonData['success'] == true) {
      return jsonData['data'] ?? [];
    }

    throw Exception(jsonData['message'] ?? 'Gagal memuat data gaji');
  }

  static Future<void> updateGaji(Map<String, dynamic> payload) async {
    final uri = Uri.parse('$_baseUrl/api/treasurer/gaji/update');

    final response = await ApiClient.post(uri, body: jsonEncode(payload), headers: {
      'Content-Type': 'application/json'
    });

    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonData['success'] == true) {
      return;
    }

    if (response.statusCode == 422) {
      final errors = jsonData['errors'] as Map<String, dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        throw Exception(errors.values.first[0]);
      }
      throw Exception('Validasi gagal.');
    }

    throw Exception(jsonData['message'] ?? 'Gagal menyimpan data gaji');
  }

  static Future<String> syncGaji(int month, int year) async {
    final uri = Uri.parse('$_baseUrl/api/treasurer/gaji/sync');
    final payload = {
      'bulan': month,
      'tahun': year,
    };

    final response = await ApiClient.post(uri, body: jsonEncode(payload), headers: {
      'Content-Type': 'application/json'
    });

    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonData['success'] == true) {
      return jsonData['message'] ?? 'Sinkronisasi berhasil';
    }

    throw Exception(jsonData['message'] ?? 'Gagal sinkronisasi data gaji');
  }
}