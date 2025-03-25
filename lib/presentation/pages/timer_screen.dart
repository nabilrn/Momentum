import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../services/navigation_service.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with SingleTickerProviderStateMixin {
  bool _isRunning = false;
  bool _isCompleted = false;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = AppTheme.isDarkMode(context);
    final primaryColor = const Color(0xFF4B6EFF);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App bar with back button and habit title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => NavigationService.goBack(context),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      "Morning Meditation",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Habit description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                '15 minutes of focused activity',
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 16,
                ),
              ),
            ),

            const Spacer(),

            // Timer display
            _buildTimerCircle(isDarkMode, primaryColor),

            // Completed message
            if (_isCompleted)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Great job! You completed this habit.',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            const Spacer(),

            // Control buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Reset button
                  _buildActionButton(
                    'Reset',
                    Icons.refresh,
                    primaryColor,
                    isDarkMode,
                        () => setState(() => _isCompleted = false),
                    isOutlined: true,
                  ),

                  const SizedBox(width: 16),

                  // Start/Pause button
                  _buildActionButton(
                    _isRunning ? 'Pause' : (_isCompleted ? 'Done' : 'Start'),
                    _isRunning ? Icons.pause : (_isCompleted ? Icons.check : Icons.play_arrow),
                    primaryColor,
                    isDarkMode,
                        () => setState(() {
                      if (_isCompleted) {
                        Navigator.of(context).pop();
                      } else {
                        _isRunning = !_isRunning;
                        if (!_isRunning) {
                          _isCompleted = true;
                        }
                      }
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerCircle(bool isDarkMode, Color primaryColor) {
    // Example fixed progress
    double progress = 0.75;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.2 + (_animation.value * 0.1)),
                blurRadius: 20 + (_animation.value * 10),
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer progress circle
              SizedBox(
                width: 220,
                height: 220,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: isDarkMode
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    primaryColor.withOpacity(_isRunning ? 1.0 : 0.7),
                  ),
                ),
              ),

              // Inner circle with time
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode ? const Color(0xFF252836) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: -5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "11:15:00",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(
      String label,
      IconData icon,
      Color color,
      bool isDarkMode,
      VoidCallback onPressed, {
        bool isOutlined = false,
      }) {
    return Expanded(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: isOutlined
              ? null
              : const LinearGradient(
            colors: [
              Color(0xFF4B6EFF),
              Color(0xFF3B5AF8),
            ],
          ),
          color: isOutlined ? Colors.transparent : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isOutlined
              ? null
              : [
            BoxShadow(
              color: const Color(0xFF4B6EFF).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: isOutlined
              ? Border.all(
            color: isDarkMode ? Colors.white24 : Colors.black12,
            width: 2,
          )
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isOutlined
                        ? (isDarkMode ? Colors.white : Colors.black)
                        : Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: isOutlined
                          ? (isDarkMode ? Colors.white : Colors.black)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}