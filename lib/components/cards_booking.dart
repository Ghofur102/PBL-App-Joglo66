import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pbl_app_joglo66/components/status_badge.dart';

class CardsBooking extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onTap;

  const CardsBooking({super.key, required this.booking, required this.onTap});

  Widget _buildContextualInfo(String status, int totalPaid, int remaining, int refund, NumberFormat formatRp) {
    final s = status.toLowerCase();
    IconData icon = Icons.info_outline;
    Color color = Colors.grey.shade600;
    String text = "";

    if (s == 'cancelled') {
      icon = Icons.money_off_rounded;
      color = Colors.red.shade700;
      text = "Refund: ${formatRp.format(refund)}";
    } else if (s == 'active') {
      if (remaining > 0) {
        icon = Icons.pending_actions;
        color = Colors.orange.shade700;
        text = "Sisa Tagihan: ${formatRp.format(remaining)}";
      } else {
        icon = Icons.check_circle_outline_rounded;
        color = Colors.green.shade700;
        text = "Sudah Dibayar: ${formatRp.format(totalPaid)}";
      }
    } else if (s == 'finish') {
      icon = Icons.assignment_turned_in_outlined;
      color = Colors.green.shade700;
      text = "Sudah Dibayar: ${formatRp.format(totalPaid)}";
    } else if (s == 'reschedule' || s == 'closed field reschedule') {
      if (remaining > 0) {
        icon = Icons.pending_actions;
        color = Colors.orange.shade700;
        text = "Sisa Tagihan: ${formatRp.format(remaining)}";
      } else if (remaining < 0) {
        icon = Icons.add_card_rounded;
        color = Colors.blue.shade700;
        text = "Kelebihan Bayar: ${formatRp.format(remaining.abs())}";
      } else {
        icon = Icons.check_circle_outline_rounded;
        color = Colors.green.shade700;
        text = "Sisa Tagihan: ${formatRp.format(0)}";
      }
    } else if (s == 'field closure') {
      icon = Icons.report_problem_outlined;
      color = Colors.purple.shade700;
      text = "Tindakan Diperlukan: Cancel / Reschedule Sesi";
    } else if (s == 'closed field cancelled') {
      icon = Icons.assignment_return_outlined;
      color = Colors.teal.shade700;
      text = "Refund Full: ${formatRp.format(refund)}";
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: GoogleFonts.poppins(fontSize: 11, color: color, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatRp = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    
    final int itemPrice = int.tryParse(booking['price']?.toString() ?? '0') ?? 0;
    final int totalPaid = int.tryParse(booking['total_paid']?.toString() ?? '0') ?? 0;
    final int remaining = int.tryParse(booking['remaining_payment']?.toString() ?? '0') ?? 0;
    final int refund = int.tryParse(booking['refund_amount']?.toString() ?? '0') ?? 0;
    final String status = booking['status']?.toString() ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 54, height: 54,
                      decoration: BoxDecoration(color: const Color(0xFF406093), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(booking['date'] ?? '', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.1)),
                          Text((booking['month'] ?? '').toString().toUpperCase(), style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booking['title'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
                          const SizedBox(height: 4),
                          Text(booking['description'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
                          Text(booking['time'] ?? '', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        StatusBadge(status: status),
                        const SizedBox(height: 8),
                        Text(formatRp.format(itemPrice), style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF2B6CB0))),
                      ],
                    ),
                  ],
                ),
                _buildContextualInfo(status, totalPaid, remaining, refund, formatRp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}