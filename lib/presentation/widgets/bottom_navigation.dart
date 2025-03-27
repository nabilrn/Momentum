import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:momentum/core/theme/app_theme.dart';
import '../services/navigation_service.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = AppTheme.isDarkMode(context);
    final primaryColor = const Color(0xFF4B6EFF);
    final lightBlue = const Color(0xFF6B89FF);

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E2C) : primaryColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: CurvedNavigationBar(
        index: currentIndex,
        height: 55.0, // Reduced height
        items: [
          _buildNavItem(Icons.home_rounded, 0, currentIndex, isDarkMode),
          _buildNavItem(Icons.accessibility_new_rounded, 1, currentIndex, isDarkMode),
          _buildNavItem(Icons.insights_rounded, 2, currentIndex, isDarkMode),
        ],
        color: isDarkMode ? const Color(0xFF252836) : lightBlue,
        buttonBackgroundColor: isDarkMode ? primaryColor : Colors.white,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeOutQuart,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          onTap(index);
          switch (index) {
            case 0: NavigationService.navigateTo(context, '/home'); break;
            case 1: NavigationService.navigateTo(context, '/random_habit'); break;
            case 2: NavigationService.navigateTo(context, '/overview'); break;
          }
        },
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, int currentIndex, bool isDarkMode) {
    final bool isSelected = index == currentIndex;
    final darkBlue = const Color(0xFF2A41CC);

    return Container(
      padding: const EdgeInsets.all(6), // Reduced padding
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isSelected && !isDarkMode
            ? Border.all(color: darkBlue, width: 1.5) // Thinner border
            : null,
      ),
      child: Icon(
        icon,
        size: isSelected ? 24 : 22, // Reduced icon sizes
        color: isSelected
            ? (isDarkMode ? Colors.white : darkBlue)
            : (isDarkMode ? Colors.white70 : Colors.white),
      ),
    );
  }
}