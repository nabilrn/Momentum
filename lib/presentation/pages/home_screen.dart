import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'package:momentum/presentation/services/navigation_service.dart';
import 'package:momentum/presentation/widgets/bottom_navigation.dart';
import 'package:momentum/presentation/widgets/home/home_app_bar.dart';
import 'package:momentum/presentation/widgets/home/time_date_card.dart';
import 'package:momentum/presentation/widgets/home/habit_list.dart';
import 'package:provider/provider.dart';
import 'package:momentum/presentation/controllers/habit_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late String _timeOfDay;

  // Cache these values for better performance
  final Color _accentColor = const Color(0xFF6C4BFF);
  final Color _primaryColor = const Color(0xFF4B6EFF);

  @override
  void initState() {
    super.initState();

    // Calculate time of day once during initialization
    _timeOfDay = _calculateTimeOfDay();

    // Load habits after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HabitController>(context, listen: false).loadHabits();
    });
  }

  void _onTabTapped(int index) {
    if (_currentIndex == index) return; // Prevent unnecessary state updates

    setState(() {
      _currentIndex = index;
    });

    // Use a map for navigation paths instead of if-else for better scalability
    final routes = {
      1: '/random_habit',
      2: '/overview',
    };

    if (routes.containsKey(index)) {
      NavigationService.navigateTo(context, routes[index]!);
    }
  }

  String _calculateTimeOfDay() {
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

    return Scaffold(
      extendBody: true,
      backgroundColor: isDarkMode ? const Color(0xFF121117) : Colors.white,
      appBar: const HomeAppBar(),
      body: _buildBody(isDarkMode),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildBody(bool isDarkMode) {
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
          : null, // No decoration needed for light mode - more efficient
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          _buildWelcomeMessage(isDarkMode),
          const TimeDateCard(),
          Expanded(
            child: Consumer<HabitController>(
              // Using Consumer for more targeted rebuilds
              builder: (context, habitController, _) => HabitList(
                habitController: habitController,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        'Good $_timeOfDay',
        style: TextStyle(
          color: isDarkMode ? Colors.white70 : Colors.black54,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _accentColor,
            _primaryColor,
          ],
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