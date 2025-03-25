import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import 'package:momentum/core/theme/app_theme.dart';
import '../services/navigation_service.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 2; // Set to 2 since this is the Overview tab
  late AnimationController _animController;

  // Sample data - would be fetched from your database in a real app
  final int totalHabits = 12;
  final int completedHabits = 8;
  final int streakDays = 15;
  final double completionRate = 0.67; // 67%

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
    // Handle navigation based on tab index
    if (index == 0) {
      NavigationService.navigateTo(context, '/home');
    } else if (index == 1) {
      NavigationService.navigateTo(context, '/random_habit');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.isDarkMode(context);
    final primaryColor = const Color(0xFF4B6EFF);
    final accentColor = const Color(0xFF6C4BFF);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryTextColor = isDarkMode ? Colors.white70 : Colors.black87;
    final cardColor = isDarkMode ? const Color(0xFF1A1A24) : Colors.white;

    return Scaffold(
      extendBody: true,
      backgroundColor: isDarkMode
          ? const Color(0xFF121117)
          : Colors.white,
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
      ),
      body: Container(
        decoration: isDarkMode
            ? const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF121117), // Dark gradient start
              Color(0xFF1A1A24), // Dark gradient end
            ],
          ),
        )
            : const BoxDecoration(color: Colors.white),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 90.0), // Increased bottom padding
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards Row
                Row(
                  children: [
                    _buildStatCard(
                      context,
                      'Habits',
                      '$completedHabits/$totalHabits',
                      Icons.check_circle_outline,
                      primaryColor,
                      cardColor,
                      textColor,
                      isDarkMode,
                      flex: 1,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      context,
                      'Current Streak',
                      '$streakDays days',
                      Icons.local_fire_department,
                      accentColor,
                      cardColor,
                      textColor,
                      isDarkMode,
                      flex: 1,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Progress Circle
                _buildProgressSection(
                  context,
                  isDarkMode,
                  textColor,
                  secondaryTextColor,
                  primaryColor,
                ),
                const SizedBox(height: 24),

                // Weekly Performance
                Text(
                  'Weekly Performance',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Weekly Chart
                _buildWeeklyChart(
                  context,
                  isDarkMode,
                  primaryColor,
                  secondaryTextColor,
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

  Widget _buildStatCard(
      BuildContext context,
      String title,
      String value,
      IconData icon,
      Color iconColor,
      Color cardColor,
      Color textColor,
      bool isDarkMode, {
        int flex = 1,
      }) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF222232),
              Color(0xFF1A1A28),
            ],
          )
              : null,
          color: isDarkMode ? null : cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: isDarkMode
              ? Border.all(color: Colors.white.withOpacity(0.03))
              : Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(
      BuildContext context,
      bool isDarkMode,
      Color textColor,
      Color secondaryTextColor,
      Color primaryColor,
      ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF222232),
            Color(0xFF1A1A28),
          ],
        )
            : null,
        color: isDarkMode ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isDarkMode
            ? Border.all(color: Colors.white.withOpacity(0.03))
            : Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Text(
            'Habit Completion Rate',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: completionRate),
                    duration: const Duration(milliseconds: 1500),
                    builder: (context, value, _) {
                      return Stack(
                        children: [
                          SizedBox(
                            width: 120,
                            height: 120,
                            child: CircularProgressIndicator(
                              value: value,
                              strokeWidth: 10,
                              backgroundColor: isDarkMode
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                            ),
                          ),
                          Center(
                            child: Text(
                              '${(value * 100).toInt()}%',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(
                    'Completed',
                    '$completedHabits habits',
                    primaryColor,
                    textColor,
                    secondaryTextColor,
                  ),
                  const SizedBox(height: 16),
                  _buildLegendItem(
                    'Remaining',
                    '${totalHabits - completedHabits} habits',
                    isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                    textColor,
                    secondaryTextColor,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
      String title,
      String value,
      Color dotColor,
      Color textColor,
      Color secondaryTextColor,
      ) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: dotColor.withOpacity(0.4),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeeklyChart(
      BuildContext context,
      bool isDarkMode,
      Color primaryColor,
      Color secondaryTextColor,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF222232),
            Color(0xFF1A1A28),
          ],
        )
            : null,
        color: isDarkMode ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isDarkMode
            ? Border.all(color: Colors.white.withOpacity(0.03))
            : Border.all(color: Colors.grey.shade100),
      ),
      height: 220, // Increased height to prevent overflow
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: weeklyData.asMap().entries.map((entry) {
          final int index = entry.key;
          final day = entry.value;
          final double completionPercentage = day['completed'] / day['total'];
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 600 + (index * 100)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min, // Prevents overflow
                children: [
                  Text(
                    '${day['completed']}/${day['total']}',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 30,
                    height: 100 * completionPercentage * value, // Reduced height slightly
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          primaryColor,
                          primaryColor.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.black.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      day['day'],
                      style: TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }).toList(),
      ),
    );
  }
}