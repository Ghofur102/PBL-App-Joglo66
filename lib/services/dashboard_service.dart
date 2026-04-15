import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DashboardService {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? "http://10.28.239.114:8000";
  static final String _token = dotenv.env['API_TOKEN'] ?? "";

  static const int _timeout = 10; // seconds

  /// Fetch dashboard data dari API
  /// Returns: Map dengan keys: name, slotTerisi, totalSlot, slotKosong, totalBooking
  static Future<Map<String, dynamic>> fetchDashboardData() async {
    try {
      final url = Uri.parse('$_baseUrl/api/admin/dashboard');
      final headers = {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      print('[DashboardService] Fetching: $url');

      final response = await http.get(url, headers: headers).timeout(
        Duration(seconds: _timeout),
        onTimeout: () => throw Exception('Request timeout'),
      );

      print('[DashboardService] Status: ${response.statusCode}');
      print('[DashboardService] Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          // Extract data dari response
          final data = jsonData['data'] as Map<String, dynamic>;
          
          return {
            'name': data['name'] ?? 'Joglo66',
            'slotTerisi': data['slotTerisi'] ?? 0,
            'totalSlot': data['totalSlot'] ?? 0,
            'slotKosong': data['slotKosong'] ?? 0,
            'totalBooking': data['totalBooking'] ?? 0,
          };
        } else {
          throw Exception(jsonData['message'] ?? 'Gagal mengambil data dashboard');
        }
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('[DashboardService] Error: $e');
      rethrow;
    }
  }

  /// Fetch daftar field/lapangan
  static Future<List<Map<String, dynamic>>> fetchFields() async {
    try {
      final url = Uri.parse('$_baseUrl/api/admin/list-field');
      final headers = {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      };

      print('[DashboardService] Fetching fields: $url');

      final response = await http.get(url, headers: headers).timeout(
        Duration(seconds: _timeout),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          // Response format: data is direct array, not { upcoming: [...] }
          final List<dynamic> fields = jsonData['data'] ?? [];
          return fields.map((field) => field as Map<String, dynamic>).toList();
        } else {
          throw Exception(jsonData['message'] ?? 'Gagal mengambil data lapangan');
        }
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      print('[DashboardService] Error fetching fields: $e');
      rethrow;
    }
  }

  /// Fetch daftar booking
  static Future<Map<String, dynamic>> fetchBookings() async {
    try {
      final url = Uri.parse('$_baseUrl/api/admin/list-booking');
      final headers = {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      };

      print('[DashboardService] Fetching bookings: $url');

      final response = await http.get(url, headers: headers).timeout(
        Duration(seconds: _timeout),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          return jsonData['data'] as Map<String, dynamic>;
        } else {
          throw Exception(jsonData['message'] ?? 'Gagal mengambil data booking');
        }
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      print('[DashboardService] Error fetching bookings: $e');
      rethrow;
    }
  }

  /// Fetch available slots untuk field tertentu pada tanggal tertentu
  /// GET /api/admin/check-slot-availability/{field_id}/{date}
  static Future<List<Map<String, dynamic>>> fetchAvailableSlots(int fieldId, DateTime date) async {
    try {
      final dateStr = date.toString().split(' ')[0]; // YYYY-MM-DD format
      final url = Uri.parse('$_baseUrl/api/admin/check-slot-availability/$fieldId/$dateStr');
      final headers = {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      };

      print('[DashboardService] Fetching slots: $url');

      final response = await http.get(url, headers: headers).timeout(
        Duration(seconds: _timeout),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['status'] == 'success') {
          final List<dynamic> slots = jsonData['available_slots'] ?? [];
          return slots.map((slot) => slot as Map<String, dynamic>).toList();
        } else {
          throw Exception(jsonData['message'] ?? 'Gagal mengambil available slots');
        }
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      print('[DashboardService] Error fetching slots: $e');
      rethrow;
    }
  }

  /// Fetch field prices untuk field tertentu
  /// GET /api/admin/field-prices/{field_id}
  /// Returns list of price tiers berdasarkan time dan day type
  static Future<List<Map<String, dynamic>>> fetchFieldPrices(int fieldId) async {
    try {
      final url = Uri.parse('$_baseUrl/api/admin/field-prices/$fieldId');
      final headers = {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      };

      print('[DashboardService] Fetching field prices: $url');

      final response = await http.get(url, headers: headers).timeout(
        Duration(seconds: _timeout),
        onTimeout: () => throw Exception('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['success'] == true) {
          final List<dynamic> prices = jsonData['data'] ?? [];
          return prices.map((price) => price as Map<String, dynamic>).toList();
        } else {
          throw Exception(jsonData['message'] ?? 'Gagal mengambil field prices');
        }
      } else {
        throw Exception('Error ${response.statusCode}');
      }
    } catch (e) {
      print('[DashboardService] Error fetching field prices: $e');
      rethrow;
    }
  }
}
