import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import '../services/navigation_service.dart';
import '../widgets/settings/sections/appearance_section.dart';
import '../widgets/settings/sections/notifications_section.dart';
import '../widgets/settings/sections/account_section.dart';
import '../widgets/settings/sections/about_section.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/sidebar_navigation.dart';
import 'package:momentum/core/services/fcm_service.dart';
import 'package:momentum/core/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:momentum/presentation/providers/auth_provider.dart';
import 'package:momentum/presentation/providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  bool _notificationsEnabled = false;
  late String _themeMode;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late AuthService _authService;
  late ThemeProvider _themeProvider;

  // Current bottom nav index
  int _currentIndex = 3;

  // Responsive breakpoints
  static const double _breakpoint = 768;
  static const double _largeScreenBreakpoint = 1200;

  @override
  void initState() {
    super.initState();

    _authService = Provider.of<AuthProvider>(context, listen: false).authService;
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
      _themeProvider.setThemeMode(newValue);

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
      case 'light': return 'Light';
      case 'dark': return 'Dark';
      case 'system': default: return 'System default';
    }
  }

  void _handleNotificationChanged(bool value) async {
    if (value) {
      final hasPermission = await FCMService.requestPermissions(context);
      if (hasPermission) {
        setState(() {
          _notificationsEnabled = value;
        });

        await FCMService.setNotificationsEnabled(value);

        final userId = _authService.currentUser?.id;
        if (userId != null) {
          await FCMService.scheduleHabitReminders(userId);
          if (mounted) {
            // Notification success message
          }
        }
      } else {
        if (mounted) {
          // Permission denied message
        }
      }
    } else {
      setState(() {
        _notificationsEnabled = value;
      });
      await FCMService.setNotificationsEnabled(false);
      await FCMService.clearAllNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Habit reminders turned off')),
        );
      }
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    final routes = {
      0: '/home',
      1: '/random_habit',
      2: '/overview',
      3: '/settings',
      4: '/account',
    };

    if (routes.containsKey(index) && index != 3) { // Don't navigate if already on this page
      NavigationService.navigateTo(context, routes[index]!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive layout decision
    final usesSidebar = screenWidth > _breakpoint;
    final isLargeScreen = screenWidth > _largeScreenBreakpoint;

    return Scaffold(
      extendBody: !usesSidebar,
      backgroundColor: isDarkMode ? const Color(0xFF121117) : Color.fromARGB(255, 244, 245, 247),
      appBar: usesSidebar ? null : AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => NavigationService.goBack(context),
        ),
      ),
      body: usesSidebar
          ? _buildWithSidebar(isDarkMode, isLargeScreen)
          : _buildWithBottomNav(isDarkMode),
      bottomNavigationBar: usesSidebar
          ? null
          : BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildWithSidebar(bool isDarkMode, bool isLargeScreen) {
    return Row(
      children: [
        // Sidebar navigation
        SidebarNavigation(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),

        // Main content
        Expanded(
          child: Container(
            decoration: isDarkMode
                ? const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF121117), Color(0xFF1A1A24)],
              ),
            )
                : BoxDecoration(
              color: isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom app bar for sidebar layout
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                // Main content area with different layouts based on screen size
                Expanded(
                  child: isLargeScreen
                      ? _buildLargeScreenLayout(isDarkMode)
                      : _buildMediumScreenLayout(isDarkMode),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // FIX: Replaced rigid Columns with scrollable ListView to prevent RenderFlex overflow.
  Widget _buildLargeScreenLayout(bool isDarkMode) {
    final primaryColor = const Color(0xFF4B6EFF);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.white70 : Colors.black54;
    final cardColor = isDarkMode ? const Color(0xFF1E1E2C) : Colors.white;

    // Two-column layout for large screens
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column - Appearance and Notifications
            Expanded(
              child: ListView( // FIX: Changed Column to ListView
                padding: EdgeInsets.zero, // Remove default padding if not needed
                children: [
                  // Appearance Section Card
                  Card(
                    color: cardColor,
                    elevation: isDarkMode ? 0 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: isDarkMode
                          ? BorderSide(color: Colors.white.withOpacity(0.05))
                          : BorderSide.none,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: AppearanceSection(
                        isDarkMode: isDarkMode,
                        textColor: textColor,
                        primaryColor: primaryColor,
                        cardColor: cardColor,
                        themeMode: _themeMode,
                        onThemeChanged: _handleThemeChanged,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Notifications Section Card
                  Card(
                    color: cardColor,
                    elevation: isDarkMode ? 0 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: isDarkMode
                          ? BorderSide(color: Colors.white.withOpacity(0.05))
                          : BorderSide.none,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: NotificationsSection(
                        isDarkMode: isDarkMode,
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                        primaryColor: primaryColor,
                        cardColor: cardColor,
                        notificationsEnabled: _notificationsEnabled,
                        onNotificationChanged: _handleNotificationChanged,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // Right column - Account and About
            Expanded(
              child: ListView( // FIX: Changed Column to ListView
                padding: EdgeInsets.zero,
                children: [
                  // Account Section Card
                  Card(
                    color: cardColor,
                    elevation: isDarkMode ? 0 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: isDarkMode
                          ? BorderSide(color: Colors.white.withOpacity(0.05))
                          : BorderSide.none,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: AccountSection(
                        isDarkMode: isDarkMode,
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                        cardColor: cardColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // About Section Card
                  Card(
                    color: cardColor,
                    elevation: isDarkMode ? 0 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: isDarkMode
                          ? BorderSide(color: Colors.white.withOpacity(0.05))
                          : BorderSide.none,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: AboutSection(
                        isDarkMode: isDarkMode,
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                        cardColor: cardColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediumScreenLayout(bool isDarkMode) {
    final primaryColor = const Color(0xFF4B6EFF);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.white70 : Colors.black54;
    final cardColor = isDarkMode ? const Color(0xFF1E1E2C) : Colors.white;

    // Centered card layout for medium screens
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              children: [
                // Appearance Section Card
                Card(
                  color: cardColor,
                  elevation: isDarkMode ? 0 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isDarkMode
                        ? BorderSide(color: Colors.white.withOpacity(0.05))
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: AppearanceSection(
                      isDarkMode: isDarkMode,
                      textColor: textColor,
                      primaryColor: primaryColor,
                      cardColor: cardColor,
                      themeMode: _themeMode,
                      onThemeChanged: _handleThemeChanged,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Notifications Section Card
                Card(
                  color: cardColor,
                  elevation: isDarkMode ? 0 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isDarkMode
                        ? BorderSide(color: Colors.white.withOpacity(0.05))
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: NotificationsSection(
                      isDarkMode: isDarkMode,
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      primaryColor: primaryColor,
                      cardColor: cardColor,
                      notificationsEnabled: _notificationsEnabled,
                      onNotificationChanged: _handleNotificationChanged,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Account Section Card
                Card(
                  color: cardColor,
                  elevation: isDarkMode ? 0 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isDarkMode
                        ? BorderSide(color: Colors.white.withOpacity(0.05))
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: AccountSection(
                      isDarkMode: isDarkMode,
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      cardColor: cardColor,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // About Section Card
                Card(
                  color: cardColor,
                  elevation: isDarkMode ? 0 : 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isDarkMode
                        ? BorderSide(color: Colors.white.withOpacity(0.05))
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: AboutSection(
                      isDarkMode: isDarkMode,
                      textColor: textColor,
                      subtitleColor: subtitleColor,
                      cardColor: cardColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWithBottomNav(bool isDarkMode) {
    final primaryColor = const Color(0xFF4B6EFF);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.white70 : Colors.black54;
    final cardColor = isDarkMode ? const Color(0xFF1A1A24) : Colors.white;

    return Container(
      decoration: isDarkMode
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
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
            children: [
              AppearanceSection(
                isDarkMode: isDarkMode,
                textColor: textColor,
                primaryColor: primaryColor,
                cardColor: cardColor,
                themeMode: _themeMode,
                onThemeChanged: _handleThemeChanged,
              ),
              const SizedBox(height: 28),

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

              AccountSection(
                isDarkMode: isDarkMode,
                textColor: textColor,
                subtitleColor: subtitleColor,
                cardColor: cardColor,
              ),
              const SizedBox(height: 28),

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