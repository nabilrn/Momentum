import 'dart:math';
import 'package:flutter/material.dart';
import 'package:momentum/presentation/widgets/bottom_navigation.dart';
import 'package:momentum/core/theme/app_theme.dart';
import '../widgets/random/progress_bar.dart';
import '../widgets/random/habit_card.dart';
import '../widgets/random/timer_circle.dart';
import '../widgets/random/action_button.dart';
import '../services/navigation_service.dart';

class RandomHabitScreen extends StatefulWidget {
  const RandomHabitScreen({super.key});

  @override
  State<RandomHabitScreen> createState() => _RandomHabitScreenState();
}

class _RandomHabitScreenState extends State<RandomHabitScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 1;
  int _currentHabitIndex = 0;
  bool _isCountdownActive = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Updated habits with category and removed icon dependency
  final List<Map<String, dynamic>> _randomHabits = [
    {'name': 'Morning Jog', 'duration': 15, 'priority': 'High', 'category': 'Fitness'},
    {'name': 'Meditation', 'duration': 10, 'priority': 'Low', 'category': 'Wellness'},
    {'name': 'Reading', 'duration': 20, 'priority': 'Medium', 'category': 'Knowledge'},
    {'name': 'Stretching', 'duration': 5, 'priority': 'Low', 'category': 'Fitness'},
    {'name': 'Journaling', 'duration': 15, 'priority': 'Medium', 'category': 'Mindfulness'},
  ];

  @override
  void initState() {
    super.initState();
    _selectRandomHabit();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });

    _animationController.forward();
  }

  void _selectRandomHabit() {
    final random = Random();
    setState(() {
      _currentHabitIndex = random.nextInt(_randomHabits.length);
      _isCountdownActive = false;
    });
  }

  void _nextHabit() {
    setState(() {
      _currentHabitIndex = (_currentHabitIndex + 1) % _randomHabits.length;
      _isCountdownActive = false;
    });
  }

  void _previousHabit() {
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
    // Handle progress indicator tap
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.isDarkMode(context);
    final currentHabit = _randomHabits[_currentHabitIndex];
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
            child: Column(
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
                    habit: currentHabit,
                    isDarkMode: isDarkMode,
                    textColor: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 30),
                TimerCircle(
                  habit: currentHabit,
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
                        icon: Icons.refresh,
                        label: 'Skip',
                        color: accentColor,
                        isDarkMode: isDarkMode,
                        onPressed: _selectRandomHabit,
                        isOutlined: true,
                      ),
                      const SizedBox(width: 40), // Add margin between buttons
                      ActionButton(
                        icon: Icons.timer,
                        label: 'Open Timer',
                        color: accentColor,
                        isDarkMode: isDarkMode,
                        onPressed: (){
                          NavigationService.navigateTo(context, '/timer');
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
    );
  }
}