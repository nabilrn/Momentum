// lib/presentation/controllers/habit_controller.dart
import 'package:flutter/material.dart';
import 'package:momentum/core/providers/repository_providers.dart';
import 'package:momentum/data/models/habit_model.dart';
import 'package:momentum/data/repositories/habit_repository.dart';

class HabitController extends ChangeNotifier {
  final HabitRepository _repository = RepositoryProviders.habitRepository;

  bool _isLoading = false;
  String? _error;
  List<HabitModel> _habits = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<HabitModel> get habits => _habits;

  // Create a new habit
  Future<HabitModel?> createHabit({
    required String name,
    required int focusTimeMinutes,
    required String priority,
    TimeOfDay? startTime,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final habit = await _repository.createHabit(
        name: name,
        focusTimeMinutes: focusTimeMinutes,
        priority: priority,
        startTime: startTime,
      );

      // Add to local list and notify
      _habits.insert(0, habit);

      _isLoading = false;
      notifyListeners();

      return habit;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Load all habits for the current user
  Future<void> loadHabits() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _habits = await _repository.getUserHabits();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a habit
  Future<bool> deleteHabit(String habitId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.deleteHabit(habitId);

      // Remove from local list
      _habits.removeWhere((habit) => habit.id == habitId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}