import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pbl_app_joglo66/services/api_client.dart'; 
class BookingService {
  // Mengambil Base URL dari .env, dengan fallback ke localhost emulator
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;
  static SharedPreferences? _prefs;

  // 1. Inisialisasi SharedPreferences untuk mengambil Token Sanctum
  static Future<void> _initializePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static String get _token {
    return _prefs?.getString('auth_token') ?? '';
  }

  // Helper untuk membuat header yang konsisten
  static Map<String, String> get _headers {
    return {
      'Authorization': 'Bearer $_token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  /// =====================================================================
  /// 1. GET: /api/admin/list-booking 
  /// =====================================================================
  static Future<Map<String, dynamic>> fetchListBooking({
    int? fieldId,
    String? search,
    String? startDate,
    String? endDate,
  }) async {
    await _initializePrefs();
    try {
      List<String> queryParams = [];
      if (fieldId != null) queryParams.add('field_id=$fieldId');
      if (search != null && search.isNotEmpty) queryParams.add('search=$search');
      if (startDate != null && startDate.isNotEmpty) queryParams.add('start_date=$startDate');
      if (endDate != null && endDate.isNotEmpty) queryParams.add('end_date=$endDate');
      
      String queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final url = Uri.parse('$_baseUrl/api/admin/list-booking$queryString');

      // MENGGUNAKAN API CLIENT (Otomatis handle 401 & Timeout)
      final response = await ApiClient.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['data']; 
      } else {
        throw Exception('Gagal mengambil daftar booking (Error ${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// =====================================================================
  /// 2. POST: /api/admin/create-booking 
  /// =====================================================================
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
    await _initializePrefs(); 

    if (_token.isEmpty) {
      throw Exception('Token tidak ditemukan. Silakan login ulang.');
    }

    try {
      final url = Uri.parse('$_baseUrl/api/admin/create-booking');
      
      // MENGGUNAKAN API CLIENT
      final response = await ApiClient.post(
        url,
        headers: _headers,
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

      final jsonData = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonData; 
      } else {
        throw Exception(jsonData['message'] ?? 'Gagal membuat pesanan.');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// =====================================================================
  /// 3. GET: /api/admin/detail-booking/{id} 
  /// =====================================================================
  static Future<Map<String, dynamic>> fetchBookingDetail(String detailBookingId) async {
    await _initializePrefs();
    try {
      final url = Uri.parse('$_baseUrl/api/admin/detail-booking/$detailBookingId');
      
      // MENGGUNAKAN API CLIENT
      final response = await ApiClient.get(url, headers: _headers);

      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['status'] == 'success') {
        return jsonData['data'];
      } else {
        throw Exception(jsonData['message'] ?? 'Data booking tidak ditemukan');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// =====================================================================
  /// 4. POST: /api/admin/reschedule-booking/{id} 
  /// =====================================================================
  static Future<Map<String, dynamic>> rescheduleBooking({
    required String detailBookingId,
    required String newPlayDate, 
    required String newStartTime, 
    required String newEndTime, 
    required String reason,
    int? fieldClosureId,
    int? newPrice, 
  }) async {
    await _initializePrefs();
    try {
      final url = Uri.parse('$_baseUrl/api/admin/reschedule-booking/$detailBookingId');
      
      // PERBAIKAN SYNTAX DART: Menggunakan (if) di dalam MAP
      final body = {
        'new_play_date': newPlayDate,
        'new_start_time': newStartTime,
        'new_end_time': newEndTime,
        'reason': reason,
        if (fieldClosureId != null) 'fk_field_closure_id': fieldClosureId,
        if (newPrice != null) 'new_price': newPrice, 
      };

      // MENGGUNAKAN API CLIENT
      final response = await ApiClient.post(url, headers: _headers, body: jsonEncode(body));

      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['status'] == 'success') {
        return jsonData;
      } else {
        throw Exception(jsonData['message'] ?? 'Gagal mereschedule jadwal');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// =====================================================================
  /// 5. POST: /api/admin/cancel-booking/{id} 
  /// =====================================================================
  static Future<Map<String, dynamic>> cancelBooking({
    required String detailBookingId,
    required String reason,
    String? statusRefund,
    int? fieldClosureId,
  }) async {
    await _initializePrefs();
    try {
      final url = Uri.parse('$_baseUrl/api/admin/cancel-booking/$detailBookingId');
      
      final body = {
        'reason': reason,
        if (statusRefund != null) 'status_refund': statusRefund,
        if (fieldClosureId != null) 'fk_field_closure_id': fieldClosureId,
      };

      // MENGGUNAKAN API CLIENT
      final response = await ApiClient.post(url, headers: _headers, body: jsonEncode(body));

      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['status'] == 'success') {
        return jsonData;
      } else {
        throw Exception(jsonData['message'] ?? 'Gagal membatalkan booking');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// =====================================================================
  /// 6. GET: /api/admin/list-close-booking 
  /// =====================================================================
  static Future<Map<String, dynamic>> fetchClosedBookings({
    int? fieldId,
    String? date, 
  }) async {
    await _initializePrefs();
    try {
      List<String> queryParams = [];
      if (fieldId != null) queryParams.add('field_id=$fieldId');
      if (date != null && date.isNotEmpty) queryParams.add('date=$date');

      String queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final url = Uri.parse('$_baseUrl/api/admin/list-close-booking$queryString');

      // MENGGUNAKAN API CLIENT
      final response = await ApiClient.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          return jsonData['closed_bookings'];
        } else {
          throw Exception(jsonData['message'] ?? 'Gagal mengambil data closed bookings');
        }
      } else {
        throw Exception('Error server (Code: ${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }
}