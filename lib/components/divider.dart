import 'package:flutter/material.dart';

class Divider extends StatelessWidget {
  const Divider({super.key, required Color color, required int thickness, required int height});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0),
      child: Divider(
        color: Color(0xFF8E8E8E),
        thickness: 3,
        height: 1,
      ),
    );
  }
}