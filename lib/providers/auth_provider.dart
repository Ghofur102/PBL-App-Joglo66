import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pbl_app_joglo66/constants/api_endpoints.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _role = 'guest';
  String? _token;
  int? _userId;

  bool get isLoggedIn => _isLoggedIn;
  String get role => _role;
  String? get token => _token;
  int? get userId => _userId;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _role = prefs.getString('user_role') ?? 'guest';
    _userId = prefs.getInt('user_id');
    _isLoggedIn = _token != null && _token!.isNotEmpty;

    Future.microtask(() => notifyListeners());
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.login),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
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
        Future.microtask(() => notifyListeners());
        return {'success': true, 'message': 'Login berhasil'};
      }

      if (response.statusCode == 422) {
        String specificError = 'Validasi gagal.';
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          specificError = errors.values.first[0];
        }
        return {'success': false, 'message': specificError};
      }

      return {
        'success': false,
        'message': data['message'] ?? 'Login gagal. Silakan coba lagi.',
      };
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

    try {
      final response = await http.get(
        Uri.parse(ApiEndpoints.profile),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return json.decode(response.body)['data'];
      }

      if (response.statusCode == 401) {
        await logout();
        throw const FormatException('Sesi Anda telah berakhir. Silakan login kembali.');
      }

      throw FormatException(json.decode(response.body)['message'] ?? 'Gagal mengambil data profil');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final currentToken = prefs.getString('auth_token');

    if (currentToken != null) {
      try {
        await http.post(
          Uri.parse(ApiEndpoints.logout),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $currentToken',
            'Content-Type': 'application/json',
          },
        );
      } catch (_) {
        // Kegagalan jaringan server sengaja diabaikan agar pembersihan lokal tetap berjalan lancar tanpa interupsi
      }
    }

    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    await prefs.remove('user_id');

    _isLoggedIn = false;
    _role = 'guest';
    _token = null;
    _userId = null;

    Future.microtask(() => notifyListeners());
  }
}
