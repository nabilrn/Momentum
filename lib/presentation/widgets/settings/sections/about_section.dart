import 'package:flutter/material.dart';
import '../section_header.dart';
import '../settings_card.dart';
import '../settings_item.dart';

class AboutSection extends StatelessWidget {
  final bool isDarkMode;
  final Color textColor;
  final Color subtitleColor;
  final Color cardColor;

  const AboutSection({
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
          title: 'About',
          icon: Icons.info_outline,
          textColor: textColor,
        ),
        const SizedBox(height: 12),
        SettingsCard(
          cardColor: cardColor,
          child: Column(
            children: [
              SettingsItem(
                title: 'Version',
                subtitle: '1.0.0',
                icon: Icons.new_releases_outlined,
                isDarkMode: isDarkMode,
                textColor: textColor,
                subtitleColor: subtitleColor,
              ),
              const Divider(height: 1),
              SettingsItem(
                title: 'Terms of Service',
                subtitle: 'Read our terms and conditions',
                icon: Icons.description_outlined,
                isDarkMode: isDarkMode,
                textColor: textColor,
                subtitleColor: subtitleColor,
                onTap: () {
                  // Handle terms action
                },
              ),
              const Divider(height: 1),
              SettingsItem(
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                icon: Icons.privacy_tip_outlined,
                isDarkMode: isDarkMode,
                textColor: textColor,
                subtitleColor: subtitleColor,
                onTap: () {
                  // Handle privacy action
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}