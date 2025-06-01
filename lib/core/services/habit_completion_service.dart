import 'package:flutter/material.dart';
import 'package:momentum/data/datasources/supabase_datasource.dart';
import 'package:momentum/data/models/habit_completions_model.dart';


class HabitCompletionService {
  final SupabaseDataSource _dataSource;

  HabitCompletionService(this._dataSource);

  // Check if habit has been completed today
  Future<bool> isHabitCompletedToday(String habitId) async {
    try {
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final DateTime tomorrow = today.add(const Duration(days: 1));

      // Get completions between start of today and start of tomorrow
      final completions = await _dataSource.getHabitCompletions(
        habitId: habitId,
        startDate: today.toIso8601String(),
        endDate: tomorrow.toIso8601String(),
      );

      return completions.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error checking habit completion: $e');
      return false; // Assume not completed on error
    }
  }

  Future<bool> recordCompletion(String habitId) async {
    try {
      // Check if already completed today
      if (await isHabitCompletedToday(habitId)) {
        debugPrint('ℹ️ Habit already completed today');
        return false; // No new record created
      }

      final completionData = {
        'habit_id': habitId,
        'completion_date': DateTime.now().toIso8601String(),
        'is_completed': true,
        'created_at': DateTime.now().toIso8601String(),
      };

      await _dataSource.insertHabitCompletionFromMap(completionData);
      debugPrint('✅ Habit completion recorded successfully');
      return true; // New record created
    } catch (e) {
      debugPrint('❌ Error recording habit completion: $e');
      rethrow;
    }
  }

  // Updated alternative method
  Future<bool> recordCompletionWithModel(String habitId) async {
    try {
      // Check if already completed today
      if (await isHabitCompletedToday(habitId)) {
        debugPrint('ℹ️ Habit already completed today');
        return false; // No new record created
      }

      final completion = HabitCompletionsModel(
        id: null,
        habitId: habitId,
        completionDate: DateTime.now(),
        isCompleted: true,
        createdAt: DateTime.now(),
      );

      await _dataSource.insertHabitCompletionExcludingId(completion);
      debugPrint('✅ Habit completion recorded successfully');
      return true; // New record created
    } catch (e) {
      debugPrint('❌ Error recording habit completion: $e');
      rethrow;
    }
  }
}