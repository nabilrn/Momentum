import 'package:flutter/material.dart';
import 'package:momentum/data/datasources/supabase_datasource.dart';
import 'package:momentum/data/models/habit_completions_model.dart';

class HabitCompletionService {
  final SupabaseDataSource _dataSource;

  HabitCompletionService(this._dataSource);

  Future<void> recordCompletion(String habitId) async {
    try {
      // Option 1: Don't include id in the model if your table auto-generates it
      final completionData = {
        'habit_id': habitId,
        'completion_date': DateTime.now().toIso8601String(),
        'is_completed': true,
        'created_at': DateTime.now().toIso8601String(),
      };

      // Insert directly using a Map instead of the model
      await _dataSource.insertHabitCompletionFromMap(completionData);
      debugPrint('✅ Habit completion recorded successfully');
    } catch (e) {
      debugPrint('❌ Error recording habit completion: $e');
      rethrow;
    }
  }

  // Alternative method using the model but excluding the id
  Future<void> recordCompletionWithModel(String habitId) async {
    try {
      final completion = HabitCompletionsModel(
        id: null, // This will be ignored during insertion
        habitId: habitId,
        completionDate: DateTime.now(),
        isCompleted: true,
        createdAt: DateTime.now(),
      );

      // You'll need to modify your data source to handle this properly
      await _dataSource.insertHabitCompletionExcludingId(completion);
      debugPrint('✅ Habit completion recorded successfully');
    } catch (e) {
      debugPrint('❌ Error recording habit completion: $e');
      rethrow;
    }
  }
}