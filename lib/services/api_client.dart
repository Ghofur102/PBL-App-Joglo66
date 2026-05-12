import 'package:http/http.dart' as http;
import 'package:pbl_app_joglo66/router/app_router.dart'; 

class ApiClient {
  static const int _timeout = 30;

  // 1. Pembungkus fungsi GET
  static Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final response = await http.get(url, headers: headers).timeout(const Duration(seconds: _timeout));
    _checkUnauthorized(response.statusCode);
    return response;
  }

  // 2. Pembungkus fungsi POST
  static Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body}) async {
    final response = await http.post(url, headers: headers, body: body).timeout(const Duration(seconds: _timeout));
    _checkUnauthorized(response.statusCode);
    return response;
  }

  // 3. Pembungkus fungsi MULTIPART (Untuk form unggah gambar yang kita buat sebelumnya)
  static Future<http.Response> sendMultipart(http.MultipartRequest request) async {
    final streamedResponse = await request.send().timeout(const Duration(seconds: _timeout));
    final response = await http.Response.fromStream(streamedResponse);
    _checkUnauthorized(response.statusCode);
    return response;
  }
 
  static void _checkUnauthorized(int statusCode) {
    if (statusCode == 401) {
      // 1. Panggil fungsi logout untuk menghapus token dan memicu auto-redirect ke /login
      authService.logout(); 
      
      // 2. Lempar exception agar proses loading di layar berhenti
      throw Exception('Sesi Anda telah habis (401). Silakan login kembali.');
    }
  }
}