import 'dart:math';
import 'package:flutter/material.dart';
import 'package:momentum/presentation/widgets/bottom_navigation.dart';
import 'package:momentum/presentation/widgets/sidebar_navigation.dart';
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
import '../widgets/common/empty_state_widget.dart';

class RandomHabitScreen extends StatefulWidget {
  const RandomHabitScreen({super.key});

  @override
  State<RandomHabitScreen> createState() => _RandomHabitScreenState();
}

class _RandomHabitScreenState extends State<RandomHabitScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 1;
  int _currentHabitIndex = 0;
  bool _isCountdownActive = false;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _animation;
  List<HabitModel> _randomHabits = [];

  // Maximum number of habits to show
  final int _maxHabitsToShow = 3;

  // Responsive breakpoints
  static const double _breakpoint = 768;
  static const double _largeScreenBreakpoint = 1200;

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

    final habitController = Provider.of<HabitController>(
      context,
      listen: false,
    );
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
      _currentHabitIndex =
          (_currentHabitIndex - 1 + _randomHabits.length) %
          _randomHabits.length;
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

    final routes = {
      0: '/home',
      1: '/random_habit',
      2: '/overview',
      3: '/settings',
      4: '/account',
    };

    if (routes.containsKey(index) && index != 1) {
      // Don't navigate if already on this page
      NavigationService.navigateTo(context, routes[index]!);
    }
  }

  void _onProgressIndicatorTap(int index) {
    if (_randomHabits.isEmpty) return;

    setState(() {
      _currentHabitIndex = index;
      _isCountdownActive = false;
    });
  }

  Map<String, dynamic> _convertHabitToMap(HabitModel habit) {
    return {
      'name': habit.name,
      'duration': habit.focusTimeMinutes,
      'priority': habit.priority,
      'category': 'Habit',
      'color': ColorUtils.getPriorityColor(habit.priority),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.isDarkMode(context);
    final accentColor = const Color(0xFF4B6EFF);
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive layout decision
    final usesSidebar = screenWidth > _breakpoint;
    final isLargeScreen = screenWidth > _largeScreenBreakpoint;

    return Scaffold(
      extendBody: !usesSidebar,
      backgroundColor: isDarkMode ? const Color(0xFF121117) : Colors.white,
      appBar:
          usesSidebar
              ? null
              : AppBar(
                title: const Text(
                  'Random Habit',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
      body:
          usesSidebar
              ? _buildWithSidebar(isDarkMode, accentColor, isLargeScreen)
              : _buildWithBottomNav(isDarkMode, accentColor),
      bottomNavigationBar:
          usesSidebar
              ? null
              : BottomNavigation(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
              ),
    );
  }

  Widget _buildWithSidebar(
    bool isDarkMode,
    Color accentColor,
    bool isLargeScreen,
  ) {
    return Row(
      children: [
        // Sidebar navigation
        SidebarNavigation(currentIndex: _currentIndex, onTap: _onTabTapped),

        // Main content
        Expanded(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration:
                isDarkMode
                    ? const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF121117), Color(0xFF1A1A24)],
                      ),
                    )
                    : const BoxDecoration(color: Color(0xFFF8F9FA)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom app bar for sidebar layout
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Random Habit',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),

                      // Desktop action buttons
                      Row(
                        children: [
                          _actionButton(
                            isDarkMode,
                            Icons.shuffle,
                            'Shuffle',
                            onPressed: () {
                              if (_randomHabits.isNotEmpty) _loadHabits();
                            },
                          ),
                          const SizedBox(width: 16),
                          _actionButton(
                            isDarkMode,
                            Icons.add,
                            'Add Habit',
                            onPressed:
                                () => NavigationService.navigateTo(
                                  context,
                                  '/add_habit',
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main content area - different layouts based on screen size
                Expanded(
                  child:
                      isLargeScreen
                          ? _buildLargeScreenContent(isDarkMode, accentColor)
                          : _buildMediumScreenContent(isDarkMode, accentColor),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton(
    bool isDarkMode,
    IconData icon,
    String tooltip, {
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color:
              isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(icon, color: isDarkMode ? Colors.white70 : Colors.black54),
          onPressed: onPressed,
          padding: const EdgeInsets.all(12),
          iconSize: 22,
        ),
      ),
    );
  }

  Widget _buildWithBottomNav(bool isDarkMode, Color accentColor) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration:
          isDarkMode
              ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF121117), Color(0xFF1A1A24)],
                ),
              )
              : const BoxDecoration(color: Colors.white),
      child: SafeArea(
        bottom: false,
        child: _buildMainContent(isDarkMode, accentColor),
      ),
    );
  }

  // Two-column layout for very large screens
  Widget _buildLargeScreenContent(bool isDarkMode, Color accentColor) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: accentColor));
    }

    if (_randomHabits.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left column - Card and progress
          Expanded(
            flex: 3,
            child: Card(
              color: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
              elevation: isDarkMode ? 0 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side:
                    isDarkMode
                        ? BorderSide(color: Colors.white.withOpacity(0.05))
                        : BorderSide.none,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daily Challenge',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        ProgressBar(
                          isDarkMode: isDarkMode,
                          currentIndex: _currentHabitIndex,
                          totalItems: _randomHabits.length,
                          onIndicatorTap: _onProgressIndicatorTap,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    // Swipeable habit card - larger size for desktop
                    // FIX: Removed fixed height to allow for flexible content size.
                    GestureDetector(
                      onHorizontalDragEnd: (details) {
                        if (details.primaryVelocity! > 0) {
                          _previousHabit();
                        } else if (details.primaryVelocity! < 0) {
                          _nextHabit();
                        }
                      },
                      child: HabitCard(
                        habit: _convertHabitToMap(
                          _randomHabits[_currentHabitIndex],
                        ),
                        isDarkMode: isDarkMode,
                        textColor: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const Spacer(),
                    // Navigation buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _navigationButton(
                          isDarkMode,
                          Icons.arrow_back_ios_new,
                          _previousHabit,
                        ),
                        const SizedBox(width: 16),
                        _navigationButton(
                          isDarkMode,
                          Icons.arrow_forward_ios,
                          _nextHabit,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _habitInfoWidget(isDarkMode),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 24),

          // Right column - Timer and controls
          Expanded(
            flex: 2,
            child: Card(
              color: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
              elevation: isDarkMode ? 0 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side:
                    isDarkMode
                        ? BorderSide(color: Colors.white.withOpacity(0.05))
                        : BorderSide.none,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center content vertically
                  children: [
                    Text(
                      'Focus Timer',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),
                    TimerCircle(
                      habit: _convertHabitToMap(
                        _randomHabits[_currentHabitIndex],
                      ),
                      isDarkMode: isDarkMode,
                      isCountdownActive: _isCountdownActive,
                      animation: _animation,
                    ),
                    const SizedBox(height: 36),
                    _buildDesktopActionButton(
                      'Open Timer',
                      Icons.timer,
                      isDarkMode,
                      () {
                        NavigationService.navigateTo(
                          context,
                          '/timer',
                          arguments: {
                            'habitId': _randomHabits[_currentHabitIndex].id,
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navigationButton(
    bool isDarkMode,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: isDarkMode ? Colors.white70 : Colors.black54),
        onPressed: onPressed,
      ),
    );
  }

  Widget _habitInfoWidget(bool isDarkMode) {
    if (_randomHabits.isEmpty) return const SizedBox.shrink();

    final habit = _randomHabits[_currentHabitIndex];

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              const SizedBox(width: 8),
              Text(
                'Habit Details',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow(
            'Focus Time',
            '${habit.focusTimeMinutes} minutes',
            isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value,
    bool isDarkMode, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: isDarkMode ? Colors.white54 : Colors.black54,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? (isDarkMode ? Colors.white : Colors.black87),
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // FIX: This method is now used for the centered medium-screen layout.
  // It ensures the content is scrollable.
  Widget _buildMediumScreenContent(bool isDarkMode, Color accentColor) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: accentColor));
    }

    if (_randomHabits.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Card(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          color: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
          elevation: isDarkMode ? 0 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side:
                isDarkMode
                    ? BorderSide(color: Colors.white.withOpacity(0.05))
                    : BorderSide.none,
          ),
          child: _buildMainContent(isDarkMode, accentColor, isCardLayout: true),
        ),
      ),
    );
  }

  // FIX: Refactored to use SingleChildScrollView and handle both mobile and card layouts.
  Widget _buildMainContent(
    bool isDarkMode,
    Color accentColor, {
    bool isCardLayout = false,
  }) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: accentColor));
    }

    if (_randomHabits.isEmpty) {
      return _buildEmptyState(isDarkMode);
    }

    // Set padding based on whether it's in a card or full screen.
    final double horizontalPadding = isCardLayout ? 24.0 : 20.0;
    final double topPadding = isCardLayout ? 24.0 : 10.0;
    final double bottomPadding =
        isCardLayout ? 24.0 : (MediaQuery.of(context).padding.bottom + 90.0);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        topPadding,
        horizontalPadding,
        bottomPadding,
      ),
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
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity! > 0)
                _previousHabit();
              else if (details.primaryVelocity! < 0)
                _nextHabit();
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
          const SizedBox(height: 40), // Spacing before buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 140),
                  child: ActionButton(
                    icon: Icons.swipe,
                    label: 'Next',
                    color: ColorUtils.getPriorityColor(
                      _randomHabits[_currentHabitIndex].priority,
                    ),
                    isDarkMode: isDarkMode,
                    onPressed: _nextHabit,
                    isOutlined: true,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: ActionButton(
                    icon: Icons.timer,
                    label: 'Open Timer',
                    color: ColorUtils.getPriorityColor(
                      _randomHabits[_currentHabitIndex].priority,
                    ),
                    isDarkMode: isDarkMode,
                    onPressed: () {
                      NavigationService.navigateTo(
                        context,
                        '/timer',
                        arguments: {
                          'habitId': _randomHabits[_currentHabitIndex].id,
                        },
                      );
                    },
                    isOutlined: false,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      // Make sure empty state is also centered
      child: EmptyStateWidget(
        title: 'No habits found',
        message: 'Create habits to start your random challenges',
        lottieAsset: 'assets/lottie/empty_state.json',
        actionLabel: 'Add New Habit',
        onActionPressed:
            () => NavigationService.navigateTo(context, '/add_habit'),
      ),
    );
  }

  Widget _buildDesktopActionButton(
    String label,
    IconData icon,
    bool isDarkMode,
    VoidCallback onPressed,
  ) {
    return Center(
      child: Container(
        width: 200, // Fixed width for desktop
        height: 48, // Smaller height than mobile
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4B6EFF), Color(0xFF3B5AF8)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4B6EFF).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 20, // Smaller icon
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14, // Smaller font
                      fontWeight: FontWeight.w600,
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
