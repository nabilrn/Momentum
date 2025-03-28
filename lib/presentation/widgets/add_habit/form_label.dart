import 'package:flutter/material.dart';

class FormLabel extends StatelessWidget {
  final String label;
  final Color textColor;
  final IconData icon;

  const FormLabel({
    super.key,
    required this.label,
    required this.textColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF4B6EFF),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}