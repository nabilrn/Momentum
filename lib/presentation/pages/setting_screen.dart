import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import 'package:momentum/core/theme/app_theme.dart';
import '../services/navigation_service.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  int _currentIndex = 2; // Set to 2 since this is the Settings tab
  bool _notificationsEnabled = true; // Track notification switch state
  bool _isDarkMode = false; // Track theme mode

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Handle navigation based on tab index
    if (index == 0) {
      NavigationService.navigateTo(context, '/home');
    } else if (index == 1) {
      NavigationService.navigateTo(context, '/random_habit');
    } else if (index == 2) {
      // Already on settings screen, no need to navigate
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize dark mode status when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isDarkMode = AppTheme.isDarkMode(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.isDarkMode(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: isDarkMode ? const Color(0xFF121117) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 18,
          ),
        ),
      ),
      body: Container(
        decoration: isDarkMode
            ? const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF121117), // Dark gradient start
              Color(0xFF1A1A24), // Dark gradient end
            ],
          ),
        )
            : const BoxDecoration(
          color: Colors.white, // Light mode background
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme section
              Text(
                'Theme',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Light/Dark mode option
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Light Mode',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  // Toggle theme
                  setState(() {
                    _isDarkMode = false;
                  });
                  // Here you would implement the actual theme change
                  // This would typically be done via a ThemeProvider or similar
                },
                trailing: Radio<bool>(
                  value: false,
                  groupValue: _isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _isDarkMode = value!;
                    });
                    // Implement theme change logic
                  },
                  activeColor: Colors.blue,
                ),
              ),

              Divider(color: isDarkMode ? Colors.white24 : Colors.grey.shade300),

              // Notification section
              const SizedBox(height: 16),
              Text(
                'Notification Reminder',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Notification toggle
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Enable Notifications',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                    fontSize: 16,
                  ),
                ),
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    // Implement notification settings logic
                  },
                  activeColor: Colors.blue,
                ),
              ),

              Divider(color: isDarkMode ? Colors.white24 : Colors.grey.shade300),

              // Other potential settings
              const SizedBox(height: 16),
              Text(
                'App Information',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Version',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                    fontSize: 16,
                  ),
                ),
                trailing: Text(
                  '1.0.0',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white38 : Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                    fontSize: 16,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDarkMode ? Colors.white38 : Colors.grey,
                ),
                onTap: () {
                  // Navigate to privacy policy
                },
              ),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Terms of Service',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                    fontSize: 16,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: isDarkMode ? Colors.white38 : Colors.grey,
                ),
                onTap: () {
                  // Navigate to terms of service
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}