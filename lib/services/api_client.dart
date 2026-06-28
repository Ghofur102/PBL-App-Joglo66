import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pbl_app_joglo66/providers/auth_provider.dart';

class ApiClient {
  static const int _timeoutSeconds = 30;

  static final AuthProvider authProvider = AuthProvider();

  static Future<Map<String, String>> getHeaders(Map<String, String>? customHeaders) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
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
    final mergedHeaders = await getHeaders(headers);
    final response = await http.get(url, headers: mergedHeaders).timeout(const Duration(seconds: _timeoutSeconds));
    _interceptUnauthorized(response.statusCode);
    return response;
  }

  static Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body}) async {
    final mergedHeaders = await getHeaders(headers);
    final response = await http.post(url, headers: mergedHeaders, body: body).timeout(const Duration(seconds: _timeoutSeconds));
    _interceptUnauthorized(response.statusCode);
    return response;
  }

  static Future<http.Response> sendMultipart(http.MultipartRequest request) async {
    final mergedHeaders = await getHeaders(request.headers);
    request.headers.addAll(mergedHeaders);

    final streamedResponse = await request.send().timeout(const Duration(seconds: _timeoutSeconds));
    final response = await http.Response.fromStream(streamedResponse);
    _interceptUnauthorized(response.statusCode);
    return response;
  }

  static void _interceptUnauthorized(int statusCode) {
    if (statusCode == 401) {
      authProvider.logout();
      throw const FormatException('Sesi Anda telah habis (401). Silakan login kembali.');
    }
  }
}
