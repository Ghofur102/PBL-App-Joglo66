import 'package:pbl_app_joglo66/services/api_client.dart';

// DEVELOPER: ZAMI

class PdfService {
  static Future<Map<String, dynamic>> fetchPdfPreview(int month, int year) async {
    // Logic: Tarik representasi struktur preview data bulanan dari '/api/admin/laporan-pdf/preview'.
    return {};
  }
  static String getDownloadPdfUrl(int month, int year) {
    // Logic: Mengembalikan nilai absolute string URL endpoint unduh file mentah PDF laporan bulanan.
    return "/api/admin/laporan-pdf/download?bulan=$month&tahun=$year";
  }
}