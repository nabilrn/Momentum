import 'package:flutter/material.dart';
import 'package:momentum/core/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:momentum/presentation/providers/auth_provider.dart';

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
    return Card(
      color: cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                'Habit Reminders',
                style: TextStyle(color: textColor),
              ),
              subtitle: Text(
                'Get notified 15 minutes before a habit starts',
                style: TextStyle(color: subtitleColor),
              ),
              trailing: Switch(
                value: notificationsEnabled,
                activeColor: primaryColor,
                onChanged: onNotificationChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
}