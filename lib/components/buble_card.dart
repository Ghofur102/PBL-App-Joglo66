import 'package:flutter/material.dart';

class BubbleCard extends StatelessWidget {
  final String topText;
  final String bottomText;
  final Color? startColor;
  final Color? endColor;
  final double? width;
  final double? height;

  const BubbleCard({
    Key? key,
    required this.topText,
    required this.bottomText,
    this.startColor,
    this.endColor,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 200,
      height: height ?? 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            startColor ?? Color(0xFF64B5F6),
            endColor ?? Color(0xFF42A5F5),
          ],
        ),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 16,
            offset: Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top text
            Text(
              topText,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w600,
                shadows: [
                  Shadow(
                    offset: Offset(0, 2),
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            // Bottom text
            Text(
              bottomText,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(0, 1),
                    blurRadius: 3,
                    color: Colors.black.withOpacity(0.15),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
