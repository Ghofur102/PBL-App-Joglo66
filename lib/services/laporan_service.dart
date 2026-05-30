import 'package:pbl_app_joglo66/services/api_client.dart';

// DEVELOPER: HUDA

class LaporanService {
  static Future<Map<String, dynamic>> fetchMonthlyLaporan(int month, int year) async {
    // Logic: Hit HTTP GET call ke '/api/admin/laporan-bulanan?bulan=$month&tahun=$year'.
    // Parsing response JSON kalkulasi otomatis neraca keuangan dari backend.
    return {};
  }
}