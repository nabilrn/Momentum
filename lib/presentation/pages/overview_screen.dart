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
  int _currentIndex = 3; // Overview is index 3 in bottom navigation
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

    // Check if we're using sidebar or bottom navigation
    final screenWidth = MediaQuery.of(context).size.width;
    final usesSidebar = PlatformHelper.isDesktop || kIsWeb || screenWidth > 768;

    if (usesSidebar) {
      // Handle sidebar navigation (different indices)
      switch (index) {
        case 0:
          NavigationService.navigateTo(context, '/home');
          break;
        case 1:
          NavigationService.navigateTo(context, '/random_habit');
          break;
        case 2:
          // This is overview in sidebar, stay here
          break;
        case 3:
          NavigationService.navigateTo(context, '/settings');
          break;
        case 4:
          NavigationService.navigateTo(context, '/account');
          break;
        case 5:
          NavigationService.navigateTo(context, '/priority');
          break;
      }
    } else {
      // Handle bottom navigation
      switch (index) {
        case 0:
          NavigationService.navigateTo(context, '/home');
          break;
        case 1:
          NavigationService.navigateTo(context, '/random_habit');
          break;
        case 2:
          NavigationService.navigateTo(context, '/priority');
          break;
        case 3:
          // This is overview in bottom nav, stay here
          break;
      }
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
      body:
          usesSidebar
              ? _buildDesktopLayout(
                isDarkMode,
                textColor,
                secondaryTextColor,
                cardColor,
              )
              : _buildMobileLayout(
                isDarkMode,
                textColor,
                secondaryTextColor,
                cardColor,
              ),
      bottomNavigationBar:
          usesSidebar
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

  Widget _buildDesktopLayout(
    bool isDarkMode,
    Color textColor,
    Color secondaryTextColor,
    Color cardColor,
  ) {
    return Row(
      children: [
        SidebarNavigation(
          currentIndex: 2, // Overview is index 2 in sidebar navigation
          onTap: (index) {
            // Map sidebar indices correctly
            if (index == 2) {
              // Stay on overview
              setState(() {
                _currentIndex = 3; // Bottom nav index for overview
              });
            } else {
              _onTabTapped(index);
            }
          },
        ),
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
              children: [
                // Custom header section
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Habits Overview',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          _buildActionButton(
                            isDarkMode,
                            Icons.refresh,
                            'Refresh',
                            onPressed: () {
                              final habitController =
                                  Provider.of<HabitController>(
                                    context,
                                    listen: false,
                                  );
                              habitController.loadHabitsWithCompletions();
                            },
                          ),
                          const SizedBox(width: 16),
                          _buildActionButton(
                            isDarkMode,
                            Icons.calendar_month,
                            'Calendar View',
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildMainContent(
                    isDarkMode,
                    textColor,
                    secondaryTextColor,
                    cardColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    bool isDarkMode,
    Color textColor,
    Color secondaryTextColor,
    Color cardColor,
  ) {
    return _buildMainContent(
      isDarkMode,
      textColor,
      secondaryTextColor,
      cardColor,
    );
  }

  Widget _buildMainContent(
    bool isDarkMode,
    Color textColor,
    Color secondaryTextColor,
    Color cardColor,
  ) {
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
        final int completedHabits = habitController.getTotalCompletionsForDate(
          DateTime.now(),
        );
        final int streakDays = habitController.calculateCurrentStreak();
        final double completionRate = habitController.getTodayCompletionRate();
        final List<Map<String, dynamic>> weeklyData =
            habitController.getWeeklyData();
        final double weeklyAvg = habitController.getWeeklyCompletionRate();

        return Container(
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
            child:
                totalHabits == 0
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
                    : _buildOverviewContent(
                      isDarkMode,
                      textColor,
                      secondaryTextColor,
                      cardColor,
                      totalHabits,
                      completedHabits,
                      streakDays,
                      completionRate,
                      weeklyData,
                      weeklyAvg,
                    ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
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

  Widget _buildOverviewContent(
    bool isDarkMode,
    Color textColor,
    Color secondaryTextColor,
    Color cardColor,
    int totalHabits,
    int completedHabits,
    int streakDays,
    double completionRate,
    List<Map<String, dynamic>> weeklyData,
    double weeklyAvg,
  ) {
    final bool isDesktop = MediaQuery.of(context).size.width > 768;

    if (isDesktop) {
      // Desktop layout with better spacing and cards
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column - Stats and Progress
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
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
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: 'Current Streak',
                          value: '$streakDays day${streakDays != 1 ? 's' : ''}',
                          icon: Icons.local_fire_department,
                          iconColor:
                              streakDays > 0 ? Colors.orange : neutralColor,
                          cardColor: cardColor,
                          textColor: textColor,
                          isDarkMode: isDarkMode,
                          iconGradient: RadialGradient(
                            colors:
                                streakDays > 0
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Progress Section
                  Card(
                    color: cardColor,
                    elevation: isDarkMode ? 0 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side:
                          isDarkMode
                              ? BorderSide(
                                color: Colors.white.withOpacity(0.05),
                              )
                              : BorderSide.none,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: ProgressSection(
                        isDarkMode: isDarkMode,
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        primaryColor: primaryColor,
                        accentColor: accentColor,
                        completedHabits: completedHabits,
                        totalHabits: totalHabits,
                        completionRate: completionRate,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 24),

            // Right column - Weekly Chart
            Expanded(
              flex: 3,
              child: Card(
                color: cardColor,
                elevation: isDarkMode ? 0 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side:
                      isDarkMode
                          ? BorderSide(color: Colors.white.withOpacity(0.05))
                          : BorderSide.none,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Weekly Performance',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  weeklyAvg >= 70
                                      ? successColor.withOpacity(0.2)
                                      : weeklyAvg >= 50
                                      ? warningColor.withOpacity(0.2)
                                      : dangerColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${weeklyAvg.toStringAsFixed(1)}% weekly',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color:
                                    weeklyAvg >= 70
                                        ? successColor
                                        : weeklyAvg >= 50
                                        ? warningColor
                                        : dangerColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: WeeklyChart(
                          isDarkMode: isDarkMode,
                          primaryColor: primaryColor,
                          secondaryTextColor: secondaryTextColor,
                          weeklyData: weeklyData,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile layout (original)
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 90.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards Row
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
                  value: '$streakDays day${streakDays != 1 ? 's' : ''}',
                  icon: Icons.local_fire_department,
                  iconColor: streakDays > 0 ? Colors.orange : neutralColor,
                  cardColor: cardColor,
                  textColor: textColor,
                  isDarkMode: isDarkMode,
                  iconGradient: RadialGradient(
                    colors:
                        streakDays > 0
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

            // Progress Section
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

            // Weekly Performance Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Weekly Performance',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        weeklyAvg >= 70
                            ? successColor.withOpacity(0.2)
                            : weeklyAvg >= 50
                            ? warningColor.withOpacity(0.2)
                            : dangerColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${weeklyAvg.toStringAsFixed(1)}% weekly',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          weeklyAvg >= 70
                              ? successColor
                              : weeklyAvg >= 50
                              ? warningColor
                              : dangerColor,
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
    }
  }
}
