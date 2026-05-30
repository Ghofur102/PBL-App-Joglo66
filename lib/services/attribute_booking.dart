import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pbl_app_joglo66/services/api_client.dart';
import 'package:pbl_app_joglo66/models/rental_item_model.dart';

class AttributeBookingService {
  static final String _baseUrl = dotenv.env['API_BASE_URL']!;
  static SharedPreferences? _prefs;

  static Future<void> _initializePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static String get _token => _prefs?.getString('auth_token') ?? '';

  static Map<String, String> get headers => {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  static int calculateTotalPrice(List<RentalItemModel> items, int duration) {
    int total = 0;
    for (final item in items) {
      if (item.selectedAttributeId != null) {
        total += item.price * item.quantity * duration;
      }
    }
    return total;
  }

  static List<Map<String, dynamic>> formatRentalPayload(List<RentalItemModel> items) {
    return items.map((item) => {
      'fk_attribute_id': item.selectedAttributeId,
      'quantity': item.quantity,
      'name': item.name,
      'price_hour': item.price,
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> fetchActiveBookings() async {
    await _initializePrefs();
    try {
      final url = Uri.parse('$_baseUrl/api/admin/active-bookings');
      final response = await ApiClient.get(url, headers: headers);
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        return List<Map<String, dynamic>>.from(jsonData['data'] ?? []);
      }
      throw Exception(jsonData['message'] ?? 'Gagal memuat daftar booking aktif');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> rentAttribute({
    required int fkBookingId,
    required List<Map<String, dynamic>> items,
    required String customerName,
    String? customerPhone,
    required int durationHours,
    required String transactionDate,
  }) async {
    await _initializePrefs();
    try {
      final url = Uri.parse('$_baseUrl/api/admin/rent-attribute');
      final response = await ApiClient.post(
        url,
        headers: headers,
        body: jsonEncode({
          'fk_booking_id': fkBookingId,
          'items': items,
          'customer_name': customerName,
          'customer_phone': customerPhone ?? '',
          'duration_hours': durationHours,
          'transaction_date': transactionDate,
        }),
      );

      final jsonData = json.decode(response.body);

      if (response.statusCode == 201 && jsonData['success'] == true) {
        return jsonData['data'];
      }

      if (response.statusCode == 422) {
        throw Exception(jsonData['message'] ?? 'Validasi gagal');
      }

      throw Exception(jsonData['message'] ?? 'Gagal memproses penyewaan');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> returnItem(int id) async {
    await _initializePrefs();
    try {
      final url = Uri.parse('$_baseUrl/api/admin/return-rent-attribute/$id');
      final response = await ApiClient.post(url, headers: headers);
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        return jsonData['data'];
      }

      throw Exception(jsonData['message'] ?? 'Gagal memproses pengembalian');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> fetchHistory({
    String? search,
    String? startDate,
    String? endDate,
    String? status,
    int? limit,
  }) async {
    await _initializePrefs();
    try {
      List<String> queryParams = [];
      if (search != null && search.isNotEmpty) queryParams.add('search=$search');
      if (startDate != null && startDate.isNotEmpty) queryParams.add('start_date=$startDate');
      if (endDate != null && endDate.isNotEmpty) queryParams.add('end_date=$endDate');
      if (status != null && status.isNotEmpty) queryParams.add('status=$status');
      if (limit != null) queryParams.add('limit=$limit');

      String queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final url = Uri.parse('$_baseUrl/api/admin/history-rent-attribute$queryString');
      final response = await ApiClient.get(url, headers: headers);
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        return jsonData['data'];
      }

      throw Exception(jsonData['message'] ?? 'Gagal memuat riwayat');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> fetchDetail(int id) async {
    await _initializePrefs();
    try {
      final url = Uri.parse('$_baseUrl/api/admin/detail-rent-attribute/$id');
      final response = await ApiClient.get(url, headers: headers);
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        return jsonData['data'];
      }

      throw Exception(jsonData['message'] ?? 'Data penyewaan tidak ditemukan');
    } catch (e) {
      rethrow;
    }
  }
}