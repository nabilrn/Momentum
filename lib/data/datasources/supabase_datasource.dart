// lib/data/datasources/supabase_datasource.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:momentum/core/services/supabase_service.dart';
import 'package:momentum/data/models/habit_model.dart';
import 'package:momentum/data/models/habit_completions_model.dart';

class SupabaseDataSource {
  final SupabaseClient _client = SupabaseService.client;

  // Table names
  static const String _habitsTable = 'habit';
  static const String _habitCompletionsTable = 'habit_completions';

  // Create a new habit in Supabase
  Future<HabitModel> createHabit(HabitModel habit) async {
    try {
      // Make sure the user is authenticated
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User must be authenticated to create habits');
      }

      final habitData = habit.toMap();
      debugPrint('User ID in habit data: ${habitData['user_id']}');
      debugPrint('Current user ID: ${_client.auth.currentUser?.id}');

      // Ensure the user_id matches the authenticated user
      habitData['user_id'] = currentUser.id;

      debugPrint('📝 Attempting to create habit with data: $habitData');

      final response =
          await _client.from(_habitsTable).insert(habitData).select().single();

      debugPrint('✅ SupabaseDataSource: Habit created successfully');
      return HabitModel.fromMap(response);
    } catch (e) {
      debugPrint('❌ SupabaseDataSource: Error creating habit: $e');
      rethrow;
    }
  }

  // Get all habits for a specific user
  Future<List<HabitModel>> getHabitsForUser(String userId) async {
    try {
      final response = await _client
          .from(_habitsTable)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => HabitModel.fromMap(item))
          .toList();
    } catch (e) {
      debugPrint('❌ SupabaseDataSource: Error fetching habits: $e');
      rethrow;
    }
  }

  Future<HabitModel> updateHabit(HabitModel habit) async {
    try {
      final response =
          await _client
              .from(_habitsTable)
              .update(habit.toMap())
              .eq('id', habit.id)
              .select()
              .single();

      debugPrint('✅ SupabaseDataSource: Habit updated successfully');
      return HabitModel.fromMap(response);
    } catch (e) {
      debugPrint('❌ SupabaseDataSource: Error updating habit: $e');
      throw Exception('Failed to update habit: $e');
    }
  }

  // Delete a habit
  Future<void> deleteHabit(String habitId) async {
    try {
      await _client.from(_habitsTable).delete().eq('id', habitId);
    } catch (e) {
      debugPrint('❌ SupabaseDataSource: Error deleting habit: $e');
      rethrow;
    }
  }

  // Add these methods to your SupabaseDataSource class

  // Method 1: Insert from Map (recommended)
  Future<void> insertHabitCompletionFromMap(Map<String, dynamic> data) async {
    try {
      await SupabaseService.client.from('habit_completions').insert(data);
    } catch (e) {
      debugPrint('❌ Error inserting habit completion from map: $e');
      rethrow;
    }
  }

  // Method 2: Insert model excluding id
  Future<void> insertHabitCompletionExcludingId(
    HabitCompletionsModel completion,
  ) async {
    try {
      final data = {
        'habit_id': completion.habitId,
        'completion_date': completion.completionDate.toIso8601String(),
        'is_completed': completion.isCompleted,
        'created_at': completion.createdAt.toIso8601String(),
      };

      await SupabaseService.client.from('habit_completions').insert(data);
    } catch (e) {
      debugPrint('❌ Error inserting habit completion excluding id: $e');
      rethrow;
    }
  }

  Future<void> insertHabitCompletion(HabitCompletionsModel completion) async {
    try {
      final data = completion.toMap(); // Use toMap() instead of toJson()
      data.remove('id'); // Remove the id field before insertion

      await SupabaseService.client.from('habit_completions').insert(data);
    } catch (e) {
      debugPrint('❌ Error inserting habit completion: $e');
      rethrow;
    }
  }

  Future<List<HabitCompletionsModel>> getCompletionsByHabitId(
    String habitId,
  ) async {
    try {
      final response = await _client
          .from(_habitCompletionsTable)
          .select()
          .eq('habit_id', habitId)
          .order('completion_date', ascending: false);

      return (response as List)
          .map((item) => HabitCompletionsModel.fromMap(item))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching habit completions: $e');
      rethrow;
    }
  }

  // Add to your SupabaseDataSource class
  Future<List<HabitCompletionsModel>> getHabitCompletions({
    required String habitId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _client
          .from(_habitCompletionsTable)
          .select()
          .eq('habit_id', habitId)
          .gte('completion_date', startDate)
          .lt('completion_date', endDate);

      return (response as List)
          .map((item) => HabitCompletionsModel.fromMap(item))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching habit completions by date range: $e');
      rethrow;
    }
  }
}
