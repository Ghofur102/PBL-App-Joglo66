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

      final response = await ApiClient.post(Uri.parse(ApiEndpoints.rentAttribute), body: jsonEncode(body));
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        return jsonData['data'];
      }

      if (response.statusCode == 422) {
        final errors = jsonData['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          throw FormatException(errors.values.first[0]);
        }
        throw const FormatException('Validasi pembayaran gagal. Periksa kembali data Anda.');
      }

      throw FormatException(jsonData['message'] ?? 'Gagal memproses pembayaran');
    } catch (e) {
      rethrow;
    }
  }
}
