import 'dart:convert';
import 'package:pbl_app_joglo66/services/api_client.dart';

// DEVELOPER: HUDA

class RekapService {
  /// Contoh base URL, sesuaikan jika perlu
  static const String _baseUrl = 'https://example.com';

  /// Mengambil data rekap harian dari endpoint
  /// GET /api/admin/rekap-harian?tanggal={date}
  ///
  /// [date] format: 'YYYY-MM-DD'
  /// Return [Map] berisi list transaksi dan ringkasan,
  /// atau throw [Exception] jika status code bukan 200.
  static Future<Map<String, dynamic>> fetchDailyRekap(String date) async {
    // Logic: Lakukan HTTP GET call ke endpoint '/api/admin/rekap-harian?tanggal=$date'.
    // Return data map response atau throw exception jika status code bukan 200.

    final uri = Uri.parse(
      '$_baseUrl/api/admin/rekap-harian',
    ).replace(queryParameters: {'tanggal': date});

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
        'Gagal mengambil data rekap harian. '
        'Status: ${response.statusCode}, '
        'Message: ${decoded['message'] ?? 'Unknown error'}',
      );
    }
  }

  /// Mengambil daftar transaksi dari rekap harian.
  /// Shortcut untuk langsung mendapat List dari response.
  ///
  /// [date] format: 'YYYY-MM-DD'
  static Future<List<dynamic>> fetchDailyTransaksi(String date) async {
    final result = await fetchDailyRekap(date);

    // Sesuaikan key dengan response API — asumsi key 'transaksi'
    if (result.containsKey('transaksi')) {
      return result['transaksi'] as List<dynamic>;
    }

    // Fallback jika response langsung berupa list
    if (result.containsKey('data') && result['data'] is List) {
      return result['data'] as List<dynamic>;
    }

    return [];
  }
}