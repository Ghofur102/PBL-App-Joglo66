import 'package:http/http.dart' as http; // Tetap dipertahankan HANYA untuk membuat objek Multipart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- IMPORT API CLIENT (Pintu Gerbang Utama) ---
import 'package:pbl_app_joglo66/services/api_client.dart';

class FieldService {
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

  // Helper untuk membuat header yang konsisten (Wajib bawa Token & minta JSON)
  static Map<String, String> get _headers {
    return {
      'Authorization': 'Bearer $_token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  /// =====================================================================
  /// 1. GET: /api/admin/list-field (Mencocokkan fungsi index)
  /// =====================================================================
  static Future<List<dynamic>> fetchListField({
    String? search,
    int? limit,
  }) async {
    await _initializePrefs();
    try {
      // Menyusun Query Parameters
      List<String> queryParams = [];
      if (search != null && search.isNotEmpty) queryParams.add('search=$search');
      if (limit != null) queryParams.add('limit=$limit');
      
      String queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final url = Uri.parse('$_baseUrl/api/admin/list-field$queryString');

      // MENGGUNAKAN API CLIENT
      final response = await ApiClient.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          return jsonData['data']; // Mengembalikan array of fields
        } else {
          throw Exception(jsonData['message'] ?? 'Gagal memuat daftar lapangan');
        }
      } else {
        throw Exception('Error server (Code: ${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// =====================================================================
  /// 2. GET: /api/admin/detail-field/{field_id} (Mencocokkan fungsi show)
  /// =====================================================================
  static Future<Map<String, dynamic>> fetchFieldDetail(String fieldId) async {
    await _initializePrefs();
    try {
      final url = Uri.parse('$_baseUrl/api/admin/detail-field/$fieldId');
      
      // MENGGUNAKAN API CLIENT
      final response = await ApiClient.get(url, headers: _headers);

      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['status'] == 'success') {
        return jsonData['data'];
      } else {
        throw Exception(jsonData['message'] ?? 'Data lapangan tidak ditemukan');
      }
    } catch (e) {
      rethrow;
    }
  }
 
 /// =====================================================================
  /// 3. POST/PUT: /api/admin/update-field (Mencocokkan fungsi update)
  /// =====================================================================
  static Future<Map<String, dynamic>> updateField({
    required int id,
    String? name,
    String? description,
    String? category,
    String? imagePath, // <-- MENERIMA PATH FILE FISIK DARI GALERI
    List<Map<String, dynamic>>? pricingRules,
  }) async {
    await _initializePrefs();
    try {
      final url = Uri.parse('$_baseUrl/api/admin/update-field');
      
      // Menggunakan MultipartRequest dari http untuk Upload File
      var request = http.MultipartRequest('POST', url);
      
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      });

      // Masukkan data teks
      request.fields['id'] = id.toString();
      if (name != null) request.fields['name'] = name;
      if (description != null) request.fields['description'] = description;
      if (category != null) request.fields['category'] = category;

      // Masukkan array jadwal dalam bentuk JSON String
      if (pricingRules != null && pricingRules.isNotEmpty) {
        request.fields['pricing_rules'] = json.encode(pricingRules);
      }

      // Masukkan File Gambar Fisik jika ada yang dipilih
      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imagePath),
        );
      }

      // Kirim request ke server MENGGUNAKAN API CLIENT (sendMultipart)
      final response = await ApiClient.sendMultipart(request);

      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && (jsonData['status'] == 'success' || jsonData['success'] == true)) {
        return jsonData['field'] ?? {}; 
      } else if (response.statusCode == 422) {
        throw Exception('Validasi gagal. Cek kembali jadwal harga agar tidak bentrok.');
      } else {
        throw Exception(jsonData['message'] ?? 'Gagal mengupdate lapangan');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// =====================================================================
  /// 4. GET: /api/admin/check-slot-availability/{field_id}/{date} (Cek Slot)
  /// =====================================================================
  static Future<List<dynamic>> checkAvailability({
    required int fieldId,
    required String date, // Format harus YYYY-MM-DD
  }) async {
    await _initializePrefs();
    try {
      final url = Uri.parse('$_baseUrl/api/admin/check-slot-availability/$fieldId/$date');
      
      // MENGGUNAKAN API CLIENT
      final response = await ApiClient.get(url, headers: _headers);

      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['status'] == 'success') {
        return jsonData['available_slots']; // Mengembalikan array jadwal kosong
      } else {
        throw Exception(jsonData['message'] ?? 'Gagal mengecek ketersediaan jadwal');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// =====================================================================
  /// 5. POST: /api/admin/close-field (Mencocokkan fungsi closeField)
  /// =====================================================================
  static Future<Map<String, dynamic>> closeField({
    required int fieldId,
    required String startTime, // Format: YYYY-MM-DD HH:mm:ss
    required String endTime,   // Format: YYYY-MM-DD HH:mm:ss
    required String reason,
  }) async {
    await _initializePrefs();
    try {
      final url = Uri.parse('$_baseUrl/api/admin/close-field');
      
      final body = {
        'fk_field_id': fieldId,
        'field_closure_start_time': startTime,
        'field_closure_end_time': endTime,
        'reason': reason,
      };

      // MENGGUNAKAN API CLIENT
      final response = await ApiClient.post(url, headers: _headers, body: json.encode(body));

      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['status'] == 'success') {
        // Berhasil menutup lapangan, mengembalikan data closure dan daftar booking yang terdampak
        return jsonData;
      } else if (response.statusCode == 422) {
        // Menangkap error validasi dari Laravel (misal: waktu mundur)
        final errors = jsonData['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          throw Exception(errors.values.first[0]); // Ambil pesan error validasi pertama
        }
        throw Exception('Format tanggal/waktu tidak valid');
      } else {
        throw Exception(jsonData['message'] ?? 'Gagal melakukan penutupan lapangan');
      }
    } catch (e) {
      rethrow;
    }
  }
}