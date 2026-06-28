import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? paddingHorizontal;
  final double? borderRadius;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.paddingHorizontal,
    this.borderRadius,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppThemeConstants.accentBlue,
        foregroundColor: textColor ?? Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: paddingHorizontal ?? AppThemeConstants.radiusCircular,
          vertical: 18.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? AppThemeConstants.radiusLarge),
        ),
        elevation: 2,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize ?? 16.0,
          fontWeight: fontWeight ?? FontWeight.bold,
        ),
      ),
    );
  }
}
