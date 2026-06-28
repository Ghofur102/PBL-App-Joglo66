import 'package:flutter/material.dart';
import 'package:pbl_app_joglo66/constants/app_theme_constants.dart';

class AppInputField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final IconData? icon;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool isEnabled;
  final String? initialValue;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String? prefixText;
  final bool obscureText;
  final Widget? suffixIcon;
  final int maxLines;

  const AppInputField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.icon,
    this.readOnly = false,
    this.onTap,
    this.isEnabled = true,
    this.initialValue,
    this.keyboardType,
    this.validator,
    this.prefixText,
    this.obscureText = false,
    this.suffixIcon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final OutlineInputBorder borderStyle = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppThemeConstants.radiusMedium),
      borderSide: const BorderSide(color: AppThemeConstants.borderGrey),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppThemeConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          enabled: isEnabled,
          keyboardType: keyboardType,
          validator: validator,
          obscureText: obscureText,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: AppThemeConstants.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: AppThemeConstants.textSecondary),
            prefixIcon: icon != null ? Icon(icon, size: 20, color: AppThemeConstants.textSecondary) : null,
            prefixText: prefixText,
            prefixStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppThemeConstants.textPrimary),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isEnabled ? const Color(0xFFF8FAFC) : const Color(0xFFE2E8F0),
            border: borderStyle,
            enabledBorder: borderStyle,
            focusedBorder: borderStyle.copyWith(
              borderSide: const BorderSide(color: AppThemeConstants.accentBlue, width: 1.5),
            ),
            errorBorder: borderStyle.copyWith(
              borderSide: const BorderSide(color: AppThemeConstants.errorRed, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
