import 'package:flutter/material.dart';
import '../section_header.dart';
import '../settings_card.dart';

class NotificationsSection extends StatelessWidget {
  final bool isDarkMode;
  final Color textColor;
  final Color subtitleColor;
  final Color primaryColor;
  final Color cardColor;
  final bool notificationsEnabled;
  final Function(bool) onNotificationChanged;

  const NotificationsSection({
    super.key,
    required this.isDarkMode,
    required this.textColor,
    required this.subtitleColor,
    required this.primaryColor,
    required this.cardColor,
    required this.notificationsEnabled,
    required this.onNotificationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Notifications',
          icon: Icons.notifications_outlined,
          textColor: textColor,
        ),
        const SizedBox(height: 12),
        SettingsCard(
          cardColor: cardColor,
          child: SwitchListTile(
            title: Text(
              'Habit Reminders',
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Receive notifications for your habit schedule',
              style: TextStyle(
                color: subtitleColor,
                fontSize: 14,
              ),
            ),
            value: notificationsEnabled,
            activeColor: primaryColor,
            onChanged: onNotificationChanged,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }
}