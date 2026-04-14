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
          final List<dynamic> fields = jsonData['data']['upcoming'] ?? [];
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
}
