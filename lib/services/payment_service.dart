import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pbl_app_joglo66/services/api_client.dart';

class PaymentService {
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;
  static SharedPreferences? _prefs;

  static Future<void> _initializePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static String get _token => _prefs?.getString('auth_token') ?? '';

  static Map<String, String> get _headers => {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  /// Melakukan proses pembayaran (DP, Final, Refund, Reschedule)
  /// Endpoint: POST /api/admin/payment-booking
  static Future<Map<String, dynamic>> processPayment({
    required int bookingId,
    required String paymentType,
    required String method,
    required int amount,
    int? bookingDetailId,
    String? referenceId,
  }) async {
    await _initializePrefs();

    try {
      final url = Uri.parse('$_baseUrl/api/admin/payment-booking');

      final body = {
        'booking_id': bookingId,
        'payment_type': paymentType,
        'method': method,
        'amount': amount,
        if (bookingDetailId != null) 'booking_detail_id': bookingDetailId,
        if (referenceId != null) 'reference_id': referenceId,
      };

      final response = await ApiClient.post(url, headers: _headers, body: jsonEncode(body));
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        return jsonData['data'];
      }

      if (response.statusCode == 422) {
        final errors = jsonData['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          throw Exception(errors.values.first[0]);
        }
        throw Exception('Validasi pembayaran gagal. Periksa kembali data Anda.');
      }

      throw Exception(jsonData['message'] ?? 'Gagal memproses pembayaran');
    } catch (e) {
      rethrow;
    }
  }
}