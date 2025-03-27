import 'package:flutter/material.dart';

class FilterSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color primaryColor;
  final bool isDarkMode;
  final Widget child;

  const FilterSection({
    super.key,
    required this.title,
    required this.icon,
    required this.primaryColor,
    required this.isDarkMode,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(
                icon,
                color: primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        child,
        const SizedBox(height: 16),
        Divider(
          color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
        ),
      ],
    );
  }
}