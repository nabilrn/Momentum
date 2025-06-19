import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../widgets/bottom_navigation.dart';
import 'package:momentum/core/theme/app_theme.dart';
import '../services/navigation_service.dart';
import '../widgets/overview/stat_card.dart';
import '../widgets/overview/progress_section.dart';
import '../widgets/overview/weekly_chart.dart';
import '../controllers/habit_controller.dart';
import '../widgets/common/empty_state_widget.dart';
import '../utils/platform_helper.dart';
import 'package:momentum/presentation/widgets/sidebar_navigation.dart';

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
    if (index == 0) {
      NavigationService.navigateTo(context, '/home');
    } else if (index == 1) {
      NavigationService.navigateTo(context, '/random_habit');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;

    // Use PlatformHelper to determine layout for desktop or web
    final usesSidebar = PlatformHelper.isDesktop || kIsWeb || screenWidth > 768;

    // Initialize color palette
    primaryColor = const Color(0xFF4B6EFF);
    accentColor = const Color(0xFF6C4BFF);
    successColor = const Color(0xFF4CAF50);
    warningColor = const Color(0xFFFFC107);
    dangerColor = const Color(0xFFF44336);
    neutralColor = isDarkMode ? Colors.white70 : Colors.black54;

    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final cardColor = isDarkMode ? const Color(0xFF1A1A24) : Colors.white;

    return Scaffold(
      extendBody: !usesSidebar,
      backgroundColor: isDarkMode ? const Color(0xFF121117) : Colors.white,
      appBar: usesSidebar ? null : _buildAppBar(textColor, accentColor),
      body: usesSidebar
          ? _buildDesktopLayout(
          isDarkMode, textColor, secondaryTextColor, cardColor)
          : _buildMobileLayout(
          isDarkMode, textColor, secondaryTextColor, cardColor),
      bottomNavigationBar: usesSidebar
          ? null
          : BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color textColor, Color accentColor) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Habits Overview',
        style: TextStyle(
          color: textColor,
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
    );
  }

  Widget _buildDesktopLayout(bool isDarkMode, Color textColor,
      Color secondaryTextColor, Color cardColor) {
    return Row(
      children: [
        SidebarNavigation(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
        Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Habits Overview',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
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
              ),
              Expanded(
                child: _buildMainContent(
                    isDarkMode, textColor, secondaryTextColor, cardColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(bool isDarkMode, Color textColor,
      Color secondaryTextColor, Color cardColor) {
    return _buildMainContent(isDarkMode, textColor, secondaryTextColor, cardColor);
  }

  Widget _buildMainContent(bool isDarkMode, Color textColor,
      Color secondaryTextColor, Color cardColor) {
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
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final habits = habitController.habits;
        final totalHabits = habits.length;

        // Use real data from HabitController
        final int completedHabits =
        habitController.getTotalCompletionsForDate(DateTime.now());
        final int streakDays = habitController.calculateCurrentStreak();
        final double completionRate = habitController.getTodayCompletionRate();
        final List<Map<String, dynamic>> weeklyData =
        habitController.getWeeklyData();
        final double weeklyAvg = habitController.getWeeklyCompletionRate();

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
            child: totalHabits == 0
                ? Center(
              child: EmptyStateWidget(
                title: 'No habits yet',
                message: 'Add habits to see your progress',
                lottieAsset: 'assets/lottie/empty_state.json',
                actionLabel: 'Add Your First Habit',
                onActionPressed: () {
                  NavigationService.navigateTo(context, '/add_habit');
                },
              ),
            )
                : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20.0,
                16.0,
                20.0,
                90.0,
              ),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced Summary Cards Row
                  Row(
                    children: [
                      StatCard(
                        title: 'Today\'s Habits',
                        value: '$completedHabits/$totalHabits',
                        icon: Icons.check_circle_outline,
                        iconColor: primaryColor,
                        cardColor: cardColor,
                        textColor: textColor,
                        isDarkMode: isDarkMode,
                        iconGradient: RadialGradient(
                          colors: [
                            primaryColor.withOpacity(0.7),
                            primaryColor.withOpacity(0.2),
                          ],
                          center: Alignment.center,
                          radius: 0.8,
                        ),
                      ),
                      const SizedBox(width: 16),
                      StatCard(
                        title: 'Current Streak',
                        value:
                        '$streakDays day${streakDays != 1 ? 's' : ''}',
                        icon: Icons.local_fire_department,
                        iconColor: streakDays > 0
                            ? Colors.orange
                            : neutralColor,
                        cardColor: cardColor,
                        textColor: textColor,
                        isDarkMode: isDarkMode,
                        iconGradient: RadialGradient(
                          colors: streakDays > 0
                              ? [
                            Colors.orange.withOpacity(0.7),
                            accentColor.withOpacity(0.3),
                          ]
                              : [
                            neutralColor.withOpacity(0.3),
                            neutralColor.withOpacity(0.1),
                          ],
                          center: Alignment.center,
                          radius: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Progress Circle with real completion rate
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

                  // Weekly Performance section with real data
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
                                ? [
                              successColor,
                              successColor.withOpacity(0.8),
                            ]
                                : weeklyAvg > 0.4
                                ? [
                              warningColor,
                              warningColor.withOpacity(0.8),
                            ]
                                : [
                              dangerColor,
                              dangerColor.withOpacity(0.8),
                            ],
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

                  // Weekly Chart with real data
                  WeeklyChart(
                    isDarkMode: isDarkMode,
                    primaryColor: primaryColor,
                    secondaryTextColor: secondaryTextColor,
                    weeklyData: weeklyData,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}