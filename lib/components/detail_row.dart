import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBoldValue;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.isBoldValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, color: AppThemeConstants.textSecondary),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
                color: AppThemeConstants.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
