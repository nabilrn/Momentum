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

  // Get color based on completion percentage
  Color _getCompletionColor(double percentage) {
    if (percentage >= 0.7) return successColor;
    if (percentage >= 0.4) return warningColor;
    return dangerColor;
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
        // Added colorful action buttons
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
                      // Added radial gradient to icon background
                      iconGradient: RadialGradient(
                        colors: [primaryColor.withOpacity(0.7), primaryColor.withOpacity(0.2)],
                        center: Alignment.center,
                        radius: 0.8,
                      ),
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
                      // Added fire-like gradient to icon background
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
                _buildProgressSection(
                  context,
                  isDarkMode,
                  textColor,
                  secondaryTextColor,
                  primaryColor,
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
                    // Added colored tag for weekly progress
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
        Gradient? iconGradient,
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
              color: iconColor.withOpacity(0.1),
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
                // Enhanced icon container with gradient
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: iconGradient,
                    color: iconGradient == null ? iconColor.withOpacity(0.1) : null,
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
    // Determine color based on completion rate
    final completionColor = _getCompletionColor(completionRate);

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
            color: completionColor.withOpacity(0.1),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Added colored icon before the title
              Icon(
                Icons.insights_rounded,
                color: completionColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Habit Completion Rate',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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
                        // Added multiple progress indicators with different colors
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: value,
                            strokeWidth: 10,
                            backgroundColor: isDarkMode
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(completionColor),
                          ),
                        ),
                        // Inner progress indicator with gradient stroke
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: CircularProgressIndicator(
                              value: value * 0.8, // Slightly less progress
                              strokeWidth: 5,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                accentColor.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(value * 100).toInt()}%',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // Added small colored label under percentage
                              Text(
                                value > 0.6 ? 'Good' : 'Keep going',
                                style: TextStyle(
                                  color: completionColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(
                    'Completed',
                    '$completedHabits habits',
                    successColor,
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
        // Enhanced legend dot with inner shadow
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
          child: Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
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
      height: 220,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: weeklyData.asMap().entries.map((entry) {
          final int index = entry.key;
          final day = entry.value;
          final double completionPercentage = day['completed'] / day['total'];

          // Determine bar color based on completion percentage
          final Color barColor = _getCompletionColor(completionPercentage);

          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 600 + (index * 100)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Enhanced ratio display with color
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: barColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${day['completed']}/${day['total']}',
                      style: TextStyle(
                        color: barColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Enhanced bar with gradient
                  Container(
                    width: 30,
                    height: 100 * completionPercentage * value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          barColor,
                          barColor.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: barColor.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    // Added small icon inside the bar
                    child: completionPercentage >= 0.8 ?
                    Center(
                      child: Icon(
                        Icons.star,
                        color: Colors.white.withOpacity(0.7),
                        size: 12,
                      ),
                    ) : null,
                  ),
                  const SizedBox(height: 12),
                  // Day indicator with enhanced design
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.black.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: day['day'] == 'Sun' ?
                      Border.all(color: primaryColor.withOpacity(0.3)) : null,
                    ),
                    child: Text(
                      day['day'],
                      style: TextStyle(
                        color: day['day'] == 'Sun' ? primaryColor : secondaryTextColor,
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