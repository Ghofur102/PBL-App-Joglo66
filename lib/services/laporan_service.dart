import 'dart:convert';
import 'package:pbl_app_joglo66/services/api_client.dart';

// DEVELOPER: HUDA

class LaporanService {
  /// Contoh base URL, sesuaikan jika perlu
  static const String _baseUrl = 'https://example.com';

  /// Mengambil data laporan bulanan dari endpoint
  /// GET /api/admin/laporan-bulanan?bulan={month}&tahun={year}
  ///
  /// Return [Map] berisi field dari financial_reports + breakdown expenses,
  /// atau throw [Exception] jika status code bukan 200.
  static Future<Map<String, dynamic>> fetchMonthlyLaporan(
      int month, int year) async {
    // Logic: Hit HTTP GET call ke '/api/admin/laporan-bulanan?bulan=$month&tahun=$year'.
    // Parsing response JSON kalkulasi otomatis neraca keuangan dari backend.

    final uri = Uri.parse(
      '$_baseUrl/api/admin/laporan-bulanan',
    ).replace(queryParameters: {
      'bulan': month.toString(),
      'tahun': year.toString(),
    });

    final response = await ApiClient.get(uri);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
        return decoded['data'] as Map<String, dynamic>;
      }

      return decoded as Map<String, dynamic>;
    } else {
      final decoded = jsonDecode(response.body);
      throw Exception(
        'Gagal mengambil laporan bulanan. '
        'Status: ${response.statusCode}, '
        'Message: ${decoded['message'] ?? 'Unknown error'}',
      );
    }
  }
}