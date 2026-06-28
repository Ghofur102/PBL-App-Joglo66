import 'dart:convert';
import 'package:pbl_app_joglo66/constants/api_endpoints.dart';
import 'package:pbl_app_joglo66/services/api_client.dart';

class DashboardService {
  static Future<Map<String, dynamic>> fetchDashboardData({int? fieldId}) async {
    try {
      String urlString = ApiEndpoints.dashboard;
      if (fieldId != null) {
        urlString += '?field_id=$fieldId';
      }

      final response = await ApiClient.get(Uri.parse(urlString));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return jsonData['data'] as Map<String, dynamic>;
        }
        throw FormatException(jsonData['message'] ?? 'Gagal mengambil data dashboard');
      }
      throw FormatException('Error ${response.statusCode}: Gagal menghubungi server');
    } catch (e) {
      rethrow;
    }
  }
}
