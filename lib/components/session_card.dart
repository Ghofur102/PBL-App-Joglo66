import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/components/status_badge.dart';

class SessionCard extends StatelessWidget {
  final Map<String, dynamic> session;
  final String fieldName;

  const SessionCard({super.key, required this.session, required this.fieldName});

  @override
  Widget build(BuildContext context) {
    final formatRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final statusLower = session['status'].toString().toLowerCase();

    final bool canModify = ['active', 'reschedule', 'waiting', 'success', 'field closure', 'closed field reschedule'].contains(statusLower);
    final bool isInactive = !canModify && (statusLower.contains('cancel') || statusLower.contains('closure'));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isInactive ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isInactive ? Colors.grey.shade200 : Colors.blue.shade100),
        boxShadow: [if (!isInactive) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(session['play_date'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  StatusBadge(status: session['status']),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text('${session['start_time']} - ${session['end_time']}', style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.sports_soccer, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(fieldName, style: const TextStyle(color: Colors.grey)),
                  const Spacer(),
                  Text(formatRp.format(session['price']), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
              if (canModify) ...[
                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1)),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/admin/change-booking/${session['id']}'),
                    icon: const Icon(Icons.edit_calendar, size: 16),
                    label: const Text('Modify / Cancel Sesi Ini'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue.shade700,
                      side: BorderSide(color: Colors.blue.shade200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                )
              ] else ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                  child: const Text(
                    "Tidak dapat diubah (Status pesanan terkunci)",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}