import 'dart:math';
import 'package:flutter/material.dart';
import 'package:momentum/presentation/widgets/bottom_navigation.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../widgets/random/progress_bar.dart';
import '../widgets/random/habit_card.dart';
import '../widgets/random/timer_circle.dart';
import '../widgets/random/action_button.dart';
import '../services/navigation_service.dart';
import '../controllers/habit_controller.dart';
import 'package:momentum/data/models/habit_model.dart';
import 'package:momentum/presentation/utils/color_util_random.dart';

class RandomHabitScreen extends StatefulWidget {
  const RandomHabitScreen({super.key});

  @override
  State<RandomHabitScreen> createState() => _RandomHabitScreenState();
}

class _RandomHabitScreenState extends State<RandomHabitScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 1;
  int _currentHabitIndex = 0;
  bool _isCountdownActive = false;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<HabitModel> _randomHabits = [];

  // Maximum number of habits to show
  final int _maxHabitsToShow = 3;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    // Load habits when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHabits();
    });
  }

  Future<void> _loadHabits() async {
    setState(() {
      _isLoading = true;
    });

    final habitController = Provider.of<HabitController>(context, listen: false);
    await habitController.loadHabits();

    setState(() {
      // Get all habits first
      List<HabitModel> allHabits = List.from(habitController.habits);

      // If we have more habits than we want to show, pick random ones
      if (allHabits.length > _maxHabitsToShow) {
        _randomHabits = _getRandomHabits(allHabits, _maxHabitsToShow);
      } else {
        // Otherwise use all available habits (up to 3)
        _randomHabits = allHabits;
      }

      _isLoading = false;

      // Only select a random habit if we have habits available
      if (_randomHabits.isNotEmpty) {
        _currentHabitIndex = 0; // Start with the first habit
        _animationController.forward();
      }
    });
  }

  // Helper method to get a random subset of habits
  List<HabitModel> _getRandomHabits(List<HabitModel> habits, int count) {
    if (habits.isEmpty) return [];
    if (habits.length <= count) return habits;

    final random = Random();
    final List<HabitModel> result = [];
    final List<HabitModel> tempList = List.from(habits);

    for (int i = 0; i < count; i++) {
      final int randomIndex = random.nextInt(tempList.length);
      result.add(tempList[randomIndex]);
      tempList.removeAt(randomIndex);
    }

    return result;
  }

  void _nextHabit() {
    if (_randomHabits.isEmpty) return;

    setState(() {
      _currentHabitIndex = (_currentHabitIndex + 1) % _randomHabits.length;
      _isCountdownActive = false;
    });
  }

  void _previousHabit() {
    if (_randomHabits.isEmpty) return;

    setState(() {
      _currentHabitIndex = (_currentHabitIndex - 1 + _randomHabits.length) % _randomHabits.length;
      _isCountdownActive = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onProgressIndicatorTap(int index) {
    if (_randomHabits.isEmpty) return;

    setState(() {
      _currentHabitIndex = index;
      _isCountdownActive = false;
    });
  }

  // Get color based on priority

  // Convert HabitModel to the format needed by HabitCard
  Map<String, dynamic> _convertHabitToMap(HabitModel habit) {
    return {
      'name': habit.name,
      'duration': habit.focusTimeMinutes,
      'priority': habit.priority,
      'category': 'Habit', // If your HabitModel doesn't have a category, you can set a default
      'color': ColorUtils.getPriorityColor(habit.priority), // Add color based on priority
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.isDarkMode(context);
    final accentColor = const Color(0xFF4B6EFF);

    // Calculate safe bottom padding accounting for navigation bar
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80.0;

    return Scaffold(
      extendBody: true,
      backgroundColor: isDarkMode ? const Color(0xFF121117) : Colors.white,
      appBar: AppBar(
        title: const Text(
          'Random Habit',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: isDarkMode
            ? const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF121117),
              Color(0xFF1A1A24),
            ],
          ),
        )
            : const BoxDecoration(color: Colors.white),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: accentColor,
              ),
            )
                : _randomHabits.isEmpty
                ? _buildEmptyState(isDarkMode)
                : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Today\'s Random Challenge',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                // Swipeable habit card
                GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! > 0) {
                      // Swiping right (previous)
                      _previousHabit();
                    } else if (details.primaryVelocity! < 0) {
                      // Swiping left (next)
                      _nextHabit();
                    }
                  },
                  child: HabitCard(
                    habit: _convertHabitToMap(_randomHabits[_currentHabitIndex]),
                    isDarkMode: isDarkMode,
                    textColor: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 30),
                TimerCircle(
                  habit: _convertHabitToMap(_randomHabits[_currentHabitIndex]),
                  isDarkMode: isDarkMode,
                  isCountdownActive: _isCountdownActive,
                  animation: _animation,
                ),
                const SizedBox(height: 20),
                ProgressBar(
                  isDarkMode: isDarkMode,
                  currentIndex: _currentHabitIndex,
                  totalItems: _randomHabits.length,
                  onIndicatorTap: _onProgressIndicatorTap,
                ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ActionButton(
                        icon: Icons.swipe,
                        label: 'Next',
                        color: ColorUtils.getPriorityColor(_randomHabits[_currentHabitIndex].priority),
                        isDarkMode: isDarkMode,
                        onPressed: _nextHabit,
                        isOutlined: true,
                      ),
                      const SizedBox(width: 40), // Add margin between buttons
                      ActionButton(
                        icon: Icons.timer,
                        label: 'Open Timer',
                        color: ColorUtils.getPriorityColor(_randomHabits[_currentHabitIndex].priority),
                        isDarkMode: isDarkMode,
                        onPressed: () {
                          NavigationService.navigateTo(
                              context,
                              '/timer',
                              arguments: {'habitId': _randomHabits[_currentHabitIndex].id}
                          );
                        },
                        isOutlined: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
      floatingActionButton: _randomHabits.isEmpty && !_isLoading ? FloatingActionButton(
        onPressed: () => NavigationService.navigateTo(context, '/add_habit'),
        backgroundColor: accentColor,
        child: const Icon(Icons.add),
      ) : null,
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 80,
            color: isDarkMode ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No habits found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create habits to start your random challenges',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => NavigationService.navigateTo(context, '/add_habit'),
            icon: const Icon(Icons.add),
            label: const Text('Add New Habit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4B6EFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
