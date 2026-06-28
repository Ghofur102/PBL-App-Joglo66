import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';

class InfoBox extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData icon;

  const InfoBox({
    super.key,
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    this.icon = Icons.info_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppThemeConstants.paddingLarge),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppThemeConstants.radiusMedium),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
