import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/bottom_navigation.dart';
import 'package:momentum/core/theme/app_theme.dart';
import '../services/navigation_service.dart';
import '../widgets/overview/stat_card.dart';
import '../widgets/overview/progress_section.dart';
import '../widgets/overview/weekly_chart.dart';
import '../controllers/habit_controller.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> with SingleTickerProviderStateMixin {
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
      final habitController = Provider.of<HabitController>(context, listen: false);
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
      extendBody: true,
      backgroundColor: isDarkMode ? const Color(0xFF121117) : Colors.white,
      appBar: AppBar(
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
      ),
      body: Consumer<HabitController>(
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
          final int completedHabits = habitController.getTotalCompletionsForDate(DateTime.now());
          final int streakDays = habitController.calculateCurrentStreak();
          final double completionRate = habitController.getTodayCompletionRate();
          final List<Map<String, dynamic>> weeklyData = habitController.getWeeklyData();
          final double weeklyAvg = habitController.getWeeklyCompletionRate();

          return Container(
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
              child: totalHabits == 0
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_task,
                      color: primaryColor.withOpacity(0.6),
                      size: 80,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No habits yet',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add habits to see your progress',
                      style: TextStyle(color: secondaryTextColor, fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        NavigationService.navigateTo(context, '/add_habit');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add Your First Habit',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              )
                  : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 90.0),
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
                            colors: [primaryColor.withOpacity(0.7), primaryColor.withOpacity(0.2)],
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
                            colors: streakDays > 0
                                ? [Colors.orange.withOpacity(0.7), accentColor.withOpacity(0.3)]
                                : [neutralColor.withOpacity(0.3), neutralColor.withOpacity(0.1)],
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
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

                    // Weekly Chart with real data
                    WeeklyChart(
                      isDarkMode: isDarkMode,
                      primaryColor: primaryColor,
                      secondaryTextColor: secondaryTextColor,
                      weeklyData: weeklyData,
                    ),

                    // Additional stats section
                    if (totalHabits > 0) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isDarkMode
                              ? []
                              : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Stats',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildQuickStat(
                                  'Total Habits',
                                  totalHabits.toString(),
                                  Icons.list_alt,
                                  textColor,
                                  secondaryTextColor,
                                ),
                                _buildQuickStat(
                                  'This Week',
                                  '${weeklyData.fold<int>(0, (sum, day) => sum + (day['completed'] as int))}/${weeklyData.fold<int>(0, (sum, day) => sum + (day['total'] as int))}',
                                  Icons.date_range,
                                  textColor,
                                  secondaryTextColor,
                                ),
                                _buildQuickStat(
                                  'Best Day',
                                  _getBestDayOfWeek(weeklyData),
                                  Icons.star,
                                  textColor,
                                  secondaryTextColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildQuickStat(String title, String value, IconData icon, Color textColor, Color secondaryTextColor) {
    return Column(
      children: [
        Icon(icon, color: primaryColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _getBestDayOfWeek(List<Map<String, dynamic>> weeklyData) {
    if (weeklyData.isEmpty) return '-';

    final bestDay = weeklyData.reduce((current, next) {
      final currentRate = (current['total'] as int) > 0
          ? (current['completed'] as int) / (current['total'] as int)
          : 0.0;
      final nextRate = (next['total'] as int) > 0
          ? (next['completed'] as int) / (next['total'] as int)
          : 0.0;
      return currentRate >= nextRate ? current : next;
    });

    final completionRate = (bestDay['total'] as int) > 0
        ? (bestDay['completed'] as int) / (bestDay['total'] as int)
        : 0.0;

    return completionRate > 0 ? bestDay['day'] as String : '-';
  }
}