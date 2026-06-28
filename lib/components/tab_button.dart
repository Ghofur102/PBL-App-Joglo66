import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';

class TabButton extends StatelessWidget {
  final String title;
  final IconData? icon;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback onTap;

  const TabButton({
    super.key,
    required this.title,
    this.icon,
    required this.isActive,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? (activeColor ?? AppThemeConstants.accentBlue)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(AppThemeConstants.radiusMedium),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isActive ? Colors.white : AppThemeConstants.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : AppThemeConstants.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
