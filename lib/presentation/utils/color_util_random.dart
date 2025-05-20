import 'package:flutter/material.dart';

class ColorUtils {
  static Color getPriorityColor(String priority) {
    switch (priority) {
      case 'low':
        return const Color(0xFF4CAF50); // Green
      case 'medium':
        return const Color(0xFFFFC107); // Yellow
      case 'high':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF4B6EFF); // Default blue
    }
  }
}