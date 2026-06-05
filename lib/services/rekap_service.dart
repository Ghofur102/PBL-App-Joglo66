import 'dart:convert';
import 'package:pbl_app_joglo66/services/api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class RekapService {
  static const String _keyData = 'data';
  static const String _keyTransaksi = 'transaksi';

  static String get _baseUrl {
    final url = dotenv.env['API_BASE_URL'];
    if (url == null || url.isEmpty) {
      throw const ApiException('API_BASE_URL tidak ditemukan di konfigurasi .env');
    }
    return url;
  }

  static Future<Map<String, dynamic>> fetchDailyRekap(String date) async {
    final uri = Uri.parse('$_baseUrl/api/admin/rekap-harian')
        .replace(queryParameters: {'tanggal': date});

    final response = await ApiClient.get(uri);
    final dynamic decoded = _safeJsonDecode(response.body);

    if (response.statusCode != 200) {
      final String errorMessage = (decoded is Map && decoded.containsKey('message'))
          ? decoded['message'].toString()
          : 'Unknown error occurred';

      throw ApiException(
        'Gagal mengambil data rekap harian. Message: $errorMessage',
        response.statusCode,
      );
    }

    Map<String, dynamic> result = <String, dynamic>{};
    if (decoded is Map<String, dynamic>) {
      result = (decoded.containsKey(_keyData) && decoded[_keyData] is Map<String, dynamic>)
          ? decoded[_keyData] as Map<String, dynamic>
          : decoded;
    }

    return result;
  }

  static Future<List<dynamic>> fetchDailyTransaksi(String date) async {
    final result = await fetchDailyRekap(date);
    List<dynamic> listTransaksi = <dynamic>[];

    if (result.containsKey(_keyTransaksi) && result[_keyTransaksi] is List) {
      listTransaksi = result[_keyTransaksi] as List<dynamic>;
    } else if (result.containsKey(_keyData) && result[_keyData] is List) {
      listTransaksi = result[_keyData] as List<dynamic>;
    }

    return listTransaksi;
  }

  static dynamic _safeJsonDecode(String body) {
    if (body.isEmpty) {
      return null;
    }
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }
}