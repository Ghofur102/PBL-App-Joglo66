import 'dart:convert';
import 'package:pbl_app_joglo66/constants/api_endpoints.dart';
import 'package:pbl_app_joglo66/services/api_client.dart';

class AttributeService {
  static Future<List<dynamic>> fetchListAttribute({String? search}) async {
    try {
      String urlString = ApiEndpoints.listAttribute;
      if (search != null && search.isNotEmpty) {
        urlString += '?search=$search';
      }

      final response = await ApiClient.get(Uri.parse(urlString));
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        return jsonData['data'] ?? [];
      }
      throw FormatException(jsonData['message'] ?? 'Gagal memuat data atribut');
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<String>> fetchAttributeTypes() async {
    try {
      final response = await ApiClient.get(Uri.parse(ApiEndpoints.attributeTypes));
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        return List<String>.from(jsonData['data'] ?? []);
      }
      throw FormatException(jsonData['message'] ?? 'Gagal memuat jenis atribut');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> fetchDetailAttribute(int id) async {
    try {
      final response = await ApiClient.get(Uri.parse('${ApiEndpoints.detailAttribute}/$id'));
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        return jsonData['data'];
      }
      throw FormatException(jsonData['message'] ?? 'Data atribut tidak ditemukan');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createAttribute({
    required int fkFieldId,
    required String name,
    required String type,
    required int stock,
    required int priceHour,
  }) async {
    try {
      final response = await ApiClient.post(
        Uri.parse(ApiEndpoints.createAttribute),
        body: jsonEncode({
          'fk_field_id': fkFieldId,
          'name': name,
          'type': type,
          'stock': stock,
          'price_hour': priceHour,
        }),
      );

      final jsonData = json.decode(response.body);

      if (response.statusCode == 201 && jsonData['success'] == true) {
        return jsonData['data'];
      }
      throw FormatException(jsonData['message'] ?? 'Gagal menyimpan data atribut');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateAttribute({
    required int id,
    String? name,
    String? type,
    int? stock,
    int? priceHour,
    String? status,
  }) async {
    try {
      final url = Uri.parse('${ApiEndpoints.updateAttribute}/$id');
      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (type != null) body['type'] = type;
      if (stock != null) body['stock'] = stock;
      if (priceHour != null) body['price_hour'] = priceHour;
      if (status != null) body['status'] = status;

      final response = await ApiClient.post(url, body: jsonEncode(body));
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        return jsonData['data'];
      }
      throw FormatException(jsonData['message'] ?? 'Gagal memperbarui data atribut');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteAttribute(int id) async {
    try {
      final response = await ApiClient.post(Uri.parse('${ApiEndpoints.deleteAttribute}/$id'), body: jsonEncode({}));
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        return;
      }
      throw FormatException(jsonData['message'] ?? 'Gagal menghapus data atribut');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> toggleStatus(int id) async {
    try {
      final response = await ApiClient.post(Uri.parse('${ApiEndpoints.toggleAttribute}/$id'), body: jsonEncode({}));
      final jsonData = json.decode(response.body);

      if (response.statusCode == 200 && jsonData['success'] == true) {
        return jsonData['data'];
      }
      throw FormatException(jsonData['message'] ?? 'Gagal mengubah status atribut');
    } catch (e) {
      rethrow;
    }
  }
}
