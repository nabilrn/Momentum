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
import 'package:momentum/core/services/fcm_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:momentum/core/services/local_storage_service.dart';
import 'dart:developer' as developer;
import 'dart:io' show Platform;

// Check if running on iOS simulator
bool get isIOSSimulator {
  if (!kIsWeb && Platform.isIOS) {
    return !const bool.fromEnvironment('dart.vm.product') &&
        Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
  }
  return false;
}

// Check if we should skip Firebase messaging
bool get shouldSkipFirebaseMessaging {
  // Skip on iOS simulator and macOS
  if (isIOSSimulator || (!kIsWeb && Platform.isMacOS)) {
    return true;
  }
  return false;
}

Future<void> initializeFirebase() async {
  try {
    // Skip Firebase initialization on iOS simulator and macOS
    if (shouldSkipFirebaseMessaging) {
      developer.log(
        '⚠️ Skipping Firebase initialization on iOS simulator or macOS',
      );
      return;
    }

    // Check if Firebase is already initialized
    if (Firebase.apps.isNotEmpty) {
      developer.log('ℹ️ Firebase already initialized, skipping initialization');
      return;
    }

    // Try to initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    developer.log('✅ Firebase initialized successfully');
  } catch (e) {
    // If we get a duplicate-app error, it means Firebase is already initialized
    if (e.toString().contains('duplicate-app')) {
      developer.log(
        'ℹ️ Firebase already initialized (caught duplicate-app error)',
      );
      return;
    }
    developer.log('❌ Error initializing Firebase: $e');
    rethrow;
  }
}

Future<void> initializeServices() async {
  try {
    // Initialize Supabase first
    await SupabaseService.initialize();
    developer.log('✅ Supabase initialized');

    // Initialize Hive
    await LocalStorageService.initialize();
    developer.log('✅ Hive initialized');

    // Initialize Firebase
    await initializeFirebase();

    // Initialize FCM last since it depends on Firebase
    // Skip FCM on iOS simulator and macOS
    if (!shouldSkipFirebaseMessaging) {
      await FCMService.initialize();
      developer.log('✅ FCM Service initialized');
    } else {
      developer.log('⚠️ Skipping FCM initialization on iOS simulator or macOS');
    }
  } catch (e) {
    developer.log('❌ Error initializing services: $e');
    // Don't rethrow here, let the app continue even if some services fail
  }
}

void main() async {
  try {
    // Ensure Flutter bindings are initialized
    WidgetsFlutterBinding.ensureInitialized();
    developer.log('✅ Flutter bindings initialized');

    // Initialize all services
    await initializeServices();

    runApp(const MomentumApp());
  } catch (e) {
    developer.log('❌ Fatal error during initialization: $e');
    // Continue running the app even if there's an error
    runApp(const MomentumApp());
  }
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
      ],
      child: MaterialApp(
        title: 'Momentum App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
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
