import 'dart:convert';
import 'package:pbl_app_joglo66/constants/api_endpoints.dart';
import 'package:pbl_app_joglo66/services/api_client.dart';

class PaymentService {
  static Future<Map<String, dynamic>> processPayment({
    required int bookingId,
    required String paymentType,
    required String method,
    required int amount,
    int? bookingDetailId,
    String? referenceId,
  }) async {
    try {
      final body = {
        'booking_id': bookingId,
        'payment_type': paymentType,
        'method': method,
        'amount': amount,
        if (bookingDetailId != null) 'booking_detail_id': bookingDetailId,
        if (referenceId != null) 'reference_id': referenceId,
      };

      // 🟢 LOG 1: Pantau data yang dikirim dari Flutter
      print("🚀 [PAYMENT REQ] Mengirim Payload ke Laravel: $body");

      final response = await ApiClient.post(
        Uri.parse(ApiEndpoints.paymentBooking),
        body: jsonEncode(body)
      );

      // 🟢 LOG 2: Cetak BALIKAN MURNI dari Laravel secara transparan di terminal
      print("============= RAW PAYMENT RESPONSE FROM LARAVEL =============");
      print("HTTP Status Code : ${response.statusCode}");
      print("Raw Response Body: ${response.body}");
      print("=============================================================");

      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && (jsonData['success'] == true || jsonData['status'] == 'success')) {
        return (jsonData['data'] ?? jsonData) as Map<String, dynamic>;
      }

      // Menangani Eror Validasi Form (422)
      if (response.statusCode == 422) {
        final errors = jsonData['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          throw FormatException(errors.values.first[0]);
        }
        throw FormatException(jsonData['message'] ?? 'Validasi pembayaran gagal.');
      }

      // 🟢 IMPROVEMENT: Sertakan pesan asli dari Laravel + Status Code agar tidak menjadi pesan generic
      final String serverMessage = jsonData['message'] ?? 'Gagal memproses pembayaran';
      throw FormatException('$serverMessage (Status: ${response.statusCode})');

    } catch (e, stacktrace) {
      // 🟢 LOG 3: Menangkap crash internal Dart atau hilangnya koneksi internet
      print("🔴 [CRITICAL ERROR] Terjadi kegagalan di PaymentService: $e");
      print("📜 [STACKTRACE LENGKAP]:\n$stacktrace");
      rethrow;
    }
  }
}
