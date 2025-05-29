// lib/core/services/fcm_service.dart
import 'dart:convert';
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
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();
  static final SupabaseClient _supabaseClient = Supabase.instance.client;

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize Firebase if not already done
    await Firebase.initializeApp();

    // Request permission on iOS
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    developer.log('FCM permission status: ${settings.authorizationStatus}');

    // Initialize local notifications for foreground
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
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
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Get token and save to Supabase
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveTokenToSupabase(token);
    }

    // Listen for token refreshes
    _messaging.onTokenRefresh.listen(_saveTokenToSupabase);

    _initialized = true;
    developer.log('FCM Service initialized');
  }

  // NEW METHOD: Save user notification preference
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

  // UPDATED METHOD: Check both permission and user preference
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

  // NEW METHOD: Request permissions with BuildContext parameter
  static Future<bool> requestPermissions(BuildContext context) async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      bool granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      developer.log('FCM permissions request result: ${settings.authorizationStatus}');
      return granted;
    } catch (e) {
      developer.log('Error requesting FCM permissions: $e');
      return false;
    }
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    developer.log('Notification tapped: ${response.payload}');
    // Navigate based on payload if needed
  }

  static Future<void> _saveTokenToSupabase(String token) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        developer.log('Cannot save FCM token: User not authenticated');
        return;
      }

      // Save token to device_tokens table
      await _supabaseClient.from('device_tokens').upsert({
        'user_id': userId,
        'token': token,
        'platform': defaultTargetPlatform.toString(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, token');

      developer.log('FCM token saved to Supabase');
    } catch (e) {
      developer.log('Error saving FCM token: $e');
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    developer.log('Foreground message received: ${message.messageId}');

    // Extract notification data
    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      // Show local notification
      await _localNotifications.show(
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

      final res = await _supabaseClient.functions.invoke('habit-reminders', body: {'user_id': userId});

      // Check the status code instead of error property
      if (res.status != 200) {
        developer.log('Error from habit-reminders function: ${res.status}, details: ${res.data}');
      } else {
        developer.log('Requested habit reminder scheduling for user: $userId, response: ${res.data}');
      }
    } catch (e) {
      developer.log('Error requesting habit reminder scheduling: $e');
    }
  }

  static Future<void> clearAllNotifications() async {
    try {
      // Cancel all local notifications
      await _localNotifications.cancelAll();

      // Unsubscribe from server topics if user is logged in
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId != null) {
        // Optional: Inform server to stop sending notifications
        await _supabaseClient.functions.invoke('clear-habit-reminders',
            body: {'user_id': userId});
      }

      developer.log('All notifications cleared');
    } catch (e) {
      developer.log('Error clearing notifications: $e');
    }
  }
}

// This function must be top-level (not inside a class)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  developer.log('Background message received: ${message.messageId}');
}