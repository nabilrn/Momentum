import 'package:flutter/material.dart';
import '../widgets/momentum_logo.dart';
import '../widgets/bottom_navigation.dart';
import 'package:momentum/core/theme/app_theme.dart';
import '../services/navigation_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    if (index == 0) {
      // Already on home screen, no navigation needed
    } else if (index == 1) {
      NavigationService.navigateTo(context, '/random_habit');
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
          ? const Color(0xFF121117) // Dark background
          : Colors.white, // Light background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: MomentumLogo(size: 24),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.menu,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.4),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Icon(
                  Icons.person,
                  color: isDarkMode ? Colors.white : Colors.black,
                  size: 18,
                ),
              ),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
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
            const SizedBox(height: 8),

            // Time card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  gradient: isDarkMode
                      ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1E1E2C),
                      Color(0xFF0D0D15),
                    ],
                  )
                      : null,
                  color: isDarkMode ? null : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode
                          ? Colors.black.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: isDarkMode
                      ? null
                      : Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SUNDAY',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '09:30',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Habit list items
            Expanded(
              child: ListView.builder(
                itemCount: 4,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Container(
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
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? Colors.black.withOpacity(0.15)
                                : Colors.grey.withOpacity(0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: isDarkMode
                            ? null
                            : Border.all(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4B6EFF), // Blue color for both modes
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4B6EFF).withOpacity(0.4),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Text(
                            '15',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        title: Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            'Jogging',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        subtitle: Text(
                          'every day at 09:00 pm',
                          style: TextStyle(
                            color: isDarkMode ? Colors.grey : Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        onTap: () {
                          // Navigate to habit details with smooth transition
                          NavigationService.navigateTo(context, '/random_habit');
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C4BFF).withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            // Navigate to add habit screen with smooth transition
            NavigationService.navigateTo(context, '/random_habit');
          },
          backgroundColor: const Color(0xFF6C4BFF), // Purple color for both modes
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}