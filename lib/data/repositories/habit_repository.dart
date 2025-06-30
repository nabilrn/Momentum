// lib/data/repositories/habit_repository.dart
import 'package:flutter/material.dart';
import 'package:momentum/data/datasources/supabase_datasource.dart';
import 'package:momentum/data/models/habit_model.dart';
import 'package:momentum/core/services/auth_service.dart';
import 'package:momentum/core/services/local_storage_service.dart';
import 'package:momentum/core/services/fcm_service.dart';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

class HabitRepository {
  final SupabaseDataSource _dataSource;
  final AuthService _authService;

  HabitRepository({
    required SupabaseDataSource dataSource,
    required AuthService authService,
  }) : _dataSource = dataSource,
       _authService = authService;

  // Create a new habit
  Future<HabitModel> createHabit({
    required String name,
    required int focusTimeMinutes,
    required String priority,
    TimeOfDay? startTime,
  }) async {
    try {
      developer.log(
        'Creating habit: $name, $focusTimeMinutes min, priority: $priority',
      );

      // Get current user ID
      final userId = _authService.currentUser?.id;
      developer.log('Current user ID: $userId');

      if (userId == null) {
        developer.log(
          'Authentication error: User not authenticated',
          error: 'AUTH_ERROR',
        );
        throw Exception('User not authenticated');
      }

      // Format start time for storage
      final formattedStartTime =
          startTime != null ? HabitModel.formatTimeOfDay(startTime) : null;

      // Create habit model
      final habit = HabitModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
        name: name,
        focusTimeMinutes: focusTimeMinutes,
        priority: priority,
        startTime: formattedStartTime,
        userId: userId,
        isFavorite: false, // Default to false for new habits
      );

      // Save to database
      final result = await _dataSource.createHabit(habit);

      // After successful creation, add to local storage
      await LocalStorageService.addHabit(result);

      // Update notifications if enabled
      final isEnabled = await FCMService.areNotificationsEnabled();
      if (isEnabled) {
        await FCMService.scheduleHabitReminders(userId);
      }

      return result;
    } catch (e, stackTrace) {
      developer.log('Error creating habit', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Get all habits for current user
  Future<List<HabitModel>> getUserHabits() async {
    try {
      developer.log('Getting habits for current user');

      final userId = _authService.currentUser?.id;
      developer.log('Current user ID: $userId');

      if (userId == null) {
        developer.log(
          'Authentication error: User not authenticated',
          error: 'AUTH_ERROR',
        );
        throw Exception('User not authenticated');
      }

      try {
        // First try to get habits from Supabase
        final habits = await _dataSource.getHabitsForUser(userId);
        developer.log('Retrieved ${habits.length} habits from Supabase');

        // Update local storage with fresh data
        await LocalStorageService.saveHabits(userId, habits);
        await _updateLastSyncTime(userId);

        return habits;
      } catch (e) {
        // If Supabase fetch fails, try to get habits from local storage
        developer.log(
          'Error fetching from Supabase, trying local storage',
          error: e,
        );
        final localHabits = await LocalStorageService.getHabits(userId);
        developer.log(
          'Retrieved ${localHabits.length} habits from local storage',
        );

        if (localHabits.isEmpty) {
          // If local storage is also empty, rethrow the original exception
          rethrow;
        }

        return localHabits;
      }
    } catch (e, stackTrace) {
      developer.log('Error fetching habits', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Update a habit
  Future<HabitModel> updateHabit(HabitModel habit) async {
    try {
      developer.log('Updating habit with ID: ${habit.id}');

      final userId = _authService.currentUser?.id;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Ensure the habit belongs to the current user
      if (habit.userId != userId) {
        throw Exception('Cannot update habit that does not belong to the user');
      }

      final updatedHabit = await _dataSource.updateHabit(habit);

      // Update the habit in local storage
      await LocalStorageService.updateHabit(updatedHabit);
      await _updateLastSyncTime(userId);

      // Update notifications
      final isEnabled = await FCMService.areNotificationsEnabled();
      if (isEnabled) {
        await FCMService.scheduleHabitReminders(userId);
      }

      return updatedHabit;
    } catch (e, stackTrace) {
      developer.log('Error updating habit', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Delete a habit
  Future<void> deleteHabit(String habitId) async {
    try {
      developer.log('Deleting habit with ID: $habitId');

      final userId = _authService.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _dataSource.deleteHabit(habitId);

      // Also remove from local storage
      await LocalStorageService.deleteHabit(habitId);
      await _updateLastSyncTime(userId);

      // Update notifications
      final isEnabled = await FCMService.areNotificationsEnabled();
      if (isEnabled) {
        await FCMService.scheduleHabitReminders(userId);
      }

      developer.log('Habit deleted successfully');
    } catch (e, stackTrace) {
      developer.log('Error deleting habit', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Check if data needs syncing
  Future<bool> needsSync() async {
    final userId = _authService.currentUser?.id;
    if (userId == null) return false;

    final lastSync = await _getLastSyncTime(userId);
    if (lastSync == null) return true;

    // Sync if last sync was more than 30 minutes ago
    final thirtyMinutesAgo = DateTime.now().subtract(
      const Duration(minutes: 30),
    );
    return lastSync.isBefore(thirtyMinutesAgo);
  }

  // Helper methods for sync time management
  Future<void> _updateLastSyncTime(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'last_sync_$userId',
      DateTime.now().toIso8601String(),
    );
  }

  Future<DateTime?> _getLastSyncTime(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final timeString = prefs.getString('last_sync_$userId');
    if (timeString == null) return null;
    return DateTime.parse(timeString);
  }

  // Add a dedicated method to refresh notifications
  Future<void> refreshNotifications() async {
    final userId = _authService.currentUser?.id;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final isEnabled = await FCMService.areNotificationsEnabled();
    if (isEnabled) {
      await FCMService.scheduleHabitReminders(userId);
      developer.log('Notifications refreshed for user: $userId');
    } else {
      await FCMService.clearAllNotifications();
      developer.log('Notifications cleared - disabled in settings');
    }
  }
}
