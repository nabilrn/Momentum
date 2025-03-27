import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import '../services/navigation_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  bool _notificationsEnabled = true;
  String _themeMode = 'system'; // 'dark', 'light', 'system'
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.isDarkMode(context);
    final primaryColor = const Color(0xFF4B6EFF);
    final backgroundColor = isDarkMode ? const Color(0xFF121117) : Colors.white;
    final cardColor = isDarkMode ? const Color(0xFF1A1A24) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => NavigationService.goBack(context),
        ),
      ),
      body: Container(
        decoration: isDarkMode
            ? const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF121117),
              Color(0xFF1A1A24),
            ],
          ),
        )
            : null,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Appearance Section
              _buildSectionHeader('Appearance', Icons.palette_outlined, textColor),
              const SizedBox(height: 12),
              _buildSettingsCard(
                context,
                cardColor,
                Column(
                  children: [
                    _buildThemeOption('System Default', 'system', isDarkMode, textColor, primaryColor),
                    const Divider(height: 1),
                    _buildThemeOption('Light Mode', 'light', isDarkMode, textColor, primaryColor),
                    const Divider(height: 1),
                    _buildThemeOption('Dark Mode', 'dark', isDarkMode, textColor, primaryColor),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Notifications Section
              _buildSectionHeader('Notifications', Icons.notifications_outlined, textColor),
              const SizedBox(height: 12),
              _buildSettingsCard(
                context,
                cardColor,
                SwitchListTile(
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
                  value: _notificationsEnabled,
                  activeColor: primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              const SizedBox(height: 28),

              // Account Section
              _buildSectionHeader('Account', Icons.person_outline, textColor),
              const SizedBox(height: 12),
              _buildSettingsCard(
                context,
                cardColor,
                Column(
                  children: [
                    _buildSettingsItem(
                      'Data Backup',
                      'Back up your habits progress to cloud',
                      Icons.backup_outlined,
                      isDarkMode,
                      textColor,
                      subtitleColor,
                      onTap: () {
                        // Handle backup action
                      },
                    ),
                    const Divider(height: 1),
                    _buildSettingsItem(
                      'Export Data',
                      'Export your habits and progress',
                      Icons.download_outlined,
                      isDarkMode,
                      textColor,
                      subtitleColor,
                      onTap: () {
                        // Handle export action
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // About Section
              _buildSectionHeader('About', Icons.info_outline, textColor),
              const SizedBox(height: 12),
              _buildSettingsCard(
                context,
                cardColor,
                Column(
                  children: [
                    _buildSettingsItem(
                      'Version',
                      '1.0.0',
                      Icons.new_releases_outlined,
                      isDarkMode,
                      textColor,
                      subtitleColor,
                    ),
                    const Divider(height: 1),
                    _buildSettingsItem(
                      'Terms of Service',
                      'Read our terms and conditions',
                      Icons.description_outlined,
                      isDarkMode,
                      textColor,
                      subtitleColor,
                      onTap: () {
                        // Handle terms action
                      },
                    ),
                    const Divider(height: 1),
                    _buildSettingsItem(
                      'Privacy Policy',
                      'Read our privacy policy',
                      Icons.privacy_tip_outlined,
                      isDarkMode,
                      textColor,
                      subtitleColor,
                      onTap: () {
                        // Handle privacy action
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF4B6EFF),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, Color cardColor, Widget child) {
    final isDarkMode = AppTheme.isDarkMode(context);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: child,
      ),
    );
  }

  Widget _buildThemeOption(String title, String value, bool isDarkMode, Color textColor, Color primaryColor) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: _themeMode == value ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      value: value,
      groupValue: _themeMode,
      activeColor: primaryColor,
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _themeMode = newValue;
          });
          // Here you would update the app's theme
        }
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildSettingsItem(
      String title,
      String subtitle,
      IconData icon,
      bool isDarkMode,
      Color textColor,
      Color subtitleColor, {
        VoidCallback? onTap,
      }) {
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