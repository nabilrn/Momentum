import 'dart:convert';
import 'dart:io' show Platform;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'package:momentum/data/models/habit_model.dart';

class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static FlutterLocalNotificationsPlugin? _localNotifications;
  static late final SupabaseClient _supabaseClient;
  static bool _initialized = false;
  static bool _isIOSSimulator = false;

  static Future<void> initialize() async {
    if (_initialized) {
      developer.log('FCM Service already initialized');
      return;
    }

    try {
      // Initialize Supabase client
      _supabaseClient = Supabase.instance.client;
      developer.log('✅ Supabase client initialized in FCM Service');

      // Check platform capabilities
      if (kIsWeb) {
        developer.log('Running on Web platform');
        await _initializeWeb();
      } else if (Platform.isIOS) {
        _isIOSSimulator =
            !kReleaseMode &&
            Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
        developer.log(
          'Running on iOS ${_isIOSSimulator ? "simulator" : "device"}',
        );
        if (_isIOSSimulator) {
          developer.log(
            '⚠️ Push notifications are not supported on iOS simulators - skipping FCM initialization',
          );
          _initialized = true;
          return; // Skip the rest of initialization for iOS simulator
        }
        await _initializeMobile();
      } else if (Platform.isAndroid) {
        developer.log('Running on Android');
        await _initializeMobile();
      } else {
        developer.log('Running on unsupported platform for push notifications');
        _initialized = true;
        return;
      }

      // Listen for token refreshes
      _messaging.onTokenRefresh.listen((token) {
        // Only save if user is authenticated
        if (_supabaseClient.auth.currentUser != null) {
          _saveTokenToSupabase(token);
        }
      });

      // Listen for auth state changes to handle token registration
      _supabaseClient.auth.onAuthStateChange.listen((event) {
        if (event.event == AuthChangeEvent.signedIn) {
          registerTokenAfterLogin();
        }
      });

      _initialized = true;
      developer.log('✅ FCM Service initialized successfully');

      // Try to get token immediately if supported
      if (_shouldAttemptTokenRegistration()) {
        try {
          final token = await _messaging.getToken();
          if (token != null && _supabaseClient.auth.currentUser != null) {
            await _saveTokenToSupabase(token);
            developer.log('Initial FCM token registered: $token');
          }
        } catch (e) {
          developer.log('Error getting initial FCM token: $e');
        }
      }
    } catch (e) {
      developer.log('❌ Error initializing FCM Service: $e');
      rethrow;
    }
  }

  static Future<void> _initializeWeb() async {
    developer.log('🔔 FCM Web: Starting FCM initialization for web platform');
    // Request permission for web
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    developer.log(
      '🔔 FCM Web permission status: ${settings.authorizationStatus}',
    );

    // Handle foreground messages for web
    FirebaseMessaging.onMessage.listen(_handleForegroundMessageWeb);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    developer.log('✅ FCM Web: Initialization completed');
  }

  static Future<void> _initializeMobile() async {
    // Request permission on mobile
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    developer.log(
      'Mobile FCM permission status: ${settings.authorizationStatus}',
    );

    // Initialize local notifications for mobile
    _localNotifications = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications!.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Configure foreground notification presentation
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Handle background/terminated messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessageMobile);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  static bool _shouldAttemptTokenRegistration() {
    if (kIsWeb) return true;
    if (Platform.isAndroid) return true;
    if (Platform.isIOS && !_isIOSSimulator) return true;
    return false;
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('fcm_notifications_enabled', enabled);

      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId != null) {
        // Update preference on server if user is logged in
        await _supabaseClient.from('user_preferences').upsert({
          'user_id': userId,
          'notifications_enabled': enabled,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id');
      }

      developer.log('FCM notifications preference set to: $enabled');
    } catch (e) {
      developer.log('Error setting notification preference: $e');
    }
  }

  static Future<bool> areNotificationsEnabled() async {
    try {
      // First check if the user has enabled notifications in preferences
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('fcm_notifications_enabled') ?? false;

      // If disabled in preferences, return false immediately
      if (!enabled) return false;

      // Otherwise check system permission status
      final settings = await _messaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      developer.log('Error checking notification status: $e');
      return false;
    }
  }

  static Future<bool> requestPermissions(BuildContext context) async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      bool granted =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      developer.log(
        'FCM permissions request result: ${settings.authorizationStatus}',
      );
      return granted;
    } catch (e) {
      developer.log('Error requesting FCM permissions: $e');
      return false;
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap (mobile only)
    developer.log('Notification tapped: ${response.payload}');
    // Navigate based on payload if needed
  }

  static Future<void> _saveTokenToSupabase(String token) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        developer.log('❌ FCM: Cannot save FCM token: User not authenticated');
        return;
      }

      developer.log('🔔 FCM: Saving token to Supabase for user: $userId');

      String platformString;
      if (kIsWeb) {
        platformString = 'web';
        developer.log('🔔 FCM Web: Saving web platform token');
      } else {
        platformString = defaultTargetPlatform.toString();
      }

      // Save token to device_tokens table
      await _supabaseClient.from('device_tokens').upsert({
        'user_id': userId,
        'token': token,
        'platform': platformString,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, token');

      developer.log('✅ FCM: Token saved to Supabase successfully');
      if (kIsWeb) {
        developer.log('✅ FCM Web: Token registration and storage complete');
      }
    } catch (e) {
      developer.log('❌ FCM: Error saving FCM token: $e');
    }
  }

  static Future<void> _handleForegroundMessageMobile(
    RemoteMessage message,
  ) async {
    developer.log('Mobile foreground message received: ${message.messageId}');

    if (_localNotifications == null) return;

    // Extract notification data
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      // Show local notification
      await _localNotifications!.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_reminders',
            'Habit Reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(data),
      );
    }
  }

  static Future<void> _handleForegroundMessageWeb(RemoteMessage message) async {
    developer.log(
      '🔔 FCM Web: Foreground message received: ${message.messageId}',
    );

    // For web, the browser will handle showing the notification
    // You can add custom handling here if needed
    final notification = message.notification;
    if (notification != null) {
      developer.log(
        '🔔 FCM Web notification: ${notification.title} - ${notification.body}',
      );
    }

    final data = message.data;
    if (data.isNotEmpty) {
      developer.log('🔔 FCM Web message data: ${jsonEncode(data)}');
    }
  }

  static void _handleNotificationTap(RemoteMessage message) {
    developer.log('Notification opened app: ${message.messageId}');
  }

  static Future<void> scheduleHabitReminders(String userId) async {
    try {
      final isEnabled = await areNotificationsEnabled();
      if (!isEnabled) {
        developer.log('Skipping reminder scheduling: notifications disabled');
        return;
      }

      final res = await _supabaseClient.functions.invoke(
        'habit-reminders',
        body: {'user_id': userId},
      );

      if (res.status != 200) {
        developer.log(
          'Error from habit-reminders function: ${res.status}, details: ${res.data}',
        );
      } else {
        developer.log(
          'Requested habit reminder scheduling for user: $userId, response: ${res.data}',
        );
      }
    } catch (e) {
      developer.log('Error requesting habit reminder scheduling: $e');
    }
  }

  static Future<void> clearAllNotifications() async {
    try {
      // Cancel all local notifications (mobile only)
      if (!kIsWeb && _localNotifications != null) {
        await _localNotifications!.cancelAll();
      }

      // Unsubscribe from server topics if user is logged in
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId != null) {
        // Optional: Inform server to stop sending notifications
        await _supabaseClient.functions.invoke(
          'clear-habit-reminders',
          body: {'user_id': userId},
        );
      }

      developer.log('All notifications cleared');
    } catch (e) {
      developer.log('Error clearing notifications: $e');
    }
  }

  // Register FCM token after login - Modified to handle all platforms
  static Future<void> registerTokenAfterLogin() async {
    // Skip FCM registration on iOS simulator immediately
    if (!kIsWeb && Platform.isIOS && _isIOSSimulator) {
      developer.log(
        '⚠️ FCM iOS: Skipping FCM token registration on iOS simulator - push notifications not supported',
      );
      return;
    }

    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        developer.log(
          '❌ FCM: Cannot register FCM token: User not authenticated',
        );
        return;
      }

      developer.log('🔔 FCM: Registering token after login for user: $userId');
      developer.log(
        '🔔 FCM: Platform: ${kIsWeb ? 'Web' : Platform.operatingSystem}',
      );

      // For web, Android, or physical iOS devices
      if (_shouldAttemptTokenRegistration()) {
        try {
          developer.log('🔔 FCM: Requesting FCM token...');
          final token = await _messaging.getToken();
          if (token != null) {
            developer.log(
              '🔔 FCM: Token obtained (${token.substring(0, _min(10, token.length))}...)',
            );
            await _saveTokenToSupabase(token);
            developer.log('✅ FCM: Token registration successful');
          } else {
            developer.log(
              '❌ FCM: Unable to get FCM token - null value returned',
            );
          }
        } catch (e) {
          developer.log('❌ FCM: Error getting FCM token: $e');
        }
      }
    } catch (e) {
      developer.log('❌ FCM: Error in registerTokenAfterLogin: $e');
    }
  }

  // Helper function to get the minimum of two values
  static int _min(int a, int b) {
    return a < b ? a : b;
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  developer.log('Background message received: ${message.messageId}');
}
