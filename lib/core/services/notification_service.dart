// lib/core/services/notification_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_init;
import 'dart:developer' as developer;
import 'package:momentum/core/services/local_storage_service.dart';
import 'package:momentum/data/models/habit_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final SupabaseClient _supabaseClient = Supabase.instance.client;

  static const String _reminderEnabledKey = 'habit_reminders_enabled';
  static const String _notificationChannelId = 'habit_reminders';
  static const String _notificationChannelName = 'Habit Reminders';
  static const String _notificationChannelDescription = 'Notifications for habit reminders';

  static bool _initialized = false;

  // Initialize notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    developer.log('🔔 Initializing NotificationService');

    // Initialize Firebase
    await Firebase.initializeApp();

    tz_init.initializeTimeZones();

    // Initialize notification settings for Android
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // Initialize notification settings for iOS
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: false, // We'll request later
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Initialize settings for all platforms
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android 8.0+
    await _createNotificationChannel();

    // Configure FCM foreground notification presentation
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

    _initialized = true;
    developer.log('✅ NotificationService initialized successfully');
  }

  // Create the notification channel for Android
  static Future<void> _createNotificationChannel() async {
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
    _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _notificationChannelId,
          _notificationChannelName,
          description: _notificationChannelDescription,
          importance: Importance.high,
        ),
      );
      developer.log('✅ Created notification channel: $_notificationChannelId');
    }
  }

  // Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    developer.log('🔔 Notification tapped: ${response.payload}');
    // You can add navigation or other actions here
  }

  static void _handleNotificationTap(RemoteMessage message) {
    developer.log('👆 Background notification tapped: ${message.messageId}');
    // Handle navigation based on notification data
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    developer.log('📲 Foreground message received: ${message.messageId}');

    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      await _notificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _notificationChannelId,
            _notificationChannelName,
            channelDescription: _notificationChannelDescription,
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

  // Request notification permissions
  static Future<bool> requestPermissions(BuildContext context) async {
    developer.log('🔔 Requesting notification permissions');

    // Request FCM permissions first
    NotificationSettings fcmSettings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    bool fcmPermissionGranted = fcmSettings.authorizationStatus == AuthorizationStatus.authorized ||
        fcmSettings.authorizationStatus == AuthorizationStatus.provisional;

    if (!fcmPermissionGranted) {
      developer.log('❌ FCM permissions denied');
      return false;
    }

    // Platform specific permissions
    if (Theme.of(context).platform == TargetPlatform.android) {
      // For Android 13+ (SDK 33+), request POST_NOTIFICATIONS permission
      if (await Permission.notification.status.isDenied) {
        final status = await Permission.notification.request();
        final granted = status.isGranted;
        developer.log('📱 Android notification permission granted: $granted');

        // Register device token if permissions granted
        if (granted) {
          await registerDeviceToken();
        }

        return granted;
      }

      await registerDeviceToken();
      return true;
    } else {
      final result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );

      developer.log('📱 iOS notification permission status: ${result.toString()}');

      // Register device token if permissions granted
      if (result == true) {
        await registerDeviceToken();
      }

      return result ?? false;
    }
  }

  // Register device token with Supabase
  static Future<void> registerDeviceToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToSupabase(token);
      }

      // Listen for token refreshes
      _messaging.onTokenRefresh.listen(_saveTokenToSupabase);
    } catch (e) {
      developer.log('❌ Error registering device token', error: e);
    }
  }

  static Future<void> _saveTokenToSupabase(String token) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        developer.log('⚠️ Cannot save FCM token: User not authenticated');
        return;
      }

      developer.log('💾 Saving FCM token to Supabase: ${token.substring(0, 10)}...');

      // Save token to device_tokens table
      await _supabaseClient.from('device_tokens').upsert({
        'user_id': userId,
        'token': token,
        'platform': _getPlatformName(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, token');

      developer.log('✅ FCM token saved to Supabase');
    } catch (e) {
      developer.log('❌ Error saving FCM token: $e');
    }
  }

  static String _getPlatformName() {
    if (Theme.of(currentContext!).platform == TargetPlatform.android) return 'android';
    if (Theme.of(currentContext!).platform == TargetPlatform.iOS) return 'ios';
    return 'unknown';
  }

  // Keep track of current BuildContext
  static BuildContext? currentContext;

  // Check if notifications are enabled in app settings
  static Future<bool> areNotificationsEnabled() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isEnabled = prefs.getBool(_reminderEnabledKey) ?? false;
    developer.log('🔔 Notifications enabled in settings: $isEnabled');
    return isEnabled;
  }

  // Set notifications enabled/disabled in app settings
  static Future<bool> setNotificationsEnabled(bool value) async {
    developer.log('🔔 Setting notifications enabled to: $value');
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // If enabling notifications, register the device token
    if (value) {
      await registerDeviceToken();

      // Schedule reminders for current user
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId != null) {
        await scheduleHabitReminders(userId);
      }
    } else {
      // Cancel all scheduled notifications
      await cancelAllNotifications();
    }

    return prefs.setBool(_reminderEnabledKey, value);
  }

  // Schedule notifications for habits
  static Future<void> scheduleHabitReminders(String userId) async {
    // Check if notifications are enabled in app settings
    if (!await areNotificationsEnabled()) {
      developer.log('🔕 Notifications are disabled in settings, skipping scheduling');
      await _notificationsPlugin.cancelAll();
      return;
    }

    developer.log('🔔 Scheduling habit reminders for user: $userId');

    try {
      // Cancel all existing notifications first
      await _notificationsPlugin.cancelAll();
      developer.log('🧹 Cleared all existing notifications');

      // Get habits from SharedPreferences
      final habits = await LocalStorageService.getHabits(userId);
      developer.log('📚 Found ${habits.length} habits in SharedPreferences');

      int scheduledCount = 0;

      for (final habit in habits) {
        if (habit.startTime != null) {
          final timeParts = habit.startTime!.split(':');
          if (timeParts.length == 2) {
            final hour = int.tryParse(timeParts[0]) ?? 0;
            final minute = int.tryParse(timeParts[1]) ?? 0;

            // Calculate time for 5 minutes before habit starts
            final reminderMinute = minute >= 5 ? minute - 5 : (minute + 60 - 5);
            final reminderHour = minute >= 5 ? hour : (hour == 0 ? 23 : hour - 1);

            final now = tz.TZDateTime.now(tz.local);
            var scheduledDate = tz.TZDateTime(
              tz.local,
              now.year,
              now.month,
              now.day,
              reminderHour,
              reminderMinute,
            );

            // If time already passed today, schedule for tomorrow
            if (scheduledDate.isBefore(now)) {
              scheduledDate = scheduledDate.add(const Duration(days: 1));
            }

            await _scheduleHabitReminder(
              id: habit.id.hashCode,
              title: "It's almost time for ${habit.name}!",
              body: "Your ${habit.priority} priority habit starts in 5 minutes.",
              scheduledDate: scheduledDate,
              habit: habit,
            );

            scheduledCount++;
            developer.log('📅 Scheduled reminder for "${habit.name}" at ${reminderHour.toString().padLeft(2, '0')}:${reminderMinute.toString().padLeft(2, '0')}');
          }
        }
      }

      developer.log('✅ Successfully scheduled $scheduledCount notifications');

      // Invoke server-side scheduling as backup
      await _triggerServerSideReminders(userId);

    } catch (e) {
      developer.log('❌ Error scheduling habit reminders', error: e);
    }
  }

  // Trigger server-side reminders as a backup
  static Future<void> _triggerServerSideReminders(String userId) async {
    try {
      await _supabaseClient.functions.invoke('habit-reminders',
          body: {'user_id': userId});
      developer.log('🔄 Triggered server-side reminders for user');
    } catch (e) {
      developer.log('⚠️ Failed to trigger server-side reminders', error: e);
    }
  }

  // Schedule a single habit reminder
  static Future<void> _scheduleHabitReminder({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required HabitModel habit,
  }) async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _notificationChannelId,
        _notificationChannelName,
        channelDescription: _notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Daily repetition
      payload: habit.id,
    );
  }

  // Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    developer.log('🔕 Cancelling all notifications');
    await _notificationsPlugin.cancelAll();
  }

  // Debugging
  static Future<void> showTestNotification() async {
    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _notificationChannelId,
        _notificationChannelName,
        channelDescription: _notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification from Momentum',
      notificationDetails,
    );
  }
}

// This top-level function is required for FCM background handling
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  developer.log('📲 Background message received: ${message.messageId}');
}