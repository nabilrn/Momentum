import 'package:flutter/material.dart';
import 'package:momentum/data/datasources/supabase_datasource.dart';
import 'package:momentum/data/models/habit_model.dart';
import 'package:momentum/core/services/auth_service.dart';
import 'package:momentum/core/services/local_storage_service.dart';
import 'dart:developer' as developer;
import 'package:momentum/core/services/notification_service.dart';

class HabitRepository {
  final SupabaseDataSource _dataSource;
  final AuthService _authService;

  HabitRepository({
    required SupabaseDataSource dataSource,
    required AuthService authService,
  })  : _dataSource = dataSource,
        _authService = authService;

  // Create a new habit
  Future<HabitModel> createHabit({
    required String name,
    required int focusTimeMinutes,
    required String priority,
    TimeOfDay? startTime,
  }) async {
    try {
      developer.log('Creating habit: $name, $focusTimeMinutes min, priority: $priority');

      // Get current user ID
      final userId = _authService.currentUser?.id;
      developer.log('Current user ID: $userId');

      if (userId == null) {
        developer.log('Authentication error: User not authenticated', error: 'AUTH_ERROR');
        throw Exception('User not authenticated');
      }

      // Format start time for storage
      final formattedStartTime = startTime != null
          ? HabitModel.formatTimeOfDay(startTime)
          : null;

      // Create habit model
      final habit = HabitModel(
        name: name,
        focusTimeMinutes: focusTimeMinutes,
        priority: priority,
        startTime: formattedStartTime,
        userId: userId,
      );

      // Save to database
      final result = await _dataSource.createHabit(habit);

      // After successful creation, update local cache
      final localHabits = await LocalStorageService.getHabits(userId);
      localHabits.add(result);
      await LocalStorageService.saveHabits(localHabits, userId);
      await LocalStorageService.setLastSyncTime(userId);

      final isEnabled = await NotificationService.areNotificationsEnabled();
      if (isEnabled) {
        await NotificationService.scheduleHabitReminders(userId);
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
        developer.log('Authentication error: User not authenticated', error: 'AUTH_ERROR');
        throw Exception('User not authenticated');
      }

      try {
        // First try to get habits from Supabase
        final habits = await _dataSource.getHabitsForUser(userId);
        developer.log('Retrieved ${habits.length} habits from Supabase');

        // Update local storage with fresh data
        await LocalStorageService.saveHabits(habits, userId);
        await LocalStorageService.setLastSyncTime(userId);

        return habits;
      } catch (e) {
        // If Supabase fetch fails, try to get habits from local storage
        developer.log('Error fetching from Supabase, trying local storage', error: e);
        final localHabits = await LocalStorageService.getHabits(userId);
        developer.log('Retrieved ${localHabits.length} habits from local storage');

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
      final localHabits = await LocalStorageService.getHabits(userId);
      final index = localHabits.indexWhere((h) => h.id == habit.id);

      if (index != -1) {
        localHabits[index] = updatedHabit;
        await LocalStorageService.saveHabits(localHabits, userId);
        await LocalStorageService.setLastSyncTime(userId);
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
      final localHabits = await LocalStorageService.getHabits(userId);
      final updatedHabits = localHabits.where((h) => h.id != habitId).toList();
      await LocalStorageService.saveHabits(updatedHabits, userId);
      await LocalStorageService.setLastSyncTime(userId);

      developer.log('Habit deleted successfully');
    } catch (e, stackTrace) {
      developer.log('Error deleting habit', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Check if data needs syncing (optional method)
  Future<bool> needsSync() async {
    final userId = _authService.currentUser?.id;
    if (userId == null) return false;

    final lastSync = await LocalStorageService.getLastSyncTime(userId);
    if (lastSync == null) return true;

    // Sync if last sync was more than 30 minutes ago
    final thirtyMinutesAgo = DateTime.now().subtract(const Duration(minutes: 30));
    return lastSync.isBefore(thirtyMinutesAgo);
  }
}