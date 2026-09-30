import 'package:pbl_app_joglo66/enums/approval_status.dart';
import 'package:pbl_app_joglo66/enums/notification_type.dart';

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'notifiable_type': notifiableType,
    'notifiable_id': notifiableId,
    'data': data.toJson(),
    'read_at': readAt?.toIso8601String(),
    'created_at': createdAt.toIso8601String(),
  };
}

class AppNotificationData {
  final String title;
  final String message;
  final NotificationType type;
  final int? bookingId;
  final int? bookingDetailId;
  final String? url;
  final int? senderId;
  final String senderName;
  final String senderRole;
  final ApprovalStatus decisionStatus;
  final String? rejectionReason;

  AppNotificationData({
    required this.title,
    required this.message,
    required this.type,
    this.bookingId,
    this.bookingDetailId,
    this.url,
    this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.decisionStatus,
    this.rejectionReason,
  });

  factory AppNotificationData.fromJson(Map<String, dynamic> json) {
    return AppNotificationData(
      title: json['title'] ?? 'Pemberitahuan',
      message: json['message'] ?? '',
      type: NotificationType.fromValue(json['type']),
      bookingId: json['booking_id'] != null ? int.tryParse(json['booking_id'].toString()) : null,
      bookingDetailId: json['booking_detail_id'] != null ? int.tryParse(json['booking_detail_id'].toString()) : null,
      url: json['url'],
      senderId: json['sender_id'] != null ? int.tryParse(json['sender_id'].toString()) : null,
      senderName: json['sender_name'] ?? 'Sistem',
      senderRole: json['sender_role'] ?? 'system',
      decisionStatus: ApprovalStatus.fromValue(json['decision_status']),
      rejectionReason: json['rejection_reason'],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'message': message,
    'type': type.value,
    'booking_id': bookingId,
    'booking_detail_id': bookingDetailId,
    'url': url,
    'sender_id': senderId,
    'sender_name': senderName,
    'sender_role': senderRole,
    'decision_status': decisionStatus.value,
    'rejection_reason': rejectionReason,
  };
}
