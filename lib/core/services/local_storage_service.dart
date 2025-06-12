// lib/core/services/local_storage_service.dart
import 'package:momentum/data/models/habit_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:developer' as developer;

class LocalStorageService {
  static const String _habitsBoxName = 'habits';

  static Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(HabitModelAdapter());
    await Hive.openBox<HabitModel>(_habitsBoxName);
  }

  static Box<HabitModel> get _habitsBox => Hive.box<HabitModel>(_habitsBoxName);

  static Future<void> saveHabits(String userId, List<HabitModel> habits) async {
    developer.log(
      '💾 Saving ${habits.length} habits to Hive for user: $userId',
    );
    try {
      // First delete all habits for this user
      await clearUserHabits(userId);

      // Then save all the new habits
      for (var habit in habits) {
        await _habitsBox.put(habit.id, habit);
      }
      developer.log('✅ Successfully saved habits to Hive');
    } catch (e) {
      developer.log('❌ Error saving habits to Hive', error: e);
      throw e;
    }
  }

  static Future<List<HabitModel>> getHabits(String userId) async {
    developer.log('🔍 Getting habits for user: $userId');
    try {
      final habits =
          _habitsBox.values.where((habit) => habit.userId == userId).toList();
      developer.log('📚 Found ${habits.length} habits in Hive');
      return habits;
    } catch (e) {
      developer.log('❌ Error getting habits from Hive', error: e);
      return [];
    }
  }

  static Future<void> addHabit(HabitModel habit) async {
    developer.log('➕ Adding habit to Hive: ${habit.name}');
    try {
      await _habitsBox.put(habit.id, habit);
      developer.log('✅ Successfully added habit to Hive');
    } catch (e) {
      developer.log('❌ Error adding habit to Hive', error: e);
      throw e;
    }
  }

  static Future<void> updateHabit(HabitModel habit) async {
    developer.log('🔄 Updating habit in Hive: ${habit.name}');
    try {
      await _habitsBox.put(habit.id, habit);
      developer.log('✅ Successfully updated habit in Hive');
    } catch (e) {
      developer.log('❌ Error updating habit in Hive', error: e);
      throw e;
    }
  }

  static Future<void> deleteHabit(String habitId) async {
    developer.log('🗑️ Deleting habit from Hive: $habitId');
    try {
      await _habitsBox.delete(habitId);
      developer.log('✅ Successfully deleted habit from Hive');
    } catch (e) {
      developer.log('❌ Error deleting habit from Hive', error: e);
      throw e;
    }
  }

  static Future<void> clearUserHabits(String userId) async {
    developer.log('🧹 Clearing all habits for user: $userId');
    try {
      final habits =
          _habitsBox.values.where((habit) => habit.userId == userId).toList();

      for (var habit in habits) {
        await _habitsBox.delete(habit.id);
      }
      developer.log('✅ Successfully cleared all habits for user');
    } catch (e) {
      developer.log('❌ Error clearing habits', error: e);
      throw e;
    }
  }
}
