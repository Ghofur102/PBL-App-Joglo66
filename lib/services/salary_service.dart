import 'dart:convert';
import 'package:pbl_app_joglo66/constants/api_endpoints.dart';
import 'package:pbl_app_joglo66/services/api_client.dart';

class SalaryService {
  static Future<List<dynamic>> fetchSalary(int month, int year) async {
    final uri = Uri.parse(ApiEndpoints.salary).replace(queryParameters: {
      'bulan': month.toString(),
      'tahun': year.toString(),
    });

    final response = await ApiClient.get(uri);
    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonData['success'] == true) {
      return jsonData['data'] ?? [];
    }
    throw FormatException(jsonData['message'] ?? 'Gagal memuat data gaji');
  }

  static Future<void> updateSalary(Map<String, dynamic> payload) async {
    final response = await ApiClient.post(
      Uri.parse(ApiEndpoints.salaryUpdate),
      body: jsonEncode(payload),
    );

    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonData['success'] == true) {
      return;
    }

    if (response.statusCode == 422) {
      final errors = jsonData['errors'] as Map<String, dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        throw FormatException(errors.values.first[0]);
      }
      throw const FormatException('Validasi gagal.');
    }

    throw FormatException(jsonData['message'] ?? 'Gagal menyimpan data gaji');
  }

  static Future<String> syncSalary(int month, int year) async {
    final payload = {'bulan': month, 'tahun': year};

    final response = await ApiClient.post(
      Uri.parse(ApiEndpoints.salarySync),
      body: jsonEncode(payload),
    );

    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonData['success'] == true) {
      return jsonData['message'] ?? 'Sinkronisasi berhasil';
    }
    throw FormatException(jsonData['message'] ?? 'Gagal sinkronisasi data gaji');
  }
}
