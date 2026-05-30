import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text = status.toUpperCase();

    if (text.contains('CANCEL')) {
      color = Colors.red;
    } else if (text.contains('RESCHEDULE')) {
      color = Colors.orange;
    } else if (text.contains('CLOSURE')) {
      color = Colors.purple;
    } else if (text == 'WAITING' || text == 'PENDING') {
      color = Colors.amber.shade700;
    } else {
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}