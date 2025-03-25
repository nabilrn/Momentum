import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:momentum/presentation/pages/home_screen.dart';
import 'package:momentum/presentation/pages/random_habit_screen.dart';
import 'package:momentum/presentation/pages/setting_screen.dart';

class NavigationService {
  static void navigateTo(BuildContext context, String routeName) {
    Widget page;

    switch (routeName) {
      case '/home':
        page = const HomeScreen();
        break;
      case '/random_habit':
        page = const RandomHabitScreen();
        break;
      case '/settings':
        page = const SettingScreen();
        break;
      default:
        page = const HomeScreen();
    }

    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 300),
        child: page,
      ),
    );
  }
}