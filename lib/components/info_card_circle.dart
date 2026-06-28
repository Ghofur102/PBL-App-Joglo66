import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoCardCircle extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const InfoCardCircle({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 115,
      height: 105,
      decoration: BoxDecoration(
        color: Colors.blue.shade300,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.blue.shade400,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
