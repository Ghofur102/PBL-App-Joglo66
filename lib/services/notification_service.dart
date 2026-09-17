import 'dart:convert';
import 'package:pbl_app_joglo66/constants/api_endpoints.dart';
import 'package:pbl_app_joglo66/models/app_notification_model.dart';
import 'package:pbl_app_joglo66/services/api_client.dart';

class NotificationService {
  static Future<List<AppNotification>> fetchNotifications({
    required String role,
    int perPage = 20,
  }) async {
    final String url = role == 'owner'
        ? ApiEndpoints.ownerNotifications(perPage: perPage)
        : ApiEndpoints.adminNotifications(perPage: perPage);

    final response = await ApiClient.get(Uri.parse(url));
    final jsonData = json.decode(response.body);

    if (response.statusCode == 200 && jsonData['success'] == true) {
      final List list = jsonData['data']['data'] ?? [];
      return list.map((item) => AppNotification.fromJson(item)).toList();
    }

    throw FormatException(jsonData['message'] ?? 'Gagal mengambil notifikasi.');
  }

  static Future<int> fetchUnreadCount({required String role}) async {
    final String url = role == 'owner'
        ? ApiEndpoints.ownerNotificationUnreadCount
        : ApiEndpoints.adminNotificationUnreadCount;

    final response = await ApiClient.get(Uri.parse(url));
    final jsonData = json.decode(response.body);

    if (response.statusCode == 200 && jsonData['success'] == true) {
      return int.tryParse(jsonData['unread_count'].toString()) ?? 0;
    }

    return 0;
  }

  static Future<void> markAsRead({
    required String role,
    required String notificationId,
  }) async {
    final String url = role == 'owner'
        ? ApiEndpoints.ownerNotificationMarkRead(notificationId)
        : ApiEndpoints.adminNotificationMarkRead(notificationId);

    final response = await ApiClient.post(Uri.parse(url));
    final jsonData = json.decode(response.body);

    if (response.statusCode != 200 || jsonData['success'] != true) {
      throw FormatException(jsonData['message'] ?? 'Gagal memperbarui status notifikasi.');
    }
  }

  static Future<void> markAllAsRead({required String role}) async {
    final String url = role == 'owner'
        ? ApiEndpoints.ownerNotificationMarkAllRead
        : ApiEndpoints.adminNotificationMarkAllRead;

    final response = await ApiClient.post(Uri.parse(url));
    final jsonData = json.decode(response.body);

    if (response.statusCode != 200 || jsonData['success'] != true) {
      throw FormatException(jsonData['message'] ?? 'Gagal menandai semua dibaca.');
    }
  }
}
