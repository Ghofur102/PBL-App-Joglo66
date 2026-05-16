import 'dart:convert';

import 'package:http/http.dart' as http;

class ExpenseService {
  // endpoint API untuk tabel expenses
  // NOTE: samakan dengan base url yang dipakai service lain (mis. DashboardService)
  static const String baseUrl = "http://192.168.1.8:8000/api/expenses";

  // =========================
  // GET ALL EXPENSE
  // =========================
  static Future<List<dynamic>> getExpenses() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Gagal mengambil data pengeluaran");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // =========================
  // GET DETAIL EXPENSE
  // =========================
  static Future<Map<String, dynamic>> getDetailExpense(int id) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/$id"),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Gagal mengambil detail pengeluaran");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // =========================
  // CREATE EXPENSE
  // =========================
  static Future<bool> addExpense({
    required String name,
    required String category,
    required String nominal,
    required String date,
    required String note,
    String? imagePath,
  }) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse(baseUrl));

      request.headers.addAll({"Accept": "application/json"});

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

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // =========================
  // UPDATE EXPENSE
  // =========================
  static Future<bool> updateExpense({
    required int id,
    required String name,
    required String category,
    required String nominal,
    required String date,
    required String note,
    String? imagePath,
  }) async {
    try {
      var request = http.MultipartRequest("POST", Uri.parse("$baseUrl/$id"));

      request.headers.addAll({"Accept": "application/json"});

      request.fields['_method'] = "PUT";
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

      final response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // =========================
  // DELETE EXPENSE
  // =========================
  static Future<bool> deleteExpense(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/$id"),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
