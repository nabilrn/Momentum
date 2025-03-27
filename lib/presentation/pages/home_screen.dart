import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'package:momentum/presentation/services/navigation_service.dart';
import 'package:momentum/presentation/widgets/bottom_navigation.dart';
import 'package:momentum/presentation/widgets/home/home_app_bar.dart';
import 'package:momentum/presentation/widgets/home/time_date_card.dart';
import 'package:momentum/presentation/widgets/home/priority_legend.dart';
import 'package:momentum/presentation/widgets/home/habit_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _controller;

  // Sample data including priority
  final List<Map<String, dynamic>> _habits = [
    {'name': 'Jogging', 'time': 'every day at 09:00 pm', 'streak': '15', 'priority': 'high'},
    {'name': 'Reading', 'time': 'weekdays at 08:30 pm', 'streak': '7', 'priority': 'medium'},
    {'name': 'Meditation', 'time': 'every day at 07:00 am', 'streak': '21', 'priority': 'low'},
    {'name': 'Coding', 'time': 'weekends at 10:00 am', 'streak': '5', 'priority': 'medium'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      // Already on home screen, no navigation needed
    } else if (index == 1) {
      NavigationService.navigateTo(context, '/random_habit');
    } else if (index == 2) {
      NavigationService.navigateTo(context, '/overview');
    }
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'morning';
    } else if (hour < 17) {
      return 'afternoon';
    } else {
      return 'evening';
    }
  }



  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.isDarkMode(context);
    final accentColor = const Color(0xFF6C4BFF);
    final primaryColor = const Color(0xFF4B6EFF);

    return Scaffold(
      extendBody: true,
      backgroundColor: isDarkMode ? const Color(0xFF121117) : Colors.white,
      appBar: const HomeAppBar(),
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
            : const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Welcome message
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Good ${_getTimeOfDay()}',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Time and date card
            const TimeDateCard(),

            // Section title with legend
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                children: [
                  Text(
                    'Today\'s Habits',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Priority legend
                  const PriorityLegend(),
                ],
              ),
            ),

            // Habit list
            HabitList(
              habits: _habits,
              controller: _controller,
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              accentColor,
              primaryColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.5),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            NavigationService.navigateTo(context, '/add_habit');
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 24),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}