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
import 'package:momentum/core/services/auth_service.dart';
import 'package:momentum/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:momentum/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.initialize();

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
        // Add other providers here as needed
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Momentum App',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: StreamBuilder<AuthState>(
              stream: authProvider.authService.authStateChanges,
              builder: (context, snapshot) {
                // Show splash screen initially
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen();
                }

                // If user is signed in, show home screen
                if (authProvider.authService.isSignedIn) {
                  return const HomeScreen();
                }

                // If user is not signed in, show welcome screen
                return const WelcomeScreen();
              },
            ),
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
          );
        },
      ),
    );
  }
}