import 'package:flutter/material.dart';

class HeaderTwo extends StatelessWidget {
  final String title;
  final Color? color;

  const HeaderTwo({
    super.key,
    required this.title,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
