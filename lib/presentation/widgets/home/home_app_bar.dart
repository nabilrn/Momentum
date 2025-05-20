import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'package:momentum/presentation/services/navigation_service.dart';
import 'package:momentum/presentation/widgets/momentum_logo.dart';
class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.isDarkMode(context);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: MomentumLogo(size: 28),
      ),
      actions: [
        // Filter Icon

        // Menu Icon
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: isDarkMode ? Colors.white : Colors.black,
              size: 22,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
            elevation: 8,
            onSelected: (value) {
              if (value == 'settings') {
                NavigationService.navigateTo(context, '/settings');
              } else if (value == 'account') {
                NavigationService.navigateTo(context, '/account');
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(
                      Icons.settings,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Settings',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'account',
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Account',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}