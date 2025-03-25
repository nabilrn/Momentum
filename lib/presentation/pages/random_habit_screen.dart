import 'package:flutter/material.dart';
import '../widgets/bottom_navigation.dart';
import 'package:momentum/core/theme/app_theme.dart';
import '../services/navigation_service.dart';

class RandomHabitScreen extends StatefulWidget {
  const RandomHabitScreen({super.key});

  @override
  State<RandomHabitScreen> createState() => _RandomHabitScreenState();
}

class _RandomHabitScreenState extends State<RandomHabitScreen> {
  int _currentIndex = 1; // Set to 1 since this is the Random Habit tab

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Handle navigation based on tab index
    if (index == 0) {
      NavigationService.navigateTo(context, '/home');
    } else if (index == 1) {
      // Already on random habit screen, no need to navigate
    } else if (index == 2) {
      NavigationService.navigateTo(context, '/settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.isDarkMode(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: isDarkMode
          ? const Color(0xFF121117)  // Dark background for dark mode
          : Colors.white, // White background for light mode
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Random Habit',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 18,
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
            : const BoxDecoration(
          color: Colors.white, // Light mode background
        ),
        child: Column(
          children: [
            // Tab indicators
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTabIndicator('Tab', isSelected: false, isDarkMode: isDarkMode),
                  _buildTabIndicator('Tab', isSelected: true, isDarkMode: isDarkMode),
                  _buildTabIndicator('Tab', isSelected: false, isDarkMode: isDarkMode),
                ],
              ),
            ),

            // Divider
            Container(
              height: 1,
              color: isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.1),
              margin: const EdgeInsets.symmetric(vertical: 10.0),
            ),

            // Habit name
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                'Jogging',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Timer circle
            Expanded(
              child: Center(
                child: Hero(
                  tag: 'timer-circle',
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.3)
                              : Colors.blue.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '15',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'minutes',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Start button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4B6EFF),
                      Color(0xFF3B5AF8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4B6EFF).withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    // Start countdown logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Start Countdown',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),

            // Space for bottom navigation
            const SizedBox(height: 60),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildTabIndicator(String label, {required bool isSelected, required bool isDarkMode}) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDarkMode
                ? (isSelected ? Colors.white : Colors.white.withOpacity(0.5))
                : (isSelected ? Colors.black : Colors.black.withOpacity(0.5)),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected
                ? (isDarkMode ? Colors.white : Colors.black)
                : Colors.transparent,
            border: Border.all(
              color: isDarkMode
                  ? (isSelected ? Colors.white : Colors.white.withOpacity(0.3))
                  : (isSelected ? Colors.black : Colors.black.withOpacity(0.3)),
              width: 1,
            ),
          ),
        ),
      ],
    );
  }
}