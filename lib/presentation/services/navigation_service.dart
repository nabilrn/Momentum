import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:momentum/presentation/pages/home_screen.dart';
import 'package:momentum/presentation/pages/random_habit_screen.dart';
import 'package:momentum/presentation/pages/overview_screen.dart';
import 'package:momentum/presentation/pages/add_habit_screen.dart';
import 'package:momentum/presentation/pages/timer_screen.dart';
import 'package:momentum/presentation/pages/settings_screen.dart';
import 'package:momentum/presentation/pages/account_screen.dart';
import 'package:momentum/presentation/pages/welcome_screen.dart';

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
      case '/overview':
        page = const OverviewScreen();
        break;
      case '/add_habit':
        page = const AddHabitScreen();
        break;
      case '/timer':
        page = const TimerScreen();
      case '/settings':
        page = const SettingsScreen();
      case '/account':
        page = const AccountScreen();
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
  static void goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      navigateTo(context, '/home');
    }
  }
  static void goBackToWelcomeScreen(BuildContext context) {
    Navigator.pushReplacement(
      context,
      PageTransition(
        type: PageTransitionType.fade,
        duration: const Duration(milliseconds: 300),
        child: const WelcomeScreen(),
      ),
    );
  }
}