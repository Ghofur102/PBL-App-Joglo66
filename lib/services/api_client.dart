import 'package:http/http.dart' as http;
import 'package:pbl_app_joglo66/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const int _timeout = 30;

  static Future<Map<String, String>> _getDefaultHeaders(Map<String, String>? customHeaders) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final headers = {
      'Accept': 'application/json',
    
    };

    if (token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  static Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final mergedHeaders = await _getDefaultHeaders(headers);
    final response = await http.get(url, headers: mergedHeaders).timeout(const Duration(seconds: _timeout));
    _checkUnauthorized(response.statusCode);
    return response;
  }

  static Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body}) async {
    final mergedHeaders = await _getDefaultHeaders(headers);
    final response = await http.post(url, headers: mergedHeaders, body: body).timeout(const Duration(seconds: _timeout));
    _checkUnauthorized(response.statusCode);
    return response;
  }

  static Future<http.Response> sendMultipart(http.MultipartRequest request) async {
    final mergedHeaders = await _getDefaultHeaders(request.headers);
    request.headers.addAll(mergedHeaders);

    final streamedResponse = await request.send().timeout(const Duration(seconds: _timeout));
    final response = await http.Response.fromStream(streamedResponse);
    _checkUnauthorized(response.statusCode);
    return response;
  }

  static void _checkUnauthorized(int statusCode) {
    if (statusCode == 401) {
      authService.logout();
      throw Exception('Sesi Anda telah habis (401). Silakan login kembali.');
    }
  }
}