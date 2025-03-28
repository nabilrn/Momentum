import 'package:flutter/material.dart';

class ColorUtils {
  static Color getPriorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return const Color(0xFF4CAF50); // Green
      case 'Medium':
        return const Color(0xFFFFC107); // Yellow
      case 'High':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF4B6EFF); // Default blue
    }
  }
}