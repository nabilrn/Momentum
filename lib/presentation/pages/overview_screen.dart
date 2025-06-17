import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/sidebar_navigation.dart';
import 'package:momentum/core/theme/app_theme.dart';
import '../services/navigation_service.dart';
import '../widgets/overview/stat_card.dart';
import '../widgets/overview/progress_section.dart';
import '../widgets/overview/weekly_chart.dart';
import '../controllers/habit_controller.dart';
import '../widgets/common/empty_state_widget.dart';
import '../utils/platform_helper.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 2;
  late AnimationController _animController;

  // Enhanced color palette
  late Color primaryColor;
  late Color accentColor;
  late Color successColor;
  late Color warningColor;
  late Color dangerColor;
  late Color neutralColor;

  // Responsive breakpoints
  static const double _breakpoint = 768;
  static const double _largeScreenBreakpoint = 1200;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    // Load habits with completions when the screen is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final habitController = Provider.of<HabitController>(
        context,
        listen: false,
      );
      habitController.loadHabitsWithCompletions();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    final routes = {
      0: '/home',
      1: '/random_habit',
      3: '/settings',
      4: '/account',
    };

    if (routes.containsKey(index)) {
      NavigationService.navigateTo(context, routes[index]!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Initialize color palette
    primaryColor = const Color(0xFF4B6EFF);
    accentColor = const Color(0xFF6C4BFF);
    successColor = const Color(0xFF4CAF50);
    warningColor = const Color(0xFFFFC107);
    dangerColor = const Color(0xFFF44336);
    neutralColor = isDarkMode ? Colors.white70 : Colors.black54;

    // Responsive layout decision
    final usesSidebar = screenWidth > _breakpoint;
    final isLargeScreen = screenWidth > _largeScreenBreakpoint;

    return Scaffold(
      extendBody: !usesSidebar,
      backgroundColor: isDarkMode ? const Color(0xFF121117) : Colors.white,
      appBar: usesSidebar ? null : AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Habits Overview',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.calendar_month, color: accentColor),
              onPressed: () {},
              tooltip: 'Calendar View',
            ),
          ),
        ],
      ),
      body: usesSidebar
          ? _buildWithSidebar(isDarkMode, isLargeScreen)
          : _buildWithBottomNav(isDarkMode),
      bottomNavigationBar: usesSidebar
          ? null
          : BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildWithSidebar(bool isDarkMode, bool isLargeScreen) {
    return Row(
      children: [
        // Sidebar navigation
        SidebarNavigation(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),

        // Main content
        Expanded(
          child: Container(
            decoration: isDarkMode
                ? const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF121117), Color(0xFF1A1A24)],
              ),
            )
                : BoxDecoration(
              color: isDarkMode ? Colors.black : const Color(0xFFF8F9FA),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Custom app bar for sidebar layout
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Habits Overview',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          _actionButton(
                            isDarkMode,
                            Icons.date_range,
                            'Date Range',
                            onPressed: () {},
                          ),
                          const SizedBox(width: 12),
                          _actionButton(
                            isDarkMode,
                            Icons.calendar_month,
                            'Calendar View',
                            onPressed: () {},
                          ),
                          const SizedBox(width: 12),
                          _actionButton(
                            isDarkMode,
                            Icons.download,
                            'Export Data',
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main content area with different layouts based on screen size
                Expanded(
                  child: isLargeScreen
                      ? _buildLargeScreenLayout(isDarkMode)
                      : _buildMediumScreenLayout(isDarkMode),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton(bool isDarkMode, IconData icon, String tooltip, {required VoidCallback onPressed}) {
    return Tooltip(
      message: tooltip,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode
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

  Widget _buildLargeScreenLayout(bool isDarkMode) {
    return Consumer<HabitController>(
      builder: (context, habitController, child) {
        if (habitController.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          );
        }

        if (habitController.error != null) {
          return _buildErrorState(isDarkMode, habitController);
        }

        final habits = habitController.habits;
        if (habits.isEmpty) {
          return _buildEmptyState(isDarkMode);
        }

        // Two column layout for large screens
        return Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0), // Adjust padding
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column - Stats and Progress
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // Stats summary card
                    _buildStatsCard(isDarkMode, habitController),
                    const SizedBox(height: 24),
                    // Progress section
                    _buildProgressCard(isDarkMode, habitController),
                  ],
                ),
              ),

              const SizedBox(width: 24),

              // Right column - Weekly Performance
              Expanded(
                flex: 4,
                child: _buildWeeklyCard(isDarkMode, habitController),
              ),
            ],
          ),
        );
      },
    );
  }

  // FIX: Wrapped the Column in a SingleChildScrollView to prevent overflow.
  Widget _buildMediumScreenLayout(bool isDarkMode) {
    return Consumer<HabitController>(
      builder: (context, habitController, child) {
        if (habitController.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          );
        }

        if (habitController.error != null) {
          return _buildErrorState(isDarkMode, habitController);
        }

        if (habitController.habits.isEmpty) {
          return _buildEmptyState(isDarkMode);
        }

        // Centered card layout for medium screens
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  children: [
                    _buildStatsCard(isDarkMode, habitController),
                    const SizedBox(height: 24),
                    _buildProgressCard(isDarkMode, habitController),
                    const SizedBox(height: 24),
                    _buildWeeklyCard(isDarkMode, habitController),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWithBottomNav(bool isDarkMode) {
    return Container(
      decoration: isDarkMode
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
        child: _buildMobileContent(isDarkMode),
      ),
    );
  }

  Widget _buildMobileContent(bool isDarkMode) {
    return Consumer<HabitController>(
      builder: (context, habitController, child) {
        if (habitController.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          );
        }

        if (habitController.error != null) {
          return _buildErrorState(isDarkMode, habitController);
        }

        final habits = habitController.habits;
        if (habits.isEmpty) {
          return _buildEmptyState(isDarkMode);
        }

        final textColor = isDarkMode ? Colors.white : Colors.black;
        final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black87;
        final cardColor = isDarkMode ? const Color(0xFF1A1A24) : Colors.white;

        // Mobile view content from original implementation
        final completedHabits = habitController.getTotalCompletionsForDate(DateTime.now());
        final totalHabits = habits.length;
        final streakDays = habitController.calculateCurrentStreak();
        final completionRate = habitController.getTodayCompletionRate();
        final weeklyData = habitController.getWeeklyData();
        final weeklyAvg = habitController.getWeeklyCompletionRate();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 90.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 400;
                  return isNarrow
                      ? Column(
                    children: [
                      _buildStatCard(
                          'Today\'s Habits',
                          '$completedHabits/$totalHabits',
                          Icons.check_circle_outline,
                          primaryColor,
                          cardColor,
                          textColor,
                          isDarkMode
                      ),
                      const SizedBox(height: 16),
                      _buildStatCard(
                          'Current Streak',
                          '$streakDays day${streakDays != 1 ? 's' : ''}',
                          Icons.local_fire_department,
                          streakDays > 0 ? Colors.orange : neutralColor,
                          cardColor,
                          textColor,
                          isDarkMode
                      ),
                    ],
                  )
                      : Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                            'Today\'s Habits',
                            '$completedHabits/$totalHabits',
                            Icons.check_circle_outline,
                            primaryColor,
                            cardColor,
                            textColor,
                            isDarkMode
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                            'Current Streak',
                            '$streakDays day${streakDays != 1 ? 's' : ''}',
                            Icons.local_fire_department,
                            streakDays > 0 ? Colors.orange : neutralColor,
                            cardColor,
                            textColor,
                            isDarkMode
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Progress Circle
              ProgressSection(
                isDarkMode: isDarkMode,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
                primaryColor: primaryColor,
                accentColor: accentColor,
                completedHabits: completedHabits,
                totalHabits: totalHabits,
                completionRate: completionRate,
              ),
              const SizedBox(height: 24),

              // Weekly Performance header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weekly Performance',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: weeklyAvg > 0.7
                            ? [successColor, successColor.withOpacity(0.8)]
                            : weeklyAvg > 0.4
                            ? [warningColor, warningColor.withOpacity(0.8)]
                            : [dangerColor, dangerColor.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(weeklyAvg * 100).round()}% weekly',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Weekly Chart
              WeeklyChart(
                isDarkMode: isDarkMode,
                primaryColor: primaryColor,
                secondaryTextColor: secondaryTextColor,
                weeklyData: weeklyData,
              ),
            ],
          ),
        );
      },
    );
  }

  // Desktop-specific cards
  Widget _buildStatsCard(bool isDarkMode, HabitController habitController) {
    final cardColor = isDarkMode ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    final completedHabits = habitController.getTotalCompletionsForDate(DateTime.now());
    final totalHabits = habitController.habits.length;
    final streakDays = habitController.calculateCurrentStreak();
    final weeklyAvg = habitController.getWeeklyCompletionRate();

    return Card(
      color: cardColor,
      elevation: isDarkMode ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDarkMode
            ? BorderSide(color: Colors.white.withOpacity(0.05))
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Summary Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatInfo(
                    isDarkMode,
                    'Today\'s Completed',
                    '$completedHabits/$totalHabits',
                    Icons.check_circle_outline,
                    primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatInfo(
                    isDarkMode,
                    'Current Streak',
                    '$streakDays day${streakDays != 1 ? 's' : ''}',
                    Icons.local_fire_department,
                    streakDays > 0 ? Colors.orange : neutralColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatInfo(
                    isDarkMode,
                    'Weekly Average',
                    '${(weeklyAvg * 100).round()}%',
                    Icons.insights,
                    weeklyAvg > 0.7 ? successColor :
                    weeklyAvg > 0.4 ? warningColor : dangerColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatInfo(
      bool isDarkMode,
      String title,
      String value,
      IconData icon,
      Color iconColor
      ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.white.withOpacity(0.05)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black54,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(bool isDarkMode, HabitController habitController) {
    final cardColor = isDarkMode ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black87;

    final completedHabits = habitController.getTotalCompletionsForDate(DateTime.now());
    final totalHabits = habitController.habits.length;
    final completionRate = habitController.getTodayCompletionRate();

    return Card(
      color: cardColor,
      elevation: isDarkMode ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDarkMode
            ? BorderSide(color: Colors.white.withOpacity(0.05))
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 24),
            ProgressSection(
              isDarkMode: isDarkMode,
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
              primaryColor: primaryColor,
              accentColor: accentColor,
              completedHabits: completedHabits,
              totalHabits: totalHabits,
              completionRate: completionRate,
              // Removed isDesktop parameter
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyCard(bool isDarkMode, HabitController habitController) {
    final cardColor = isDarkMode ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black87;

    final weeklyData = habitController.getWeeklyData();
    final weeklyAvg = habitController.getWeeklyCompletionRate();

    return Card(
      color: cardColor,
      elevation: isDarkMode ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDarkMode
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
                  'Weekly Performance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                // Additional content remains the same
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: WeeklyChart(
                isDarkMode: isDarkMode,
                primaryColor: primaryColor,
                secondaryTextColor: secondaryTextColor,
                weeklyData: weeklyData,
                // Removed isDesktop parameter
              ),
            ),
            if (weeklyAvg > 0) ...[
              const SizedBox(height: 20),
              _buildWeeklyInsight(isDarkMode, weeklyAvg),
            ],
          ],
        ),
      ),
    );
  }
  Widget _buildWeeklyInsight(bool isDarkMode, double weeklyAvg) {
    String message;
    IconData icon;
    Color color;

    if (weeklyAvg > 0.85) {
      message = "Excellent work! You're consistently completing your habits.";
      icon = Icons.emoji_events;
      color = successColor;
    } else if (weeklyAvg > 0.7) {
      message = "Great job! You're maintaining good consistency.";
      icon = Icons.thumb_up;
      color = successColor;
    } else if (weeklyAvg > 0.5) {
      message = "Good progress! Try to improve your consistency a bit more.";
      icon = Icons.trending_up;
      color = warningColor;
    } else {
      message = "You're making some progress. Focus on building more consistency.";
      icon = Icons.notifications_active;
      color = dangerColor;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDarkMode, HabitController habitController) {
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: dangerColor, size: 48),
          const SizedBox(height: 16),
          Text(
            'Failed to load habits',
            style: TextStyle(color: textColor, fontSize: 18),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => habitController.loadHabitsWithCompletions(),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: EmptyStateWidget(
        title: 'No habits yet',
        message: 'Add habits to see your progress',
        lottieAsset: 'assets/lottie/empty_state.json',
        actionLabel: 'Add Your First Habit',
        onActionPressed: () {
          NavigationService.navigateTo(context, '/add_habit');
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color iconColor,
      Color cardColor, Color textColor, bool isDarkMode) {
    return StatCard(
      title: title,
      value: value,
      icon: icon,
      iconColor: iconColor,
      cardColor: cardColor,
      textColor: textColor,
      isDarkMode: isDarkMode,
      iconGradient: RadialGradient(
        colors: [
          iconColor.withOpacity(0.7),
          iconColor.withOpacity(0.2),
        ],
        center: Alignment.center,
        radius: 0.8,
      ),
    );
  }
}