import 'package:flutter/material.dart';
import '../section_header.dart';
import '../settings_card.dart';
import '../theme_option.dart';

class AppearanceSection extends StatelessWidget {
  final bool isDarkMode;
  final Color textColor;
  final Color primaryColor;
  final Color cardColor;
  final String themeMode;
  final Function(String?) onThemeChanged;

  const AppearanceSection({
    super.key,
    required this.isDarkMode,
    required this.textColor,
    required this.primaryColor,
    required this.cardColor,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Appearance',
          icon: Icons.palette_outlined,
          textColor: textColor,
        ),
        const SizedBox(height: 12),
        SettingsCard(
          cardColor: cardColor,
          child: Column(
            children: [
              ThemeOption(
                title: 'System Default',
                value: 'system',
                groupValue: themeMode,
                isDarkMode: isDarkMode,
                textColor: textColor,
                primaryColor: primaryColor,
                onChanged: onThemeChanged,
              ),
              const Divider(height: 1),
              ThemeOption(
                title: 'Light Mode',
                value: 'light',
                groupValue: themeMode,
                isDarkMode: isDarkMode,
                textColor: textColor,
                primaryColor: primaryColor,
                onChanged: onThemeChanged,
              ),
              const Divider(height: 1),
              ThemeOption(
                title: 'Dark Mode',
                value: 'dark',
                groupValue: themeMode,
                isDarkMode: isDarkMode,
                textColor: textColor,
                primaryColor: primaryColor,
                onChanged: onThemeChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}