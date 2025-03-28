import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDarkMode;
  final VoidCallback onPressed;
  final bool isOutlined;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.isDarkMode,
    required this.onPressed,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: isOutlined
              ? null
              : const LinearGradient(
            colors: [
              Color(0xFF4B6EFF),
              Color(0xFF3B5AF8),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          color: isOutlined ? Colors.transparent : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isOutlined
              ? null
              : [
            BoxShadow(
              color: const Color(0xFF4B6EFF).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: isOutlined
              ? Border.all(
            color: isDarkMode ? Colors.white24 : Colors.black12,
            width: 2,
          )
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isOutlined
                        ? (isDarkMode ? Colors.white : Colors.black)
                        : Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: isOutlined
                          ? (isDarkMode ? Colors.white : Colors.black)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}