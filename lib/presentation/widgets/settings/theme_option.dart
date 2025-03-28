import 'package:flutter/material.dart';

class ThemeOption extends StatelessWidget {
  final String title;
  final String value;
  final String groupValue;
  final bool isDarkMode;
  final Color textColor;
  final Color primaryColor;
  final Function(String?) onChanged;

  const ThemeOption({
    super.key,
    required this.title,
    required this.value,
    required this.groupValue,
    required this.isDarkMode,
    required this.textColor,
    required this.primaryColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: groupValue == value ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      value: value,
      groupValue: groupValue,
      activeColor: primaryColor,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}