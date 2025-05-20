import 'package:flutter/material.dart';
import 'package:momentum/data/datasources/supabase_datasource.dart';
import 'package:momentum/data/models/habit_model.dart';
import 'package:momentum/core/services/auth_service.dart';
import 'dart:developer' as developer;

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
      developer.log('Formatted start time: $formattedStartTime');

      // Create habit model
      final habit = HabitModel(
        name: name,
        focusTimeMinutes: focusTimeMinutes,
        priority: priority,
        startTime: formattedStartTime,
        userId: userId,
      );
      developer.log('Created habit model: ${habit.toMap()}');

      // Save to database
      final result = await _dataSource.createHabit(habit);
      developer.log('Habit created successfully with ID: ${result.id}');
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

      final habits = await _dataSource.getHabitsForUser(userId);
      developer.log('Retrieved ${habits.length} habits');
      return habits;
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
      developer.log('Current user ID: $userId');

      if (userId == null) {
        developer.log('Authentication error: User not authenticated', error: 'AUTH_ERROR');
        throw Exception('User not authenticated');
      }

      // Ensure the habit belongs to the current user
      if (habit.userId != userId) {
        developer.log('Authorization error: Cannot update habit that does not belong to the user', error: 'AUTH_ERROR');
        throw Exception('Cannot update habit that does not belong to the user');
      }

      final updatedHabit = await _dataSource.updateHabit(habit);
      developer.log('Habit updated successfully');
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
      await _dataSource.deleteHabit(habitId);
      developer.log('Habit deleted successfully');
    } catch (e, stackTrace) {
      developer.log('Error deleting habit', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}