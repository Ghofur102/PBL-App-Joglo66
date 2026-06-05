import 'dart:convert';
import 'package:pbl_app_joglo66/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class LaporanService {
  static const String _keyData = 'data';

  static String get _baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw const ApiException('API_BASE_URL tidak ditemukan di konfigurasi .env');
    }
    return url;
  }

  static Future<Map<String, dynamic>> fetchMonthlyLaporan(int month, int year) async {
    final uri = Uri.parse('$_baseUrl/api/treasurer/laporan-bulanan').replace(queryParameters: {
      'bulan': month.toString(),
      'tahun': year.toString(),
    });

    final response = await ApiClient.get(uri);
    final dynamic decoded = _safeJsonDecode(response.body);

    if (response.statusCode != 200) {
      final String errorMessage = (decoded is Map && decoded.containsKey('message'))
          ? decoded['message'].toString()
          : 'Terjadi kesalahan pada server (Status: ${response.statusCode})';

      throw ApiException(errorMessage, response.statusCode);
    }

    Map<String, dynamic> result = <String, dynamic>{};
    if (decoded is Map<String, dynamic>) {
      result = (decoded.containsKey(_keyData) && decoded[_keyData] is Map<String, dynamic>)
          ? decoded[_keyData] as Map<String, dynamic>
          : decoded;
    }

    return result;
  }

  static dynamic _safeJsonDecode(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }
}
