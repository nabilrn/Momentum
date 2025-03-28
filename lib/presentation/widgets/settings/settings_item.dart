import 'package:flutter/material.dart';

class SettingsItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDarkMode;
  final Color textColor;
  final Color subtitleColor;
  final VoidCallback? onTap;

  const SettingsItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isDarkMode,
    required this.textColor,
    required this.subtitleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withOpacity(0.05)
              : const Color(0xFF4B6EFF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF4B6EFF),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: subtitleColor,
          fontSize: 14,
        ),
      ),
      trailing: onTap != null
          ? const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFF6B89FF),
        size: 22,
      )
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}