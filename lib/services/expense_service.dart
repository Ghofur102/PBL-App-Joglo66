import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pbl_app_joglo66/constants/api_endpoints.dart';
import 'package:pbl_app_joglo66/services/api_client.dart';

class ExpenseService {
  static Future<List<dynamic>> getExpenses() async {
    try {
      final response = await ApiClient.get(Uri.parse(ApiEndpoints.listExpense));
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        return jsonData['data'] ?? [];
      }
      throw FormatException(jsonData['message'] ?? "Gagal mengambil data pengeluaran");
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<String>> getCategories() async {
    try {
      final response = await ApiClient.get(Uri.parse(ApiEndpoints.expenseCategories));
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        return List<String>.from(jsonData['data'] ?? []);
      }
      throw FormatException(jsonData['message'] ?? "Gagal mengambil daftar kategori");
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> addExpense({
    required String name,
    required String category,
    required String nominal,
    required String date,
    required String note,
    String? imagePath,
  }) async {
    try {
      final url = Uri.parse(ApiEndpoints.createExpense);
      final request = http.MultipartRequest("POST", url);

      request.fields['name'] = name;
      request.fields['category'] = category;
      request.fields['nominal'] = nominal;
      request.fields['date'] = date;
      request.fields['note'] = note;

      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('image', imagePath));
      }

      final response = await ApiClient.sendMultipart(request);
      return (response.statusCode == 200 || response.statusCode == 201);
    } catch (e) {
      throw FormatException(e.toString());
    }
  }

  static Future<bool> deleteExpense(int id) async {
    try {
      final response = await ApiClient.post(Uri.parse('${ApiEndpoints.deleteExpense}/$id'), body: jsonEncode({}));
      final jsonData = json.decode(response.body);
      return (response.statusCode == 200 && jsonData['success'] == true);
    } catch (e) {
      throw FormatException(e.toString());
    }
  }
}
