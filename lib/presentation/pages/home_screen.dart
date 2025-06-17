import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'package:momentum/presentation/providers/auth_provider.dart';
import 'package:momentum/presentation/services/navigation_service.dart';
import 'package:momentum/presentation/widgets/bottom_navigation.dart';
import 'package:momentum/presentation/widgets/sidebar_navigation.dart';
import 'package:momentum/presentation/widgets/home/home_app_bar.dart';
import 'package:momentum/presentation/widgets/home/time_date_card.dart';
import 'package:momentum/presentation/widgets/home/habit_list.dart';
import 'package:provider/provider.dart';
import 'package:momentum/presentation/controllers/habit_controller.dart';
import 'package:lottie/lottie.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late String _timeOfDay;
  bool _isLoading = true;

  // Cache these values for better performance
  final Color _accentColor = const Color(0xFF6C4BFF);
  final Color _primaryColor = const Color(0xFF4B6EFF);

  // Responsive breakpoint
  static const double _breakpoint = 768;

  @override
  void initState() {
    super.initState();
    _timeOfDay = _calculateTimeOfDay();

    // Load habits after the first frame and track loading state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final habitController = Provider.of<HabitController>(context, listen: false);
      setState(() => _isLoading = true);
      // Fetch user data at the same time for the welcome message
      Provider.of<AuthProvider>(context, listen: false).refreshUserData();
      habitController.loadHabits().then((_) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      });
    });
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });

    final routes = {
      1: '/random_habit',
      2: '/overview',
      3: '/settings',
      4: '/account',
    };

    if (routes.containsKey(index)) {
      NavigationService.navigateTo(context, routes[index]!);
    }
  }

  String _calculateTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 18) return 'afternoon';
    return 'evening';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final usesSidebar = screenWidth > _breakpoint;

    return Scaffold(
      extendBody: !usesSidebar,
      backgroundColor: isDarkMode ? const Color(0xFF121117) : Colors.white,
      appBar: usesSidebar ? null : const HomeAppBar(),
      body: usesSidebar
          ? _buildWithSidebar(isDarkMode)
          : _buildWithBottomNav(isDarkMode),
      floatingActionButton: usesSidebar ? null : _buildFloatingActionButton(),
      bottomNavigationBar: usesSidebar
          ? null
          : BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  // REFACTOR: The entire desktop layout is enhanced here.
  Widget _buildWithSidebar(bool isDarkMode) {
    final authProvider = Provider.of<AuthProvider>(context);
    final habitController = Provider.of<HabitController>(context);

    return Row(
      children: [
        SidebarNavigation(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
        Expanded(
          child: Container(
            decoration: _buildBackgroundDecoration(isDarkMode),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // REFACTOR: More personal welcome message
                            _buildWelcomeMessage(isDarkMode, authProvider.fullName),
                            const SizedBox(height: 8),
                            Text(
                              "Let's make today productive.",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            )
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => NavigationService.navigateTo(context, '/add_habit'),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Habit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            children: [
                              const TimeDateCard(),
                              const SizedBox(height: 24),
                              // NEW: Populated stats card
                              _buildStatsCard(isDarkMode, habitController),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          flex: 4,
                          // REFACTOR: Habit list is now wrapped in a card for cohesion
                          child: _buildHabitListContainer(isDarkMode, habitController),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // NEW: Stats card widget is now populated with data.
  Widget _buildStatsCard(bool isDarkMode, HabitController habitController) {
    // These calculations assume methods exist on the controller as seen in other files
    final completedToday = habitController.getTotalCompletionsForDate(DateTime.now());
    final totalHabits = habitController.habits.length;
    final currentStreak = habitController.calculateCurrentStreak();

    return Card(
      color: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
      elevation: isDarkMode ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.transparent,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 20),
            IntrinsicHeight(
              child: Row(
                children: [
                  _buildStatItem(isDarkMode, '$completedToday/$totalHabits', 'Completed',
                      Icons.check_circle_outline_rounded, Colors.green),
                  VerticalDivider(color: Colors.grey.withOpacity(0.2)),
                  _buildStatItem(isDarkMode, '$currentStreak', 'Day Streak',
                      Icons.local_fire_department_rounded, Colors.orange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // REFACTOR: Stat item now includes an icon for better visuals.
  Widget _buildStatItem(bool isDarkMode, String value, String label, IconData icon, Color iconColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // NEW: Wrapper for the habit list to provide a card background and header.
  Widget _buildHabitListContainer(bool isDarkMode, HabitController habitController) {
    return Card(
      color: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
      elevation: isDarkMode ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              "Today's Habits",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black),
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildHabitList(habitController)),
        ],
      ),
    );
  }

  Widget _buildWithBottomNav(bool isDarkMode) {
    // ... (kode asli Anda tidak berubah, karena sudah baik)
    return OrientationBuilder(
      builder: (context, orientation) {
        final screenWidth = MediaQuery.of(context).size.width;
        if (orientation == Orientation.landscape && screenWidth > 600) {
          return _buildLandscapeLayout(isDarkMode);
        } else {
          return _buildPortraitLayout(isDarkMode);
        }
      },
    );
  }

  Widget _buildPortraitLayout(bool isDarkMode) {
    // ... (kode asli Anda tidak berubah)
    return SafeArea(
      bottom: false,
      child: Container(
        decoration: _buildBackgroundDecoration(isDarkMode),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildWelcomeMessage(isDarkMode, Provider.of<AuthProvider>(context).fullName),
            ),
            const TimeDateCard(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80),
                child: _buildHabitList(Provider.of<HabitController>(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandscapeLayout(bool isDarkMode) {
    // ... (kode asli Anda tidak berubah)
    return SafeArea(
      bottom: false,
      child: Container(
        decoration: _buildBackgroundDecoration(isDarkMode),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 8, left: 20, right: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeMessage(isDarkMode, Provider.of<AuthProvider>(context).fullName),
                    const SizedBox(height: 16),
                    const TimeDateCard(),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80, right: 20),
                child: _buildHabitList(Provider.of<HabitController>(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration? _buildBackgroundDecoration(bool isDarkMode) {
    return isDarkMode ? const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF121117), Color(0xFF1A1A24)],
      ),
    ) : null;
  }

  Widget _buildHabitList(HabitController habitController) {
    if (_isLoading) return _buildLoadingIndicator();
    if (habitController.habits.isEmpty) return _buildEmptyState();

    return HabitList(habitController: habitController);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie animation instead of Icon
          SizedBox(
            height: 200,
            width: 200,
            child: Lottie.asset(
              'assets/lottie/empty_state.json', // Add your Lottie file here
              repeat: true,
              animate: true,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No habits yet.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap "Add Habit" to create your first one!',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    // ... (kode asli Anda tidak berubah)
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
          ),
          const SizedBox(height: 16),
          const Text('Loading your habits...'),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage(bool isDarkMode, String? fullName) {
    final name = fullName?.split(' ')[0] ?? ''; // Get first name
    return Text(
      'Good $_timeOfDay${name.isNotEmpty ? ', $name' : ''}',
      style: TextStyle(
        color: isDarkMode ? Colors.white70 : Colors.black54,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    // ... (kode asli Anda tidak berubah)
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_accentColor, _primaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _accentColor.withOpacity(0.5),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => NavigationService.navigateTo(context, '/add_habit'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white, size: 24),
      ),
    );
  }
}