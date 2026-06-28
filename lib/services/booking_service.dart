import 'dart:convert';
import 'package:pbl_app_joglo66/constants/api_endpoints.dart';
import 'package:pbl_app_joglo66/services/api_client.dart';

class BookingService {
  static Future<Map<String, dynamic>> fetchListBooking({
    int? fieldId,
    String? search,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final List<String> queryParams = [];
      if (fieldId != null) queryParams.add('field_id=$fieldId');
      if (search != null && search.isNotEmpty) queryParams.add('search=$search');
      if (startDate != null && startDate.isNotEmpty) queryParams.add('start_date=$startDate');
      if (endDate != null && endDate.isNotEmpty) queryParams.add('end_date=$endDate');

      final String queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final response = await ApiClient.get(Uri.parse('${ApiEndpoints.listBooking}$queryString'));

      if (response.statusCode == 200) {
        return json.decode(response.body)['data'];
      }
      throw FormatException('Gagal mengambil daftar booking (Error ${response.statusCode})');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createBooking({
    required int userId,
    required int fieldId,
    required String teamName,
    required String bookingDate,
    required List<Map<String, dynamic>> details,
    String? customerPhone,
    String? customerEmail,
    String? notes,
  }) async {
    try {
      final response = await ApiClient.post(
        Uri.parse(ApiEndpoints.createBooking),
        body: jsonEncode({
          'user_id': userId,
          'field_id': fieldId,
          'team_name': teamName,
          'booking_date': bookingDate,
          'details': details,
          'customer_phone': customerPhone,
          'customer_email': customerEmail,
          'notes': notes,
        }),
      );

      return json.decode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> fetchBookingDetail(String detailBookingId) async {
    try {
      final response = await ApiClient.get(Uri.parse('${ApiEndpoints.detailBooking}/$detailBookingId'));
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['status'] == 'success') {
        return jsonData['data'];
      }
      throw FormatException(jsonData['message'] ?? 'Data booking tidak ditemukan');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> rescheduleBooking({
    required String detailBookingId,
    required String newPlayDate,
    required String newStartTime,
    required String newEndTime,
    required String reason,
    int? fieldClosureId,
    int? newPrice,
  }) async {
    try {
      final body = {
        'new_play_date': newPlayDate,
        'new_start_time': newStartTime,
        'new_end_time': newEndTime,
        'reason': reason,
        if (fieldClosureId != null) 'fk_field_closure_id': fieldClosureId,
        if (newPrice != null) 'new_price': newPrice,
      };

      final response = await ApiClient.post(
        Uri.parse('${ApiEndpoints.rescheduleBooking}/$detailBookingId'),
        body: jsonEncode(body),
      );
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['status'] == 'success') {
        return jsonData;
      }
      throw FormatException(jsonData['message'] ?? 'Gagal mereschedule jadwal');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> cancelBooking({
    required String detailBookingId,
    required String reason,
    String? statusRefund,
    int? fieldClosureId,
  }) async {
    try {
      final body = {
        'reason': reason,
        if (statusRefund != null) 'status_refund': statusRefund,
        if (fieldClosureId != null) 'fk_field_closure_id': fieldClosureId,
      };

      final response = await ApiClient.post(
        Uri.parse('${ApiEndpoints.cancelBooking}/$detailBookingId'),
        body: jsonEncode(body),
      );
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['status'] == 'success') {
        return jsonData;
      }
      throw FormatException(jsonData['message'] ?? 'Gagal membatalkan booking');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> fetchClosedBookings({
    int? fieldId,
    String? date,
  }) async {
    try {
      final List<String> queryParams = [];
      if (fieldId != null) queryParams.add('field_id=$fieldId');
      if (date != null && date.isNotEmpty) queryParams.add('date=$date');

      final String queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final response = await ApiClient.get(Uri.parse('${ApiEndpoints.listClosedBooking}$queryString'));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          return jsonData['closed_bookings'];
        }
        throw FormatException(jsonData['message'] ?? 'Gagal mengambil data closed bookings');
      }
      throw FormatException('Error server (Code: ${response.statusCode})');
    } catch (e) {
      rethrow;
    }
  }
}
