// lib/core/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_init;
import 'dart:developer' as developer;
import 'package:momentum/core/services/local_storage_service.dart';
import 'package:momentum/data/models/habit_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const String _reminderEnabledKey = 'habit_reminders_enabled';
  static const String _notificationChannelId = 'habit_reminders';
  static const String _notificationChannelName = 'Habit Reminders';
  static const String _notificationChannelDescription = 'Notifications for habit reminders';

  // Initialize notification service
  static Future<void> initialize() async {
    developer.log('🔔 Initializing NotificationService');

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
          enableVibration: true,
          enableLights: true,
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

  // Request notification permissions
  static Future<bool> requestPermissions(BuildContext context) async {
    developer.log('🔔 Requesting notification permissions');

    if (Theme.of(context).platform == TargetPlatform.android) {
      // For Android 13+ (SDK 33+), request POST_NOTIFICATIONS permission
      if (await Permission.notification.status.isDenied) {
        final status = await Permission.notification.request();
        developer.log('📱 Android notification permission status: ${status.toString()}');
        return status.isGranted;
      }
      return true;
    } else {
      final result = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      developer.log('📱 iOS notification permission status: ${result.toString()}');
      return result ?? false;
    }
  }

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
        // Debug information for each habit
        developer.log('Processing habit: ${habit.name}, startTime: ${habit.startTime}');

        // Skip habits without start time
        if (habit.startTime == null || habit.startTime!.isEmpty) {
          developer.log('⏩ Skipping habit "${habit.name ?? "Unnamed"}" - No start time set');
          continue;
        }

        try {
          final startTimeParts = habit.startTime!.split(':');
          // Check for valid time format (should be HH:MM or HH:MM:SS)
          if (startTimeParts.length < 2) {
            developer.log('⚠️ Invalid start time format for habit: ${habit.name ?? "Unnamed"} - Format: ${habit.startTime}');
            continue;
          }

          // Take only hours and minutes, ignore seconds if present
          final hour = int.parse(startTimeParts[0]);
          final minute = int.parse(startTimeParts[1].split(':').first);

          // Calculate notification time (15 minutes before start)
          final reminderMinute = minute >= 15 ? minute - 15 : (minute + 60 - 15);
          final reminderHour = minute >= 15 ? hour : (hour == 0 ? 23 : hour - 1);

          // Create proper TZDateTime for the reminder
          final now = tz.TZDateTime.now(tz.local);
          var scheduledDate = tz.TZDateTime(
            tz.local,
            now.year,
            now.month,
            now.day,
            reminderHour,
            reminderMinute,
          );

          // If the time is in the past, schedule for tomorrow
          if (scheduledDate.isBefore(now)) {
            scheduledDate = scheduledDate.add(const Duration(days: 1));
          }

          final habitId = habit.id?.hashCode ?? habit.name.hashCode;

          await _scheduleHabitReminder(
            id: habitId,
            title: "It's almost time for ${habit.name}!",
            body: "Your ${habit.priority} priority habit starts in 15 minutes.",
            scheduledDate: scheduledDate,
            habit: habit,
          );

          scheduledCount++;
          developer.log('✅ Scheduled notification for habit: ${habit.name} at ${scheduledDate.toString()}');
        } catch (e) {
          developer.log('❌ Error scheduling notification for habit: ${habit.name ?? "Unnamed"}', error: e);
        }
      }

      developer.log('✅ Successfully scheduled $scheduledCount notifications');
    } catch (e) {
      developer.log('❌ Error scheduling habit reminders', error: e);
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

  // Add to NotificationService
  static Future<void> showDebugNotification() async {
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
      999,
      "Test Notification",
      "This is a test notification",
      notificationDetails,
    );
    developer.log('🔔 Debug notification sent');
  }
}