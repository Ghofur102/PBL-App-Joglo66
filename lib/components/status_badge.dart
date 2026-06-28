import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  Color _determineStatusColor(String rawStatus) {
    final String formatted = rawStatus.toUpperCase();
    if (formatted.contains('CANCEL')) return AppThemeConstants.errorRed;
    if (formatted.contains('RESCHEDULE')) return Colors.orange;
    if (formatted.contains('CLOSURE')) return Colors.purple;
    if (formatted.contains('WAITING') || formatted.contains('PENDING')) return Colors.amber.shade700;
    return AppThemeConstants.successGreen;
  }

  @override
  Widget build(BuildContext context) {
    final Color baseColor = _determineStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppThemeConstants.radiusSmall),
        border: Border.all(color: baseColor.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: baseColor),
      ),
    );
  }
}
