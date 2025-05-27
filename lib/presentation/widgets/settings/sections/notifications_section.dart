import 'package:flutter/material.dart';

class NotificationsSection extends StatelessWidget {
  final bool isDarkMode;
  final Color textColor;
  final Color subtitleColor;
  final Color primaryColor;
  final Color cardColor;
  final bool notificationsEnabled;
  final Function(bool) onNotificationChanged;
  final bool isLoading;

  const NotificationsSection({
    super.key,
    required this.isDarkMode,
    required this.textColor,
    required this.subtitleColor,
    required this.primaryColor,
    required this.cardColor,
    required this.notificationsEnabled,
    required this.onNotificationChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDarkMode
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ]
            : [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: primaryColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Notifications',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Habit Reminders Toggle
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Habit Reminders',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Get notified 2 minutes before each habit starts',
                          style: TextStyle(
                            color: subtitleColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  isLoading
                      ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  )
                      : Switch(
                    value: notificationsEnabled,
                    onChanged: isLoading ? null : onNotificationChanged,
                    activeColor: primaryColor,
                    inactiveThumbColor: subtitleColor,
                    inactiveTrackColor: subtitleColor.withOpacity(0.3),
                  ),
                ],
              ),
            ),

            // Additional info when notifications are enabled
            if (notificationsEnabled && !isLoading) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Notifications are active for all habits with scheduled times',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}