import 'package:flutter/material.dart';
import 'package:momentum/presentation/controllers/habit_controller.dart';
import 'package:momentum/presentation/widgets/home/habit_item.dart';
import 'package:momentum/presentation/widgets/home/filter_bottom_sheet.dart';

class HabitList extends StatefulWidget {
  final HabitController habitController;

  const HabitList({
    super.key,
    required this.habitController,
  });

  @override
  State<HabitList> createState() => _HabitListState();
}

class _HabitListState extends State<HabitList> {
  String _titleFilter = '';
  List<String> _timeFilters = [];
  // Track locally filtered habits to ensure proper state management
  List<dynamic> _filteredHabits = [];

  // Time ranges for filtering - made more dynamic
  final Map<String, TimeRange> _timeRanges = {
    'Morning': TimeRange(5, 12),
    'Afternoon': TimeRange(12, 17),
    'Evening': TimeRange(17, 22),
    'Night': TimeRange(22, 5),
  };

  @override
  void initState() {
    super.initState();
    // Initialize filtered habits
    _updateFilteredHabits();
  }

  @override
  void didUpdateWidget(HabitList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update filtered habits when parent widget updates
    _updateFilteredHabits();
  }

  void _updateFilteredHabits() {
    setState(() {
      _filteredHabits = _applyFilters(widget.habitController.habits);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasActiveFilters = _titleFilter.isNotEmpty || _timeFilters.isNotEmpty;

    // Map filtered habits to display format
    final habitsToDisplay = _filteredHabits.map((habit) => {
      'id': habit.id ?? '',
      'name': habit.name,
      'startTime': habit.startTime ?? 'Not set',
      'priority': habit.priority,
      'focusTimeMinutes': habit.focusTimeMinutes,
    }).toList();

    return Column(
      children: [
        _buildHeaderWithFilter(context),
        if (hasActiveFilters) _buildActiveFiltersChips(),
        Expanded(
          child: habitsToDisplay.isEmpty
              ? _buildEmptyState(hasActiveFilters)
              : _buildHabitsList(habitsToDisplay),
        ),
      ],
    );
  }

  Widget _buildHeaderWithFilter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'My Habits',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          _buildFilterButton(),
        ],
      ),
    );
  }

  Widget _buildFilterButton() {
    final bool hasActiveFilters = _titleFilter.isNotEmpty || _timeFilters.isNotEmpty;

    return IconButton(
      icon: Stack(
        children: [
          const Icon(Icons.filter_list),
          if (hasActiveFilters)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF4B6EFF),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      onPressed: _showFilterBottomSheet,
    );
  }

  void _showFilterBottomSheet() {
    showFilterBottomSheet(
      context,
      onApplyFilters: (title, timeFilters) {
        setState(() {
          _titleFilter = title;
          _timeFilters = timeFilters;
          // Update filtered habits when filters change
          _updateFilteredHabits();
        });
      },
    );
  }

  Widget _buildHabitsList(List<Map<String, dynamic>> habits) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: habits.length,
      itemBuilder: (context, index) {
        final habit = habits[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildDismissibleHabit(habit, index),
        );
      },
    );
  }

  Widget _buildDismissibleHabit(Map<String, dynamic> habit, int index) {
    return Dismissible(
      key: ValueKey(habit['id']), // Use ValueKey instead of Key
      background: _buildDismissibleBackground(),
      secondaryBackground: _buildDismissibleBackground(),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await _confirmDeletion(context, habit);
      },
      onDismissed: (direction) {
        // Remove from the original data source first
        final habitId = habit['id'];

        // Execute deletion logic in a separate method to avoid rebuilding issues
        _handleHabitDeletion(habitId, habit['name']);
      },
      child: HabitItem(habit: habit),
    );
  }

// Handle habit deletion as a separate process without undo
  void _handleHabitDeletion(String habitId, String habitName) {
    // First, remove from the controller.
    widget.habitController.deleteHabit(habitId).then((_) {
      // Show snackbar notification after deletion completes.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$habitName deleted"),
        ),
      );
    });
  }

  Widget _buildDismissibleBackground() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20.0),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete,
            color: Colors.white,
          ),
          SizedBox(height: 4),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDeletion(BuildContext context, Map<String, dynamic> habit) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    ) ?? false;  // Default to false if dialog is dismissed
  }

  Widget _buildActiveFiltersChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          if (_titleFilter.isNotEmpty)
            _buildFilterChip(
              'Title: $_titleFilter',
                  () {
                setState(() {
                  _titleFilter = '';
                  _updateFilteredHabits();
                });
              },
            ),
          ..._timeFilters.map((filter) => _buildFilterChip(
            filter,
                () {
              setState(() {
                _timeFilters.remove(filter);
                _updateFilteredHabits();
              });
            },
          )),
          if (_titleFilter.isNotEmpty || _timeFilters.isNotEmpty)
            const SizedBox(width: 8),
          if (_titleFilter.isNotEmpty || _timeFilters.isNotEmpty)
            TextButton(
              onPressed: _clearAllFilters,
              child: const Text('Clear All'),
            )
        ],
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _titleFilter = '';
      _timeFilters = [];
      _updateFilteredHabits();
    });
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 16),
        onDeleted: onRemove,
        backgroundColor: const Color(0xFF4B6EFF).withOpacity(0.1),
        deleteIconColor: const Color(0xFF4B6EFF),
        labelStyle: const TextStyle(color: Color(0xFF4B6EFF)),
      ),
    );
  }

  Widget _buildEmptyState(bool hasFilters) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.filter_list : Icons.schedule,
            size: 60,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters
                ? 'No habits match your filters'
                : 'No habits added yet',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          if (hasFilters)
            ElevatedButton(
              onPressed: _clearAllFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B6EFF),
              ),
              child: const Text('Clear Filters'),
            ),
        ],
      ),
    );
  }

  List<dynamic> _applyFilters(List<dynamic> habits) {
    return habits.where((habit) {
      // Title filter - case-insensitive search
      final nameMatches = _titleFilter.isEmpty ||
          (habit.name?.toLowerCase() ?? '').contains(_titleFilter.toLowerCase());

      // Time filter
      bool timeMatches = _timeFilters.isEmpty;

      if (!timeMatches && habit.startTime != null) {
        timeMatches = _checkTimeMatch(habit.startTime);
      }

      return nameMatches && (timeMatches || _timeFilters.isEmpty);
    }).toList();
  }

  bool _checkTimeMatch(String timeStr) {
    try {
      // Parse time string like "12:30" to get the hour
      final parts = timeStr.split(':');
      if (parts.length < 2) return false;

      final hour = int.tryParse(parts[0]) ?? -1;
      if (hour < 0) return false;

      // Check each selected time filter
      for (final filter in _timeFilters) {
        final timeRange = _timeRanges[filter];
        if (timeRange != null) {
          if (timeRange.start < timeRange.end) {
            // Normal time range (e.g., 5-12)
            if (hour >= timeRange.start && hour < timeRange.end) {
              return true;
            }
          } else {
            // Overnight time range (e.g., 22-5)
            if (hour >= timeRange.start || hour < timeRange.end) {
              return true;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error parsing time: $e");
    }

    return false;
  }
}

// Helper class for time ranges
class TimeRange {
  final int start;
  final int end;

  TimeRange(this.start, this.end);
}