import 'package:flutter/material.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor ?? Theme.of(context).primaryColor
              : Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.black87,
                size: 20,
              ),
            if (icon != null) const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
