import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';
import 'package:pbl_app_joglo66/models/app_notification_model.dart';
import 'package:pbl_app_joglo66/services/booking_service.dart';
import 'package:pbl_app_joglo66/services/notification_service.dart';

class NotificationListScreen extends StatefulWidget {
  final String role;
  const NotificationListScreen({super.key, required this.role});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  bool _isLoading = true;
  List<AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final items = await NotificationService.fetchNotifications(role: widget.role);
      if (mounted) {
        setState(() {
          _notifications = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppThemeConstants.errorRed),
        );
      }
    }
  }

  Future<void> _handleMarkAllRead() async {
    try {
      await NotificationService.markAllAsRead(role: widget.role);
      await _loadNotifications();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppThemeConstants.errorRed),
        );
      }
    }
  }

  Future<void> _handleNotificationTap(AppNotification notif) async {
    if (notif.isUnread) {
      await NotificationService.markAsRead(role: widget.role, notificationId: notif.id);
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notif.id);
        if (index != -1) {
          _notifications[index] = AppNotification(
            id: notif.id,
            type: notif.type,
            notifiableType: notif.notifiableType,
            notifiableId: notif.notifiableId,
            data: notif.data,
            readAt: DateTime.now(),
            createdAt: notif.createdAt,
          );
        }
      });
    }

    if (notif.data.bookingId != null && mounted) {
      context.push('/admin/booking-detail/${notif.data.bookingId}');
    }
  }

  void _showApprovalDialog({
    required String title,
    required String actionType,
    required String detailBookingId,
  }) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: actionType.contains('reject')
            ? TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Alasan Penolakan',
                  hintText: 'Tuliskan alasan penolakan...',
                ),
                maxLines: 2,
              )
            : const Text('Apakah Anda yakin ingin menyetujui permohonan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: actionType.contains('reject') ? AppThemeConstants.errorRed : AppThemeConstants.successGreen,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              _processApprovalAction(
                actionType: actionType,
                detailBookingId: detailBookingId,
                reason: reasonController.text,
              );
            },
            child: Text(actionType.contains('reject') ? 'Tolak' : 'Setujui', style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _processApprovalAction({
    required String actionType,
    required String detailBookingId,
    String? reason,
  }) async {
    setState(() => _isLoading = true);
    try {
      if (actionType == 'approve_cancel') {
        await BookingService.approveCancelBooking(detailBookingId);
      } else if (actionType == 'reject_cancel') {
        await BookingService.rejectCancelBooking(
          detailBookingId: detailBookingId,
          rejectionReason: reason ?? 'Ditolak oleh admin',
        );
      } else if (actionType == 'approve_reschedule') {
        await BookingService.approveRescheduleBooking(detailBookingId);
      } else if (actionType == 'reject_reschedule') {
        await BookingService.rejectRescheduleBooking(
          detailBookingId: detailBookingId,
          rejectionReason: reason ?? 'Ditolak oleh admin',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aksi berhasil diproses.'), backgroundColor: AppThemeConstants.successGreen),
        );
        _loadNotifications();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppThemeConstants.errorRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifikasi', style: TextStyle(color: AppThemeConstants.textPrimary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Tandai Semua Dibaca',
            icon: const Icon(Icons.done_all, color: AppThemeConstants.primaryBlue),
            onPressed: _handleMarkAllRead,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text('Belum ada notifikasi.', style: TextStyle(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _notifications[index];
                      return _buildNotificationCard(item);
                    },
                  ),
                ),
    );
  }

  Widget _buildNotificationCard(AppNotification notif) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final isCancelRequest = notif.data.type == 'cancel_request';
    final isRescheduleRequest = notif.data.type == 'reschedule_request';
    final canApprove = widget.role != 'owner' && (isCancelRequest || isRescheduleRequest);

    Color badgeColor = Colors.blue.shade50;
    Color iconColor = AppThemeConstants.primaryBlue;
    IconData icon = Icons.notifications;

    if (isCancelRequest || notif.data.type.contains('cancel')) {
      badgeColor = Colors.red.shade50;
      iconColor = AppThemeConstants.errorRed;
      icon = Icons.cancel_outlined;
    } else if (isRescheduleRequest || notif.data.type.contains('reschedule')) {
      badgeColor = Colors.orange.shade50;
      iconColor = Colors.orange.shade800;
      icon = Icons.edit_calendar;
    }

    return InkWell(
      onTap: () => _handleNotificationTap(notif),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isUnread ? Colors.blue.shade50.withOpacity(0.4) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: notif.isUnread ? AppThemeConstants.primaryBlue.withOpacity(0.3) : AppThemeConstants.borderGrey),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: badgeColor,
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              notif.data.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          if (notif.isUnread)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppThemeConstants.primaryBlue, borderRadius: BorderRadius.circular(8)),
                              child: const Text('Baru', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(notif.data.message, style: const TextStyle(fontSize: 13, color: AppThemeConstants.textPrimary)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Dari: ${notif.data.senderName} (${notif.data.senderRole})', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          Text(dateFormat.format(notif.createdAt), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (canApprove && notif.data.bookingId != null) ...[
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppThemeConstants.errorRed,
                      side: const BorderSide(color: AppThemeConstants.errorRed),
                    ),
                    onPressed: () => _showApprovalDialog(
                      title: 'Tolak Permohonan',
                      actionType: isCancelRequest ? 'reject_cancel' : 'reject_reschedule',
                      detailBookingId: notif.data.bookingId.toString(),
                    ),
                    child: const Text('Tolak'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppThemeConstants.successGreen,
                    ),
                    onPressed: () => _showApprovalDialog(
                      title: 'Setujui Permohonan',
                      actionType: isCancelRequest ? 'approve_cancel' : 'approve_reschedule',
                      detailBookingId: notif.data.bookingId.toString(),
                    ),
                    child: const Text('Setujui', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
