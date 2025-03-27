import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'package:momentum/presentation/pages/splash_screen.dart';
import 'package:momentum/presentation/pages/home_screen.dart';
import 'package:momentum/presentation/pages/random_habit_screen.dart';
import 'package:momentum/presentation/pages/overview_screen.dart';
import 'package:momentum/presentation/pages/add_habit_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:momentum/presentation/pages/timer_screen.dart';
import 'package:momentum/presentation/pages/settings_screen.dart';
import 'package:momentum/presentation/pages/account_screen.dart';

void main() {
  runApp(const MomentumApp());
}

class MomentumApp extends StatelessWidget {
  const MomentumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momentum App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return PageTransition(
              type: PageTransitionType.fade,
              child: const HomeScreen(),
              duration: const Duration(milliseconds: 300),
            );
          case '/random_habit':
            return PageTransition(
              type: PageTransitionType.fade,
              child: const RandomHabitScreen(),
              duration: const Duration(milliseconds: 300),
            );
          case '/overview':
            return PageTransition(
              type: PageTransitionType.fade,
              child: const OverviewScreen(),
              duration: const Duration(milliseconds: 300),
            );
          case '/add_habit':
            return PageTransition(
              type: PageTransitionType.fade,
              child: const AddHabitScreen(),
              duration: const Duration(milliseconds: 300),
            );
          case '/timer':
            return PageTransition(
              type: PageTransitionType.fade,
              child: const TimerScreen(),
              duration: const Duration(milliseconds: 300),
            );
          case '/settings':
            return PageTransition(
              type: PageTransitionType.fade,
              child: const SettingsScreen(),
              duration: const Duration(milliseconds: 300),
            );
          case 'account':
            return PageTransition(
              type: PageTransitionType.fade,
              child: const AccountScreen(),
              duration: const Duration(milliseconds: 300),
            );

            default:
            return PageTransition(
              type: PageTransitionType.fade,
              child: const HomeScreen(),
              duration: const Duration(milliseconds: 300),
            );


        }
      },
    );
  }
}