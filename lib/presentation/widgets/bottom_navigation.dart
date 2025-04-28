import 'package:flutter/material.dart';
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
     child: SafeArea(
       top: false,
       child: Row(
         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
         children: [
           _buildNavItem(context, Icons.home_rounded, 0, 'Home'),
           _buildNavItem(context, Icons.accessibility_new_rounded, 1, 'Habits'),
           _buildNavItem(context, Icons.insights_rounded, 2, 'Overview'),
         ],
       ),
     ),
   );
 }


 Widget _buildNavItem(BuildContext context, IconData icon, int index, String label) {
   final bool isDarkMode = AppTheme.isDarkMode(context);
   final bool isSelected = index == currentIndex;


   return InkWell(
     onTap: () {
       onTap(index);
       switch (index) {
         case 0: NavigationService.navigateTo(context, '/home'); break;
         case 1: NavigationService.navigateTo(context, '/random_habit'); break;
         case 2: NavigationService.navigateTo(context, '/overview'); break;
       }
     },
     child: Container(
       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
       child: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
           Icon(
             icon,
             size: isSelected ? 24 : 22,
             color: isSelected
                 ? (isDarkMode ? Colors.white : Colors.white)
                 : (isDarkMode ? Colors.white70 : Colors.white.withOpacity(0.7)),
           ),
           const SizedBox(height: 4),
           Container(
             width: 32,
             height: 4,
             decoration: isSelected
                 ? BoxDecoration(
               color: isDarkMode ? Colors.white : Colors.white,
               borderRadius: BorderRadius.circular(2),
             )
                 : null,
           ),
         ],
       ),
     ),
   );
 }
}