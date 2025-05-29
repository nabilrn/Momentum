import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'package:momentum/presentation/pages/splash_screen.dart';
import 'package:momentum/presentation/pages/home_screen.dart';
import 'package:momentum/presentation/pages/random_habit_screen.dart';
import 'package:momentum/presentation/pages/overview_screen.dart';
import 'package:momentum/presentation/pages/add_habit_screen.dart';
import 'package:momentum/presentation/pages/welcome_screen.dart';
import 'package:page_transition/page_transition.dart';
import 'package:momentum/presentation/pages/timer_screen.dart';
import 'package:momentum/presentation/pages/settings_screen.dart';
import 'package:momentum/presentation/pages/account_screen.dart';
import 'package:momentum/core/services/supabase_service.dart';
import 'package:provider/provider.dart';
import 'package:momentum/presentation/providers/auth_provider.dart';
import 'package:momentum/presentation/controllers/habit_controller.dart';
import 'package:momentum/core/services/database_helper.dart';
import 'package:momentum/core/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseService.initialize();

  final dbHelper = DatabaseHelper();
  await dbHelper.database;

  // Replace this line:
  // await NotificationService.initialize();
  await FCMService.initialize();

  runApp(const MomentumApp());
}
class MomentumApp extends StatefulWidget {
  const MomentumApp({super.key});

  @override
  State<MomentumApp> createState() => _MomentumAppState();
}

class _MomentumAppState extends State<MomentumApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HabitController()),
        // Add other providers here as needed
      ],
      child: MaterialApp(
        title: 'Momentum App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(), // Always start with splash screen
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/welcome':
              return PageTransition(
                type: PageTransitionType.fade,
                child: const WelcomeScreen(),
                duration: const Duration(milliseconds: 300),
              );
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
            case '/account':
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
      ),
    );
  }
}