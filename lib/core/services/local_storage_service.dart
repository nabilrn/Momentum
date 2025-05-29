// lib/core/services/local_storage_service.dart
import 'package:momentum/data/models/habit_model.dart';
import 'package:momentum/core/services/database_helper.dart';
import 'dart:developer' as developer;

class LocalStorageService {
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  static Future<void> saveHabits(String userId, List<HabitModel> habits) async {
    developer.log('💾 Saving ${habits.length} habits to SQLite for user: $userId');
    try {
      // First delete all habits for this user
      await _dbHelper.deleteAllHabitsForUser(userId);
      // Then insert all the new habits
      await _dbHelper.insertHabits(habits);
      developer.log('✅ Successfully saved habits to SQLite');
    } catch (e) {
      developer.log('❌ Error saving habits to SQLite', error: e);
      throw e;
    }
  }

  static Future<List<HabitModel>> getHabits(String userId) async {
    developer.log('🔍 Getting habits for user: $userId');
    try {
      final habits = await _dbHelper.getHabitsByUserId(userId);
      developer.log('📚 Found ${habits.length} habits in SQLite');
      return habits;
    } catch (e) {
      developer.log('❌ Error getting habits from SQLite', error: e);
      return [];
    }
  }

  static Future<void> addHabit(HabitModel habit) async {
    developer.log('➕ Adding habit to SQLite: ${habit.name}');
    try {
      await _dbHelper.insertHabit(habit);
      developer.log('✅ Successfully added habit to SQLite');
    } catch (e) {
      developer.log('❌ Error adding habit to SQLite', error: e);
      throw e;
    }
  }

  static Future<void> updateHabit(HabitModel habit) async {
    developer.log('🔄 Updating habit in SQLite: ${habit.name}');
    try {
      await _dbHelper.updateHabit(habit);
      developer.log('✅ Successfully updated habit in SQLite');
    } catch (e) {
      developer.log('❌ Error updating habit in SQLite', error: e);
      throw e;
    }
  }

  static Future<void> deleteHabit(String habitId) async {
    developer.log('🗑️ Deleting habit from SQLite: $habitId');
    try {
      await _dbHelper.deleteHabit(habitId);
      developer.log('✅ Successfully deleted habit from SQLite');
    } catch (e) {
      developer.log('❌ Error deleting habit from SQLite', error: e);
      throw e;
    }
  }

  static Future<void> clearUserHabits(String userId) async {
    developer.log('🧹 Clearing all habits for user: $userId');
    try {
      await _dbHelper.deleteAllHabitsForUser(userId);
      developer.log('✅ Successfully cleared all habits for user');
    } catch (e) {
      developer.log('❌ Error clearing habits', error: e);
      throw e;
    }
  }
}