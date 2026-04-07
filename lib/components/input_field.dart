import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final bool isEnabled;
  final TextEditingController? controller;
  final IconData? icon;
  final int maxLines;
  
  // --- TAMBAHAN BARU ---
  final TextInputType? keyboardType; // Untuk tipe keyboard (email, angka, dll)
  final bool readOnly;               // Agar tidak memunculkan keyboard saat diklik (untuk kalender)
  final VoidCallback? onTap;         // Aksi ketika form diklik (untuk memunculkan pop-up)

  const InputField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.isEnabled = true,
    this.controller,
    this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.readOnly = false, // Default-nya false (bisa diketik)
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final txtController = controller ?? TextEditingController(text: initialValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isEnabled ? Colors.black87 : Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: txtController,
          enabled: isEnabled,
          maxLines: maxLines,
          
          // --- TERAPKAN DI SINI ---
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          
          style: TextStyle(color: isEnabled ? Colors.black : Colors.grey.shade600),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: isEnabled ? Colors.white : Colors.grey.shade300,
            suffixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}