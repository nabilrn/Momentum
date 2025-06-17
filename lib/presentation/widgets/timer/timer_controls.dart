import 'package:flutter/material.dart';
import 'timer_action_button.dart';

class TimerControls extends StatelessWidget {
  final bool isRunning;
  final bool isCompleted;
  final bool isDarkMode;
  final Color primaryColor;
  final VoidCallback onReset;
  final VoidCallback onToggle;
  final VoidCallback onNavigateToHome;
  final bool isDesktop;

  const TimerControls({
    super.key,
    required this.isRunning,
    required this.isCompleted,
    required this.isDarkMode,
    required this.primaryColor,
    required this.onReset,
    required this.onToggle,
    required this.onNavigateToHome,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Completed message
        if (isCompleted)
          Padding(
            padding: EdgeInsets.only(bottom: isDesktop ? 32.0 : 24.0),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 24 : 20,
                  vertical: isDesktop ? 16 : 12
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4B6EFF), Color(0xFF6C4BFF)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.celebration,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Great job! You completed this habit.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isDesktop ? 18 : 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Control buttons
        SizedBox(
          width: isDesktop ? 400 : double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: isDesktop ? 1 : 1,
                child: TimerActionButton(
                  label: 'Reset',
                  icon: Icons.refresh,
                  color: primaryColor,
                  isDarkMode: isDarkMode,
                  onPressed: onReset,
                  isOutlined: true,
                ),
              ),
              SizedBox(width: isDesktop ? 24 : 16),
              Expanded(
                flex: isDesktop ? 1 : 1,
                child: TimerActionButton(
                  label: isRunning ? 'Pause' : (isCompleted ? 'Done' : 'Start'),
                  icon: isRunning ? Icons.pause : (isCompleted ? Icons.check : Icons.play_arrow),
                  color: primaryColor,
                  isDarkMode: isDarkMode,
                  onPressed: isCompleted ? onNavigateToHome : onToggle,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}