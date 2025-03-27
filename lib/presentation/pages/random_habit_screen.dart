import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import 'package:momentum/core/theme/app_theme.dart';
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
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectRandomHabit() {
    final random = Random();
    int newIndex;
    do {
      newIndex = random.nextInt(_randomHabits.length);
    } while (newIndex == _currentHabitIndex && _randomHabits.length > 1);

    setState(() {
      _currentHabitIndex = newIndex;
      _isCountdownActive = false;
    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      NavigationService.navigateTo(context, '/home');
    } else if (index == 2) {
      NavigationService.navigateTo(context, '/overview');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.isDarkMode(context);
    final currentHabit = _randomHabits[_currentHabitIndex];
    final primaryColor = const Color(0xFF4B6EFF);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = isDarkMode ? const Color(0xFF121117) : Colors.white;

    return Scaffold(
      extendBody: true,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Random Habit',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: textColor,
              ),
              onPressed: _selectRandomHabit,
              tooltip: 'New Random Habit',
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0 || details.primaryVelocity! < 0) {
            _selectRandomHabit();
          }
        },
        child: Container(
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
              : BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.blue.shade50,
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Progress indicators
                _buildProgressBar(isDarkMode),

                // Habit card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: _buildHabitCard(currentHabit, isDarkMode, textColor),
                ),

                // Timer circle
                Expanded(
                  child: Center(
                    child: _buildTimerCircle(currentHabit, isDarkMode, primaryColor),
                  ),
                ),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 100.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(
                        'Open Timer',
                        Icons.timer_outlined,
                        primaryColor,
                        isDarkMode,
                            () => NavigationService.navigateTo(context, '/timer'),
                      ),
                      const SizedBox(width: 16),
                      _buildActionButton(
                        'Skip',
                        Icons.skip_next_rounded,
                        isDarkMode ? Colors.white24 : Colors.black12,
                        isDarkMode,
                        _selectRandomHabit,
                        isOutlined: true,
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

  Widget _buildProgressBar(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_randomHabits.length, (index) {
          return _buildProgressIndicator(
            index == _currentHabitIndex,
            isDarkMode,
            index,
          );
        }),
      ),
    );
  }

  Widget _buildProgressIndicator(bool isSelected, bool isDarkMode, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentHabitIndex = index;
          _isCountdownActive = false;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: isSelected ? 24 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4B6EFF)
              : (isDarkMode ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildHabitCard(Map<String, dynamic> habit, bool isDarkMode, Color textColor) {
    final Color priorityColor = _getPriorityColor(habit['priority']);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF252836) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Priority indicator instead of icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                habit['name'].substring(0, 1),
                style: TextStyle(
                  color: priorityColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        habit['name'],
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        habit['priority'],
                        style: TextStyle(
                          color: priorityColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        habit['category'],
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${habit['duration']} min',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: isDarkMode ? Colors.white30 : Colors.black26,
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return const Color(0xFF4CAF50); // Green
      case 'Medium':
        return const Color(0xFFFFC107); // Yellow
      case 'High':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF4B6EFF); // Default blue
    }
  }

  Widget _buildTimerCircle(
      Map<String, dynamic> habit,
      bool isDarkMode,
      Color primaryColor,
      ) {
    final Color priorityColor = _getPriorityColor(habit['priority']);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: priorityColor.withOpacity(0.2 + (_animation.value * 0.1)),
                blurRadius: 20 + (_animation.value * 10),
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Animated outer ring
              TweenAnimationBuilder(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 1),
                builder: (context, value, child) {
                  return SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                      value: _isCountdownActive ? null : value,
                      strokeWidth: 12,
                      backgroundColor: isDarkMode
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        priorityColor.withOpacity(_isCountdownActive ? 1.0 : 0.7),
                      ),
                    ),
                  );
                },
              ),

              // Inner circle with time
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode ? const Color(0xFF252836) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: -5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${habit['duration']}',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'minutes',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white60 : Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
      String label,
      IconData icon,
      Color color,
      bool isDarkMode,
      VoidCallback onPressed, {
        bool isOutlined = false,
      }) {
    return Expanded(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: isOutlined
              ? null
              : const LinearGradient(
            colors: [
              Color(0xFF4B6EFF),
              Color(0xFF3B5AF8),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          color: isOutlined ? Colors.transparent : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isOutlined
              ? null
              : [
            BoxShadow(
              color: const Color(0xFF4B6EFF).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: isOutlined
              ? Border.all(
            color: isDarkMode ? Colors.white24 : Colors.black12,
            width: 2,
          )
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isOutlined
                        ? (isDarkMode ? Colors.white : Colors.black)
                        : Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: isOutlined
                          ? (isDarkMode ? Colors.white : Colors.black)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}