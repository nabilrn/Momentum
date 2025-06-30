import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'package:momentum/presentation/controllers/habit_controller.dart';
import 'package:momentum/presentation/widgets/home/habit_item.dart';
import 'package:momentum/presentation/widgets/common/empty_state_widget.dart';
import 'package:momentum/presentation/widgets/sidebar_navigation.dart';
import 'package:momentum/presentation/widgets/bottom_navigation.dart';
import 'package:provider/provider.dart';

class FavoriteHabitsScreen extends StatefulWidget {
  const FavoriteHabitsScreen({super.key});

  @override
  State<FavoriteHabitsScreen> createState() => _FavoriteHabitsScreenState();
}

class _FavoriteHabitsScreenState extends State<FavoriteHabitsScreen> {
  int _currentIndex =
      2; // Index for favorites in bottom navigation (heart icon)

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = AppTheme.isDarkMode(context);
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FA),
      body: Consumer<HabitController>(
        builder: (context, habitController, child) {
          // Filter only favorite habits
          final favoriteHabits =
              habitController.habits
                  .where((habit) => habit.isFavorite)
                  .map(
                    (habit) => {
                      'id': habit.id,
                      'name': habit.name,
                      'startTime': habit.startTime ?? 'Not set',
                      'priority': habit.priority,
                      'focusTimeMinutes': habit.focusTimeMinutes,
                      'isFavorite': habit.isFavorite,
                      'userId': habit.userId,
                      'createdAt': habit.createdAt,
                    },
                  )
                  .toList();

          if (isDesktop) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: _buildBackgroundDecoration(isDarkMode),
              child: Row(
                children: [
                  // Sidebar Navigation for desktop
                  SidebarNavigation(
                    currentIndex: 5, // Use index 5 for favorites in sidebar
                    onTap: (index) {
                      setState(() {
                        _currentIndex =
                            index == 5
                                ? 2
                                : index; // Map sidebar index to bottom nav index
                      });
                    },
                  ),

                  // Main Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child:
                          favoriteHabits.isEmpty
                              ? _buildEmptyState()
                              : _buildFavoriteHabitsList(
                                favoriteHabits,
                                habitController,
                              ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Mobile layout
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: _buildBackgroundDecoration(isDarkMode),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child:
                      favoriteHabits.isEmpty
                          ? _buildEmptyState()
                          : _buildFavoriteHabitsList(
                            favoriteHabits,
                            habitController,
                          ),
                ),
              ),
            );
          }
        },
      ),
      bottomNavigationBar:
          MediaQuery.of(context).size.width <= 800
              ? BottomNavigation(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  // Navigate to other screens if needed
                  final routes = {
                    0: '/home',
                    1: '/random_habit',
                    3: '/overview',
                  };
                  if (routes.containsKey(index) && index != 2) {
                    Navigator.pushReplacementNamed(context, routes[index]!);
                  }
                },
              )
              : null,
    );
  }

  BoxDecoration? _buildBackgroundDecoration(bool isDarkMode) {
    return isDarkMode
        ? const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF121117), Color(0xFF1A1A24)],
          ),
        )
        : null;
  }

  Widget _buildEmptyState() {
    final bool isDarkMode = AppTheme.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title section
        Text(
          'Habit Priority',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        // Empty state
        const Expanded(
          child: Center(
            child: EmptyStateWidget(
              title: 'No priority habits yet',
              message: 'Mark your habits as favorites to see them here',
              lottieAsset: 'assets/lottie/empty_state.json',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteHabitsList(
    List<Map<String, dynamic>> favoriteHabits,
    HabitController habitController,
  ) {
    final bool isDarkMode = AppTheme.isDarkMode(context);
    final bool isDesktop = MediaQuery.of(context).size.width > 800;

    if (isDesktop) {
      // Desktop layout - simple list without card wrapper
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title section
          Text(
            'Habits Priority',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          // Habits list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: favoriteHabits.length,
              itemBuilder: (context, index) {
                final habit = favoriteHabits[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: HabitItem(
                    habit: habit,
                    onFavoriteToggle:
                        () => _toggleFavorite(habitController, habit),
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else {
      // Mobile layout - simplified without extra column wrapper
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title section
          Text(
            'Habits Priority',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          // Habits list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(
                bottom: 80,
              ), // Space for bottom nav
              itemCount: favoriteHabits.length,
              itemBuilder: (context, index) {
                final habit = favoriteHabits[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: HabitItem(
                    habit: habit,
                    onFavoriteToggle:
                        () => _toggleFavorite(habitController, habit),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }
  }

  void _toggleFavorite(
    HabitController habitController,
    Map<String, dynamic> habit,
  ) {
    final habitModel = habitController.getHabitById(habit['id']);
    if (habitModel != null) {
      final updatedHabit = habitModel.copyWith(
        isFavorite: !habitModel.isFavorite,
      );
      habitController.updateHabit(updatedHabit);
    }
  }
}
