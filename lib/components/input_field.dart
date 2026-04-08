import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final IconData? icon;
  final bool readOnly;
  final VoidCallback? onTap;
  final bool isEnabled;
  final String? initialValue;

  const InputField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.icon,
    this.readOnly = false,
    this.onTap,
    this.isEnabled = true,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      enabled: isEnabled,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(),
      ),
    );
  }
}
