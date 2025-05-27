// lib/core/services/local_storage_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:momentum/data/models/habit_model.dart';

class LocalStorageService {
  static const String _habitsKey = 'user_habits';

  // Save habits to local storage
  static Future<bool> saveHabits(List<HabitModel> habits, String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert habits to list of maps, then to JSON string
      final habitsJson = habits.map((habit) => habit.toMap()).toList();
      final habitsString = jsonEncode(habitsJson);

      // Store with user-specific key to handle multiple accounts
      return await prefs.setString('${_habitsKey}_$userId', habitsString);
    } catch (e) {
      debugPrint('❌ Error saving habits to local storage: $e');
      return false;
    }
  }

  // Get habits from local storage
  static Future<List<HabitModel>> getHabits(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsString = prefs.getString('${_habitsKey}_$userId');

      if (habitsString == null) {
        return [];
      }

      final habitsJson = jsonDecode(habitsString) as List;
      return habitsJson
          .map((habitMap) => HabitModel.fromMap(habitMap))
          .toList();
    } catch (e) {
      debugPrint('❌ Error retrieving habits from local storage: $e');
      return [];
    }
  }

  // Clear habits from local storage
  static Future<bool> clearHabits(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove('${_habitsKey}_$userId');
    } catch (e) {
      debugPrint('❌ Error clearing habits from local storage: $e');
      return false;
    }
  }

  // Get last sync timestamp
  static Future<DateTime?> getLastSyncTime(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getString('last_sync_$userId');
      return timestamp != null ? DateTime.parse(timestamp) : null;
    } catch (e) {
      return null;
    }
  }

  // Set last sync timestamp
  static Future<bool> setLastSyncTime(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString('last_sync_$userId', DateTime.now().toIso8601String());
    } catch (e) {
      return false;
    }
  }
}