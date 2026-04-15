import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BookingService {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? "http://10.28.239.114:8000";
  static final String _token = dotenv.env['API_TOKEN'] ?? "";

  static const int _timeout = 10; // seconds

  /// Create new booking (Danil's endpoint)
  /// POST /api/admin/create-booking
  /// 
  /// Request body:
  /// {
  ///   "details": [
  ///     {
  ///       "fk_field_id": 1,
  ///       "play_date": "2024-04-15",
  ///       "start_play_time": "14:00",
  ///       "end_play_time": "15:00",
  ///       "price": 100000
  ///     }
  ///   ]
  /// }
  static Future<Map<String, dynamic>> createBooking({
    required int fieldId,
    required DateTime playDate,
    required String startTime, // Format: "HH:mm"
    required String endTime,   // Format: "HH:mm"
    required int price,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/admin/create-booking');
      final headers = {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final body = {
        'details': [
          {
            'fk_field_id': fieldId,
            'play_date': playDate.toString().split(' ')[0], // YYYY-MM-DD format
            'start_play_time': startTime,
            'end_play_time': endTime,
            'price': price,
          }
        ]
      };

      print('[BookingService] Creating booking: $url');
      print('[BookingService] Body: ${json.encode(body)}');

      final response = await http
          .post(
            url,
            headers: headers,
            body: json.encode(body),
          )
          .timeout(
            Duration(seconds: _timeout),
            onTimeout: () => throw Exception('Request timeout'),
          );

      print('[BookingService] Status: ${response.statusCode}');
      print('[BookingService] Response: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success' || jsonData['success'] == true) {
          // Handle both response formats
          final bookingId = jsonData['data']?['id'] ?? jsonData['booking_id'];
          return {
            'success': true,
            'booking_id': bookingId,
            'data': jsonData['data'],
          };
        } else {
          throw Exception(jsonData['message_error'] ?? jsonData['message'] ?? 'Failed to create booking');
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('[BookingService] Error creating booking: $e');
      rethrow;
    }
  }

  /// Process cash payment (Danil's endpoint)
  /// POST /api/admin/payment-booking
  ///
  /// Request body:
  /// {
  ///   "fk_booking_id": 42,
  ///   "amount": 100000,
  ///   "payment_type": "down payment"
  /// }
  static Future<Map<String, dynamic>> processCashPayment({
    required int bookingId,
    required int amount,
    String paymentType = 'down payment',
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/admin/payment-booking');
      final headers = {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final body = {
        'fk_booking_id': bookingId,
        'amount': amount,
        'payment_type': paymentType,
      };

      print('[BookingService] Processing payment: $url');
      print('[BookingService] Body: ${json.encode(body)}');

      final response = await http
          .post(
            url,
            headers: headers,
            body: json.encode(body),
          )
          .timeout(
            Duration(seconds: _timeout),
            onTimeout: () => throw Exception('Request timeout'),
          );

      print('[BookingService] Status: ${response.statusCode}');
      print('[BookingService] Response: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success' || jsonData['success'] == true) {
          // Handle different response formats
          final paymentData = jsonData['data_payment'] ?? jsonData['data'] ?? {};
          final paymentId = paymentData['id'] ?? jsonData['payment_id'];
          
          return {
            'success': true,
            'payment_id': paymentId,
            'payment_status': paymentData['status'] ?? 'success',
            'data': paymentData,
          };
        } else {
          throw Exception(jsonData['message_error'] ?? jsonData['message'] ?? 'Failed to process payment');
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('[BookingService] Error processing payment: $e');
      rethrow;
    }
  }
}
