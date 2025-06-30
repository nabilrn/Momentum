import 'package:flutter/material.dart';
import 'package:momentum/presentation/controllers/habit_controller.dart';
import 'package:momentum/presentation/widgets/home/habit_item.dart';
import 'package:momentum/presentation/widgets/home/filter_bottom_sheet.dart';
import 'package:momentum/presentation/widgets/home/edit_habit_dialog.dart';
import '../../widgets/common/empty_state_widget.dart';

class HabitList extends StatefulWidget {
  final HabitController habitController;

  const HabitList({super.key, required this.habitController});

  @override
  State<HabitList> createState() => _HabitListState();
}

class _HabitListState extends State<HabitList> {
  String _titleFilter = '';
  List<String> _timeFilters = [];
  List<dynamic> _filteredHabits = [];
  // Track dismissed habit IDs to prevent rebuilding dismissed items
  final Set<String> _dismissedHabitIds = {};

  final Map<String, TimeRange> _timeRanges = {
    'Morning': TimeRange(5, 12),
    'Afternoon': TimeRange(12, 17),
    'Evening': TimeRange(17, 22),
    'Night': TimeRange(22, 5),
  };

  @override
  void initState() {
    super.initState();
    _updateFilteredHabits();
  }

  @override
  void didUpdateWidget(HabitList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update filtered habits if the controller's habits have changed
    if (oldWidget.habitController.habits != widget.habitController.habits) {
      _updateFilteredHabits();
    }
  }

  void _updateFilteredHabits() {
    setState(() {
      // Exclude dismissed habits
      _filteredHabits = _applyFilters(
        widget.habitController.habits
            .where((habit) => !_dismissedHabitIds.contains(habit.id))
            .toList(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasActiveFilters =
        _titleFilter.isNotEmpty || _timeFilters.isNotEmpty;

    // Map filtered habits to display format
    final habitsToDisplay =
        _filteredHabits
            .map(
              (habit) => {
                'id': habit.id ?? '',
                'name': habit.name,
                'startTime': habit.startTime ?? 'Not set',
                'priority': habit.priority,
                'focusTimeMinutes': habit.focusTimeMinutes,
                'isFavorite': habit.isFavorite,
                'userId': habit.userId,
                'createdAt': habit.createdAt,
              },
            )
            .toList();

    return Column(
      children: [
        _buildHeaderWithFilter(context),
        if (hasActiveFilters) _buildActiveFiltersChips(),
        Expanded(
          child:
              habitsToDisplay.isEmpty
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
              color:
                  Theme.of(context).brightness == Brightness.dark
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
    final bool hasActiveFilters =
        _titleFilter.isNotEmpty || _timeFilters.isNotEmpty;

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
    // Ensure habit['id'] is non-null and unique
    if (habit['id'].isEmpty) {
      debugPrint('Warning: Habit ID is empty for ${habit['name']}');
    }
    return Dismissible(
      key: ValueKey(habit['id']),
      background: _buildEditBackground(),
      secondaryBackground: _buildDeleteBackground(),
      direction: DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _confirmDeletion(context, habit);
        } else {
          _handleEditHabit(habit);
          return false;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          final habitId = habit['id'];
          final habitName = habit['name'];

          // Add to dismissed IDs to prevent rebuilding
          setState(() {
            _dismissedHabitIds.add(habitId);
            _filteredHabits.removeWhere((h) => h.id == habitId);
          });

          // Handle backend deletion
          _handleHabitDeletion(habitId, habitName);
        }
      },
      child: HabitItem(
        habit: habit,
        onFavoriteToggle: () => _toggleFavorite(habit['id']),
      ),
    );
  }

  void _handleHabitDeletion(String habitId, String habitName) {
    widget.habitController
        .deleteHabit(habitId)
        .then((_) {
          setState(() {
            _dismissedHabitIds.remove(habitId);
          });
        })
        .catchError((error) {
          // On error, restore the habit in the UI
          setState(() {
            _dismissedHabitIds.remove(habitId);
            _updateFilteredHabits();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to delete $habitName: $error"),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(
                bottom: 80.0,
                left: 10.0,
                right: 10.0,
              ),
            ),
          );
        });
  }

  void _handleEditHabit(Map<String, dynamic> habit) {
    EditHabitDialog.show(
      context,
      habit,
      onHabitUpdated: () {
        // Force rebuild of the list
        setState(() {
          _updateFilteredHabits();
        });
      },
    );
  }

  Widget _buildEditBackground() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4B6EFF),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20.0),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit, color: Colors.white),
          SizedBox(height: 4),
          Text(
            'Edit',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteBackground() {
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
          Icon(Icons.delete, color: Colors.white),
          SizedBox(height: 4),
          Text(
            'Delete',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDeletion(
    BuildContext context,
    Map<String, dynamic> habit,
  ) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor:
                    isDarkMode ? const Color(0xFF1A1A24) : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  'Delete Habit',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  'Are you sure you want to delete "${habit['name']}"?',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          isDarkMode ? Colors.white70 : Colors.grey.shade700,
                    ),
                    child: const Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text(
                      'DELETE',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Widget _buildActiveFiltersChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          if (_titleFilter.isNotEmpty)
            _buildFilterChip('Title: $_titleFilter', () {
              setState(() {
                _titleFilter = '';
                _updateFilteredHabits();
              });
            }),
          ..._timeFilters.map(
            (filter) => _buildFilterChip(filter, () {
              setState(() {
                _timeFilters.remove(filter);
                _updateFilteredHabits();
              });
            }),
          ),
          if (_titleFilter.isNotEmpty || _timeFilters.isNotEmpty)
            const SizedBox(width: 8),
          if (_titleFilter.isNotEmpty || _timeFilters.isNotEmpty)
            TextButton(
              onPressed: _clearAllFilters,
              child: const Text('Clear All'),
            ),
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
    return hasFilters
        ? EmptyStateWidget(
          title: 'No habits match your filters',
          message: 'Try changing your search criteria',
          lottieAsset: 'assets/lottie/empty_state.json',
          actionLabel: 'Clear Filters',
          onActionPressed: _clearAllFilters,
        )
        : EmptyStateWidget(
          title: 'No habits added yet',
          message: 'Start creating habits to build momentum',
          lottieAsset: 'assets/lottie/empty_state.json',
        );
  }

  List<dynamic> _applyFilters(List<dynamic> habits) {
    return habits.where((habit) {
      final nameMatches =
          _titleFilter.isEmpty ||
          (habit.name?.toLowerCase() ?? '').contains(
            _titleFilter.toLowerCase(),
          );

      bool timeMatches = _timeFilters.isEmpty;

      if (!timeMatches && habit.startTime != null) {
        timeMatches = _checkTimeMatch(habit.startTime);
      }

      return nameMatches && (timeMatches || _timeFilters.isEmpty);
    }).toList();
  }

  bool _checkTimeMatch(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length < 2) return false;

      final hour = int.tryParse(parts[0]) ?? -1;
      if (hour < 0) return false;

      for (final filter in _timeFilters) {
        final timeRange = _timeRanges[filter];
        if (timeRange != null) {
          if (timeRange.start < timeRange.end) {
            if (hour >= timeRange.start && hour < timeRange.end) {
              return true;
            }
          } else {
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

  void _toggleFavorite(String habitId) async {
    try {
      await widget.habitController.toggleFavorite(habitId);
      setState(() {
        _updateFilteredHabits();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to toggle favorite: $e"),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80.0, left: 10.0, right: 10.0),
        ),
      );
    }
  }
}

class TimeRange {
  final int start;
  final int end;

  TimeRange(this.start, this.end);
}
