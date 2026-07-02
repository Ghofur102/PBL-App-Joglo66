import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _role = 'guest';
  String? _token;
  int? _userId;

  bool get isLoggedIn => _isLoggedIn;
  String get role => _role;
  String? get token => _token;
  int? get userId => _userId;

  String get _baseUrl => dotenv.env['API_BASE_URL']!;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _role = prefs.getString('user_role') ?? 'guest';
    _userId = prefs.getInt('user_id');
    _isLoggedIn = _token != null && _token!.isNotEmpty;

    Future.microtask(() {
      notifyListeners();
    });
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _token = data['token'];
        _role = data['user']['role'];
        _userId = data['user']['id'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_role', _role);
        await prefs.setInt('user_id', _userId!);

        _isLoggedIn = true;

        Future.microtask(() {
          notifyListeners();
        });

        return {'success': true, 'message': 'Login berhasil'};
      } else if (response.statusCode == 422) {
        String specificError = 'Validasi gagal.';
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          specificError = errors.values.first[0];
        }
        return {'success': false, 'message': specificError};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login gagal. Silakan coba lagi.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Tidak dapat terhubung ke server.'};
    }
  }

  Future<Map<String, dynamic>> fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null || token.isEmpty) {
      await logout();
      throw const FormatException('Sesi telah habis. Silakan login kembali.');
    }

    final url = Uri.parse('$_baseUrl/api/admin/profile');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['data'];
      } else if (response.statusCode == 401) {
        await logout();
        throw const FormatException('Sesi Anda telah berakhir. Silakan login kembali.');
      } else {
        final errorData = json.decode(response.body);
        throw FormatException(errorData['message'] ?? 'Gagal mengambil data profil');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      try {
        final String apiUrl = '$_baseUrl/api/admin/logout';
        await http.post(
          Uri.parse(apiUrl),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      } catch (_) {}
    }

    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    await prefs.remove('user_id');

    _isLoggedIn = false;
    _role = 'guest';
    _token = null;
    _userId = null;

    Future.microtask(() {
      notifyListeners();
    });
  }
}
