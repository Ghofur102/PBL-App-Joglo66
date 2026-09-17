class AppNotification {
  final String id;
  final String type;
  final String notifiableType;
  final int notifiableId;
  final AppNotificationData data;
  final DateTime? readAt;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.notifiableType,
    required this.notifiableId,
    required this.data,
    this.readAt,
    required this.createdAt,
  });

  bool get isUnread => readAt == null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      notifiableType: json['notifiable_type']?.toString() ?? '',
      notifiableId: int.tryParse(json['notifiable_id']?.toString() ?? '0') ?? 0,
      data: AppNotificationData.fromJson(json['data'] is Map<String, dynamic> ? json['data'] : {}),
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at']) : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now(),
    );
  }
}

class AppNotificationData {
  final String title;
  final String message;
  final String type;
  final int? bookingId;
  final String? url;
  final int? senderId;
  final String senderName;
  final String senderRole;

  AppNotificationData({
    required this.title,
    required this.message,
    required this.type,
    this.bookingId,
    this.url,
    this.senderId,
    required this.senderName,
    required this.senderRole,
  });

  factory AppNotificationData.fromJson(Map<String, dynamic> json) {
    return AppNotificationData(
      title: json['title'] ?? 'Pemberitahuan',
      message: json['message'] ?? '',
      type: json['type'] ?? 'info',
      bookingId: json['booking_id'] != null ? int.tryParse(json['booking_id'].toString()) : null,
      url: json['url'],
      senderId: json['sender_id'] != null ? int.tryParse(json['sender_id'].toString()) : null,
      senderName: json['sender_name'] ?? 'Sistem',
      senderRole: json['sender_role'] ?? 'system',
    );
  }
}
