import 'dart:convert';
import 'package:pbl_app_joglo66/constants/api_endpoints.dart';
import 'package:pbl_app_joglo66/core/exceptions/api_exception.dart';
import 'package:pbl_app_joglo66/services/api_client.dart';

class ReportService {
  static const String _keyData = 'data';

  static Future<Map<String, dynamic>> fetchMonthlyReport(int month, int year) async {
    final uri = Uri.parse(ApiEndpoints.monthlyReport).replace(queryParameters: {
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
