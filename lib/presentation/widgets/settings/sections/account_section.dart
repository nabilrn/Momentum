import 'package:flutter/material.dart';
import '../section_header.dart';
import '../settings_card.dart';
import '../settings_item.dart';

class AccountSection extends StatelessWidget {
  final bool isDarkMode;
  final Color textColor;
  final Color subtitleColor;
  final Color cardColor;

  const AccountSection({
    super.key,
    required this.isDarkMode,
    required this.textColor,
    required this.subtitleColor,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Account',
          icon: Icons.person_outline,
          textColor: textColor,
        ),
        const SizedBox(height: 12),
        SettingsCard(
          cardColor: cardColor,
          child: Column(
            children: [
              SettingsItem(
                title: 'Data Backup',
                subtitle: 'Back up your habits progress to cloud',
                icon: Icons.backup_outlined,
                isDarkMode: isDarkMode,
                textColor: textColor,
                subtitleColor: subtitleColor,
                onTap: () {
                  // Handle backup action
                },
              ),
              const Divider(height: 1),
              SettingsItem(
                title: 'Export Data',
                subtitle: 'Export your habits and progress',
                icon: Icons.download_outlined,
                isDarkMode: isDarkMode,
                textColor: textColor,
                subtitleColor: subtitleColor,
                onTap: () {
                  // Handle export action
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}