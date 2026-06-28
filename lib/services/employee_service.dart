import 'dart:convert';
import 'package:pbl_app_joglo66/constants/api_endpoints.dart';
import 'package:pbl_app_joglo66/services/api_client.dart';

class EmployeeService {
  static Future<List<dynamic>> getAllEmployee() async {
    final response = await ApiClient.get(Uri.parse(ApiEndpoints.employee));
    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonData['success'] == true) {
      return jsonData['data'] as List<dynamic>;
    }
    throw FormatException(jsonData['message'] ?? 'Gagal memuat data karyawan');
  }

  static Future<Map<String, dynamic>> createEmployee(Map<String, dynamic> data) async {
    final response = await ApiClient.post(Uri.parse(ApiEndpoints.employee), body: jsonEncode(data));
    final jsonData = jsonDecode(response.body);

    if ((response.statusCode == 200 || response.statusCode == 201) && jsonData['success'] == true) {
      return jsonData['data'];
    }

    if (response.statusCode == 422) {
      final errors = jsonData['errors'] as Map<String, dynamic>?;
      if (errors != null && errors.isNotEmpty) throw FormatException(errors.values.first[0]);
      throw const FormatException('Validasi gagal');
    }
    throw FormatException(jsonData['message'] ?? 'Gagal menambah karyawan');
  }

  static Future<Map<String, dynamic>> updateEmployee(int id, Map<String, dynamic> data) async {
    final response = await ApiClient.post(Uri.parse('${ApiEndpoints.employee}/$id/update'), body: jsonEncode(data));
    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonData['success'] == true) {
      return jsonData;
    }

    if (response.statusCode == 422) {
      final errors = jsonData['errors'] as Map<String, dynamic>?;
      if (errors != null && errors.isNotEmpty) throw FormatException(errors.values.first[0]);
      throw const FormatException('Validasi gagal');
    }
    throw FormatException(jsonData['message'] ?? 'Gagal memperbarui karyawan');
  }

  static Future<void> deleteEmployee(int id) async {
    final response = await ApiClient.post(Uri.parse('${ApiEndpoints.employee}/$id/delete'), body: jsonEncode({}));
    final jsonData = jsonDecode(response.body);

    if (response.statusCode == 200 && jsonData['success'] == true) {
      return;
    }
    throw FormatException(jsonData['message'] ?? 'Gagal menghapus karyawan');
  }
}
