// lib/presentation/controllers/habit_controller.dart
import 'package:flutter/material.dart';
import 'package:momentum/core/providers/repository_providers.dart';
import 'package:momentum/data/models/habit_model.dart';
import 'package:momentum/data/repositories/habit_repository.dart';
import 'package:momentum/data/datasources/supabase_datasource.dart';
import 'package:momentum/data/models/habit_completions_model.dart';

class HabitController extends ChangeNotifier {
  final HabitRepository _repository = RepositoryProviders.habitRepository;
  final SupabaseDataSource _dataSource = SupabaseDataSource();

  bool _isLoading = false;
  String? _error;
  List<HabitModel> _habits = [];
  Map<String, List<HabitCompletionsModel>> _habitCompletions = {};


  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<HabitModel> get habits => _habits;
  Map<String, List<HabitCompletionsModel>> get habitCompletions => _habitCompletions;

  String _titleFilter = '';
  List<String> _timeFilters = [];

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

// In habit_controller.dart, replace the filteredHabits getter with:
  List<HabitModel> get filteredHabits {
    return _habits.where((habit) {
      // Title filter
      final nameMatches = _titleFilter.isEmpty ||
          (habit.name.toLowerCase()).contains(_titleFilter.toLowerCase());

      // Time filter
      bool timeMatches = _timeFilters.isEmpty;
      if (!timeMatches && habit.startTime != null) {
        try {
          final timeStr = habit.startTime ?? "";
          if (timeStr.isNotEmpty) {
            final hourStr = timeStr.split(':')[0];
            final hour = int.tryParse(hourStr) ?? 0;

            if (_timeFilters.contains('Morning') && hour >= 5 && hour < 12) {
              timeMatches = true;
            } else if (_timeFilters.contains('Evening') && hour >= 17 && hour < 22) {
              timeMatches = true;
            }
          }
        } catch (e) {
          print("Error parsing time: $e");
        }
      }

      return nameMatches && (timeMatches || _timeFilters.isEmpty);
    }).toList();
  }

  HabitModel? getHabitById(String id) {
    try {
      return _habits.firstWhere((habit) => habit.id == id);
    } catch (e) {
      debugPrint('Habit with ID $id not found: $e');
      return null;
    }
  }

// Update an existing habit
  Future<HabitModel?> updateHabit(HabitModel habit) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final updatedHabit = await _repository.updateHabit(habit);

      // Update in local list
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index >= 0) {
        _habits[index] = updatedHabit;
      }

      _isLoading = false;
      notifyListeners();

      return updatedHabit;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  Future<void> loadHabitCompletions() async {
    try {
      _habitCompletions.clear();

      for (final habit in _habits) {
        if (habit.id != null) {
          final completions = await _dataSource.getCompletionsByHabitId(habit.id!);
          _habitCompletions[habit.id!] = completions;
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading habit completions: $e');
    }
  }
  Future<void> loadHabitsWithCompletions() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Load habits first
      _habits = await _repository.getUserHabits();

      // Then load completions for each habit
      await loadHabitCompletions();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  List<HabitCompletionsModel> getCompletionsForDate(String habitId, DateTime date) {
    final completions = _habitCompletions[habitId] ?? [];
    return completions.where((completion) {
      return completion.completionDate.year == date.year &&
          completion.completionDate.month == date.month &&
          completion.completionDate.day == date.day;
    }).toList();
  }

  int calculateCurrentStreak() {
    if (_habits.isEmpty) return 0;

    int streak = 0;
    DateTime currentDate = DateTime.now();

    // Cek dari hari ini mundur ke belakang
    while (true) {
      final DateTime checkDate = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );

      bool hasAnyCompletion = false;

      // Cek apakah ada habit yang diselesaikan di hari ini
      for (final habit in _habits) {
        if (habit.id != null) {
          final completions = getCompletionsForDate(habit.id!, checkDate);
          if (completions.any((c) => c.isCompleted)) {
            hasAnyCompletion = true;
            break;
          }
        }
      }

      if (hasAnyCompletion) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  int getTotalCompletionsForDate(DateTime date) {
    int total = 0;
    for (final habit in _habits) {
      if (habit.id != null) {
        final completions = getCompletionsForDate(habit.id!, date);
        total += completions.where((c) => c.isCompleted).length;
      }
    }
    return total;
  }

  double getTodayCompletionRate() {
    if (_habits.isEmpty) return 0.0;

    final today = DateTime.now();
    final totalHabits = _habits.length;
    final completedHabits = getTotalCompletionsForDate(today);

    return completedHabits / totalHabits;
  }
  List<Map<String, dynamic>> getWeeklyData() {
    final List<Map<String, dynamic>> weekData = [];
    final DateTime now = DateTime.now();
    final int currentDayOfWeek = now.weekday; // 1 = Monday, 7 = Sunday

    // Hitung tanggal Senin minggu ini
    final DateTime mondayOfThisWeek = now.subtract(Duration(days: currentDayOfWeek - 1));

    const List<String> dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    for (int i = 0; i < 7; i++) {
      final DateTime currentDay = mondayOfThisWeek.add(Duration(days: i));
      final String dayName = dayNames[i];

      final int totalHabits = _habits.length;
      final int completedHabits = getTotalCompletionsForDate(currentDay);

      weekData.add({
        'day': dayName,
        'completed': completedHabits,
        'total': totalHabits,
        'date': currentDay,
      });
    }

    return weekData;
  }

  double getWeeklyCompletionRate() {
    final weekData = getWeeklyData();
    if (weekData.isEmpty) return 0.0;

    int totalCompleted = 0;
    int totalPossible = 0;

    for (final day in weekData) {
      totalCompleted += day['completed'] as int;
      totalPossible += day['total'] as int;
    }

    return totalPossible > 0 ? totalCompleted / totalPossible : 0.0;
  }
// Add the setFilters method
  void setFilters(String title, List<String> timeFilters) {
    _titleFilter = title;
    _timeFilters = timeFilters;
    notifyListeners();
  }
}