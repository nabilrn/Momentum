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

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CurvedNavigationBar(
        index: currentIndex,
        height: 60.0,
        items: const <Widget>[
          Icon(Icons.home, size: 30, color: Colors.white),
          Icon(Icons.accessibility_new, size: 30, color: Colors.white),
          Icon(Icons.settings, size: 30, color: Colors.white),
        ],
        color: isDarkMode ? AppTheme.darkBottomNav : AppTheme.lightBottomNav,
        buttonBackgroundColor: isDarkMode ? AppTheme.darkBottomNav : AppTheme.lightBottomNav,
        backgroundColor: Colors.transparent,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          onTap(index);

          // Handle navigation through NavigationService
          switch (index) {
            case 0:
              NavigationService.navigateTo(context, '/home');
              break;
            case 1:
              NavigationService.navigateTo(context, '/random_habit');
              break;
            case 2:
              NavigationService.navigateTo(context, '/settings');
              break;
          }
        },
      ),
    );
  }
}