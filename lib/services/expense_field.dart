import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pbl_app_joglo66/services/api_client.dart';
import 'package:http/http.dart' as http;

class ExpenseService {
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;
  static SharedPreferences? _prefs;

  static Future<void> _initializePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static String get _token => _prefs?.getString('auth_token') ?? '';

  static Map<String, String> get headers => {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  static Future<List<dynamic>> getExpenses() async {
    await _initializePrefs();
    try {
      final url = Uri.parse('$_baseUrl/api/admin/list-expense');
      final response = await ApiClient.get(url, headers: headers);
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        return jsonData['data'] ?? [];
      } else {
        throw Exception(jsonData['message'] ?? "Gagal mengambil data pengeluaran");
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<String>> getCategories() async {
    await _initializePrefs();
    try {
      final url = Uri.parse('$_baseUrl/api/admin/expense-categories');
      final response = await ApiClient.get(url, headers: headers);
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        return List<String>.from(jsonData['data'] ?? []);
      } else {
        throw Exception(jsonData['message'] ?? "Gagal mengambil daftar kategori");
      }
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
    await _initializePrefs();
    try {
      final url = Uri.parse('$_baseUrl/api/admin/create-expense');
      var request = http.MultipartRequest("POST", url);

      request.headers.addAll({
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      });

      request.fields['name'] = name;
      request.fields['category'] = category;
      request.fields['nominal'] = nominal;
      request.fields['date'] = date;
      request.fields['note'] = note;

      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imagePath),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<bool> deleteExpense(int id) async {
    await _initializePrefs();
    try {
      final url = Uri.parse('$_baseUrl/api/admin/delete-expense/$id');
      final response = await ApiClient.post(url, headers: headers, body: jsonEncode({}));
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}