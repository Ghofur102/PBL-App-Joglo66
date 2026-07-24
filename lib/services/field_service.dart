import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pbl_app_joglo66/constants/api_endpoints.dart';
import 'package:pbl_app_joglo66/services/api_client.dart';

class FieldService {
  static Future<List<dynamic>> fetchListField({
    String? search,
    int? limit,
  }) async {
    try {
      final List<String> queryParams = [];
      if (search != null && search.isNotEmpty) {
        queryParams.add('search=$search');
      }
      if (limit != null) {
        queryParams.add('limit=$limit');
      }

      final String queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final response = await ApiClient.get(
        Uri.parse('${ApiEndpoints.listField}$queryString'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true || jsonData['status'] == 'success') {
          return jsonData['data'] ?? [];
        }
        throw FormatException(
          jsonData['message'] ?? 'Gagal memuat daftar lapangan',
        );
      }
      throw FormatException('Error server (Code: ${response.statusCode})');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> fetchFieldDetail(String fieldId) async {
    try {
      final response = await ApiClient.get(
        Uri.parse('${ApiEndpoints.detailField}/$fieldId'),
      );
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 &&
          (jsonData['success'] == true || jsonData['status'] == 'success' || jsonData.containsKey('data'))) {
        return jsonData['data'] as Map<String, dynamic>;
      }

      throw FormatException(
        jsonData['message'] ?? 'Data lapangan tidak ditemukan',
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateField({
    required int id,
    String? name,
    String? description,
    String? category,
    String? imagePath,
    List<Map<String, dynamic>>? pricingRules,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiEndpoints.updateField),
      );

      request.fields['id'] = id.toString();
      if (name != null) request.fields['name'] = name;
      if (description != null) request.fields['description'] = description;
      if (category != null) request.fields['category'] = category;

      if (pricingRules != null && pricingRules.isNotEmpty) {
        request.fields['pricing_rules'] = json.encode(pricingRules);
      }

      if (imagePath != null && imagePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imagePath),
        );
      }

      final response = await ApiClient.sendMultipart(request);
      final jsonData = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          (jsonData['status'] == 'success' || jsonData['success'] == true)) {
        return jsonData['field'] ?? {};
      }

      if (response.statusCode == 422) {
        throw const FormatException(
          'Validasi gagal. Cek kembali jadwal harga agar tidak bentrok.',
        );
      }
      throw FormatException(jsonData['message'] ?? 'Gagal mengupdate lapangan');
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<dynamic>> checkAvailability({
    required int fieldId,
    required String date,
  }) async {
    try {
      final response = await ApiClient.get(
        Uri.parse('${ApiEndpoints.checkSlot}/$fieldId/$date'),
      );
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && (jsonData['success'] == true || jsonData['status'] == 'success')) {
        final slotsContainer = jsonData['available_slots'];
        if (slotsContainer is Map && slotsContainer.containsKey('available_slots')) {
          return slotsContainer['available_slots'] as List<dynamic>;
        }
        if (slotsContainer is List) {
          return slotsContainer;
        }
      }
      throw FormatException(jsonData['message'] ?? 'Gagal memuat jadwal');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> closeField({
    required int fieldId,
    required String startTime,
    required String endTime,
    required String reason,
  }) async {
    try {
      final body = {
        'fk_field_id': fieldId,
        'field_closure_start_time': startTime,
        'field_closure_end_time': endTime,
        'reason': reason,
      };

      final response = await ApiClient.post(
        Uri.parse(ApiEndpoints.closeField),
        body: json.encode(body),
      );
      final jsonData = json.decode(response.body);

      final bool isSuccessCode = response.statusCode == 200 || response.statusCode == 201;
      final bool isSuccessData = jsonData['status'] == 'success' || jsonData['success'] == true;

      if (isSuccessCode && isSuccessData) {
        return jsonData;
      }

      if (response.statusCode == 422) {
        final errors = jsonData['errors'] as Map<String, dynamic>?;
        if (errors != null && errors.isNotEmpty) {
          throw FormatException(errors.values.first[0]);
        }
        throw const FormatException('Format tanggal/waktu tidak valid');
      }

      throw FormatException(
        jsonData['message'] ?? 'Gagal melakukan penutupan lapangan',
      );
    } catch (e) {
      rethrow;
    }
  }
}
