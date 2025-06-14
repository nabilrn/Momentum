import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import '../services/navigation_service.dart';
import '../widgets/settings/sections/appearance_section.dart';
import '../widgets/settings/sections/notifications_section.dart';
import '../widgets/settings/sections/account_section.dart';
import '../widgets/settings/sections/about_section.dart';
import 'package:momentum/core/services/fcm_service.dart'; // Changed to FCMService
import 'package:momentum/core/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:momentum/presentation/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:momentum/presentation/providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  // Change default to false as requested
  bool _notificationsEnabled = false;
  late String _themeMode;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AuthService _authService;
  late ThemeProvider _themeProvider;

  @override
  void initState() {
    super.initState();

    // Initialize auth service properly
    _authService =
        Provider.of<AuthProvider>(context, listen: false).authService;

    // Initialize theme provider
    _themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _themeMode = _themeProvider.getThemeModeString();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    // Load notification preferences
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {
    final enabled = await FCMService.areNotificationsEnabled();
    setState(() {
      _notificationsEnabled = enabled;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleThemeChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _themeMode = newValue;
      });
      // Update the app's theme using ThemeProvider
      _themeProvider.setThemeMode(newValue);

      // Show a confirmation message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Theme changed to ${_getThemeDisplayName(newValue)}'),
          ),
        );
      }
    }
  }

  String _getThemeDisplayName(String themeMode) {
    switch (themeMode) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'system':
      default:
        return 'System default';
    }
  }

  void _handleNotificationChanged(bool value) async {
    if (value) {
      // When enabling notifications
      final hasPermission = await FCMService.requestPermissions(context);
      if (hasPermission) {
        // Update UI state
        setState(() {
          _notificationsEnabled = value;
        });

        // Save the preference
        await FCMService.setNotificationsEnabled(value);

        // Schedule notifications for current user
        final userId = _authService.currentUser?.id;
        if (userId != null) {
          await FCMService.scheduleHabitReminders(userId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Habit reminders turned on')),
            );
          }
        }
      } else {
        // Don't update state if permission denied
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Permission denied. Please enable notifications in settings',
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } else {
      // When disabling notifications
      setState(() {
        _notificationsEnabled = value;
      });
      await FCMService.setNotificationsEnabled(false);
      await FCMService.clearAllNotifications(); // Changed to match FCMService method name
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Habit reminders turned off')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rest of the build method remains unchanged
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
        decoration:
            isDarkMode
                ? const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF121117), Color(0xFF1A1A24)],
                  ),
                )
                : null,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Appearance Section
              AppearanceSection(
                isDarkMode: isDarkMode,
                textColor: textColor,
                primaryColor: primaryColor,
                cardColor: cardColor,
                themeMode: _themeMode,
                onThemeChanged: _handleThemeChanged,
              ),
              const SizedBox(height: 28),

              // Notifications Section
              NotificationsSection(
                isDarkMode: isDarkMode,
                textColor: textColor,
                subtitleColor: subtitleColor,
                primaryColor: primaryColor,
                cardColor: cardColor,
                notificationsEnabled: _notificationsEnabled,
                onNotificationChanged: _handleNotificationChanged,
              ),
              const SizedBox(height: 28),

              // Account Section
              AccountSection(
                isDarkMode: isDarkMode,
                textColor: textColor,
                subtitleColor: subtitleColor,
                cardColor: cardColor,
              ),
              const SizedBox(height: 28),

              // About Section
              AboutSection(
                isDarkMode: isDarkMode,
                textColor: textColor,
                subtitleColor: subtitleColor,
                cardColor: cardColor,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
