import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import 'package:momentum/core/theme/app_theme.dart';
import '../services/navigation_service.dart';
import '../widgets/overview/stat_card.dart';
import '../widgets/overview/progress_section.dart';
import '../widgets/overview/weekly_chart.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 2;
  late AnimationController _animController;

  // Sample data
  final int totalHabits = 12;
  final int completedHabits = 8;
  final int streakDays = 15;
  final double completionRate = 0.67;

  // Enhanced color palette
  late Color primaryColor;
  late Color accentColor;
  late Color successColor;
  late Color warningColor;
  late Color dangerColor;
  late Color neutralColor;

  // Sample weekly data for chart
  final List<Map<String, dynamic>> weeklyData = [
    {'day': 'Mon', 'completed': 3, 'total': 4},
    {'day': 'Tue', 'completed': 4, 'total': 4},
    {'day': 'Wed', 'completed': 2, 'total': 4},
    {'day': 'Thu', 'completed': 3, 'total': 4},
    {'day': 'Fri', 'completed': 1, 'total': 4},
    {'day': 'Sat', 'completed': 4, 'total': 5},
    {'day': 'Sun', 'completed': 3, 'total': 5},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 90.0),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced Summary Cards Row
                Row(
                  children: [
                    StatCard(
                      title: 'Habits',
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
                      value: '$streakDays days',
                      icon: Icons.local_fire_department,
                      iconColor: accentColor,
                      cardColor: cardColor,
                      textColor: textColor,
                      isDarkMode: isDarkMode,
                      iconGradient: RadialGradient(
                        colors: [
                          Colors.orange.withOpacity(0.7),
                          accentColor.withOpacity(0.3)
                        ],
                        center: Alignment.center,
                        radius: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Progress Circle with enhanced colors
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

                // Weekly Performance section
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
                          colors: [primaryColor, accentColor],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '71% weekly',
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

                // Weekly Chart with enhanced colors
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
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}