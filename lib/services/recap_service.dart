import 'dart:convert';
import 'package:pbl_app_joglo66/constants/api_endpoints.dart';
import 'package:pbl_app_joglo66/core/exceptions/api_exception.dart';
import 'package:pbl_app_joglo66/services/api_client.dart';

class RecapService {
  static const String _keyData = 'data';
  static const String _keyTransaction = 'transaksi';

  static Future<Map<String, dynamic>> fetchDailyRecap(String date) async {
    final uri = Uri.parse(ApiEndpoints.dailyRecap).replace(queryParameters: {'tanggal': date});
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

  static Future<List<dynamic>> fetchDailyTransaction(String date) async {
    final result = await fetchDailyRecap(date);
    List<dynamic> listTransaction = <dynamic>[];

    if (result.containsKey(_keyTransaction) && result[_keyTransaction] is List) {
      listTransaction = result[_keyTransaction] as List<dynamic>;
    } else if (result.containsKey(_keyData) && result[_keyData] is List) {
      listTransaction = result[_keyData] as List<dynamic>;
    }

    return listTransaction;
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
