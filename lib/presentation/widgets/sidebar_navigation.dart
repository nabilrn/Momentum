// lib/presentation/widgets/sidebar_navigation.dart
import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import '../services/navigation_service.dart';

class SidebarNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const SidebarNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = AppTheme.isDarkMode(context);
    final primaryColor = const Color(0xFF4B6EFF);

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(1, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // App Logo or Title
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.bolt_rounded, size: 24, color: primaryColor),
                const SizedBox(width: 10),
                Text(
                  'Momentum',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

          // Main navigation items
          _buildNavItem(context, Icons.home_rounded, 0, 'Home'),
          _buildNavItem(context, Icons.accessibility_new_rounded, 1, 'Random'),
          _buildNavItem(context, Icons.insights_rounded, 2, 'Overview'),

          const Spacer(),

          // Settings and account items
          const Divider(),
          _buildNavItem(context, Icons.settings_outlined, 3, 'Settings'),
          _buildNavItem(context, Icons.account_circle_outlined, 4, 'Account'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, int index, String label) {
    final bool isDarkMode = AppTheme.isDarkMode(context);
    final bool isSelected = index == currentIndex;
    final primaryColor = const Color(0xFF4B6EFF);

    return InkWell(
      onTap: () {
        onTap(index);
        switch (index) {
          case 0: NavigationService.navigateTo(context, '/home'); break;
          case 1: NavigationService.navigateTo(context, '/random_habit'); break;
          case 2: NavigationService.navigateTo(context, '/overview'); break;
          case 3: NavigationService.navigateTo(context, '/settings'); break;
          case 4: NavigationService.navigateTo(context, '/account'); break;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: isSelected
            ? BoxDecoration(
          color: primaryColor.withOpacity(isDarkMode ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(12),
        )
            : null,
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? primaryColor
                  : (isDarkMode ? Colors.white70 : Colors.black54),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? primaryColor
                    : (isDarkMode ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}