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

    if (widget.role == 'worker' && notif.data.bookingId != null && mounted) {
      context.push('/admin/booking-detail/${notif.data.bookingId}');
    }
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return 'Hari Ini';
    } else if (itemDate == today.subtract(const Duration(days: 1))) {
      return 'Kemarin';
    }
    return DateFormat('dd MMMM yyyy').format(date);
  }

  Map<String, List<AppNotification>> _groupNotifications() {
    final Map<String, List<AppNotification>> grouped = {};
    for (var item in _notifications) {
      final header = _formatDateHeader(item.createdAt);
      grouped.putIfAbsent(header, () => []).add(item);
    }
    return grouped;
  }

  void _showApproveCancelDialog(String detailBookingId) {
    String selectedRefundStatus = 'None';
    final refundAmountController = TextEditingController(text: '0');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Persetujuan Pembatalan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Tentukan skema pengembalian dana kasir:', style: TextStyle(fontSize: 13, color: AppThemeConstants.textSecondary)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedRefundStatus,
                    decoration: const InputDecoration(
                      labelText: 'Skema Refund',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'None', child: Text('Tanpa Refund (0%)')),
                      DropdownMenuItem(value: 'Partial', child: Text('Sebagian (Kustom)')),
                      DropdownMenuItem(value: 'Full', child: Text('Refund Penuh')),
                    ],
                    onChanged: (val) {
                      setDialogState(() {
                        selectedRefundStatus = val ?? 'None';
                        if (selectedRefundStatus == 'None') {
                          refundAmountController.text = '0';
                        }
                      });
                    },
                  ),
                  if (selectedRefundStatus != 'None') ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: refundAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Nominal Refund (Rp)',
                        prefixText: 'Rp ',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppThemeConstants.successGreen),
                onPressed: () async {
                  final amount = int.tryParse(refundAmountController.text) ?? 0;
                  Navigator.pop(ctx);
                  _processApprovalAction(
                    actionType: 'approve_cancel',
                    detailBookingId: detailBookingId,
                    statusRefund: selectedRefundStatus,
                    refundAmount: amount,
                  );
                },
                child: const Text('Setujui Batal', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRejectDialog({
    required String title,
    required String actionType,
    required String detailBookingId,
  }) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Alasan Penolakan',
            hintText: 'Tuliskan alasan penolakan...',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppThemeConstants.errorRed),
            onPressed: () async {
              Navigator.pop(ctx);
              _processApprovalAction(
                actionType: actionType,
                detailBookingId: detailBookingId,
                reason: reasonController.text,
              );
            },
            child: const Text('Tolak', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _processApprovalAction({
    required String actionType,
    required String detailBookingId,
    String? statusRefund,
    int? refundAmount,
    String? reason,
  }) async {
    setState(() => _isLoading = true);
    try {
      if (actionType == 'approve_cancel') {
        await BookingService.approveCancelBooking(
          detailBookingId: detailBookingId,
          statusRefund: statusRefund ?? 'None',
          refundAmount: refundAmount ?? 0,
        );
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
    final grouped = _groupNotifications();

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
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    itemCount: grouped.keys.length,
                    itemBuilder: (context, groupIndex) {
                      final header = grouped.keys.elementAt(groupIndex);
                      final items = grouped[header]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Text(
                                    header,
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
                              ],
                            ),
                          ),
                          ...items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildNotificationCard(item),
                              )),
                        ],
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildNotificationCard(AppNotification notif) {
    final timeFormat = DateFormat('HH:mm');
    final targetDetailId = (notif.data.bookingDetailId ?? notif.data.bookingId)?.toString();

    final isCancel = notif.data.type.isCancel;
    final isReschedule = notif.data.type.isReschedule;
    final isActionable = notif.data.type.isActionableRequest;
    final status = notif.data.decisionStatus;

    final canApprove = widget.role != 'owner' &&
        isActionable &&
        status.isPending &&
        targetDetailId != null;

    Color badgeColor = Colors.blue.shade50;
    Color iconColor = AppThemeConstants.primaryBlue;
    IconData icon = Icons.notifications;

    if (isCancel) {
      badgeColor = Colors.red.shade50;
      iconColor = AppThemeConstants.errorRed;
      icon = Icons.cancel_outlined;
    } else if (isReschedule) {
      badgeColor = Colors.orange.shade50;
      iconColor = Colors.orange.shade800;
      icon = Icons.edit_calendar;
    }

    return InkWell(
      onTap: () => _handleNotificationTap(notif),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: notif.isUnread ? Colors.blue.shade50.withOpacity(0.35) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notif.isUnread ? AppThemeConstants.primaryBlue.withOpacity(0.3) : AppThemeConstants.borderGrey,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: badgeColor,
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              notif.data.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (notif.isUnread) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(color: AppThemeConstants.primaryBlue, borderRadius: BorderRadius.circular(8)),
                              child: const Text('Baru', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notif.data.message,
                        style: const TextStyle(fontSize: 12, color: AppThemeConstants.textPrimary),
                      ),
                      const SizedBox(height: 6),

                      if (status.isPending) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.amber.shade300),
                          ),
                          child: Text(
                            'Status: Menunggu Keputusan Admin',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                          ),
                        ),
                      ] else if (status.isApproved) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: const Text(
                            'Status: Telah Disetujui',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ),
                      ] else if (status.isRejected) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.red.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status: Telah Ditolak',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppThemeConstants.errorRed),
                              ),
                              if (notif.data.rejectionReason != null && notif.data.rejectionReason!.isNotEmpty)
                                Text(
                                  'Alasan: ${notif.data.rejectionReason}',
                                  style: TextStyle(fontSize: 10, color: Colors.red.shade800),
                                ),
                            ],
                          ),
                        ),
                      ],

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Dari: ${notif.data.senderName} (${notif.data.senderRole})',
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            timeFormat.format(notif.createdAt),
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (canApprove) ...[
              const SizedBox(height: 8),
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppThemeConstants.errorRed,
                        side: const BorderSide(color: AppThemeConstants.errorRed),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        minimumSize: const Size(60, 32),
                        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => _showRejectDialog(
                        title: isCancel ? 'Tolak Pembatalan' : 'Tolak Reschedule',
                        actionType: isCancel ? 'reject_cancel' : 'reject_reschedule',
                        detailBookingId: targetDetailId,
                      ),
                      child: const Text('Tolak'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemeConstants.successGreen,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        minimumSize: const Size(60, 32),
                        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        if (isCancel) {
                          _showApproveCancelDialog(targetDetailId);
                        } else {
                          _processApprovalAction(
                            actionType: 'approve_reschedule',
                            detailBookingId: targetDetailId,
                          );
                        }
                      },
                      child: const Text('Setujui', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
