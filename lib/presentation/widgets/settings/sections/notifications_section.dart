// lib/presentation/widgets/settings/sections/notifications_section.dart
import 'package:flutter/material.dart';

class NotificationsSection extends StatelessWidget {
  final bool isDarkMode;
  final Color textColor;
  final Color subtitleColor;
  final Color primaryColor;
  final Color cardColor;
  final bool notificationsEnabled;
  final Function(bool) onNotificationChanged;

  const NotificationsSection({
    Key? key,
    required this.isDarkMode,
    required this.textColor,
    required this.subtitleColor,
    required this.primaryColor,
    required this.cardColor,
    required this.notificationsEnabled,
    required this.onNotificationChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDarkMode
                ? []
                : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSwitchTile(
                  title: 'Habit Reminders',
                  subtitle: 'Get notified 5 minutes before a habit starts',
                  value: notificationsEnabled,
                  onChanged: (value) {
                    onNotificationChanged(value);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: subtitleColor, fontSize: 14),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeColor: primaryColor,
          onChanged: onChanged,
        ),
      ],
    );
  }
}