import 'package:flutter/material.dart';
import 'timer_action_button.dart';

class TimerControls extends StatelessWidget {
  final bool isRunning;
  final bool isCompleted;
  final bool isDarkMode;
  final Color primaryColor;
  final VoidCallback onReset;
  final VoidCallback onToggle;
  final VoidCallback onNavigateToHome; // Add a callback for navigation

  const TimerControls({
    super.key,
    required this.isRunning,
    required this.isCompleted,
    required this.isDarkMode,
    required this.primaryColor,
    required this.onReset,
    required this.onToggle,
    required this.onNavigateToHome, // Pass the navigation callback
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Completed message
        if (isCompleted)
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.celebration,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Great job! You completed this habit.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Reset button
            TimerActionButton(
              label: 'Reset',
              icon: Icons.refresh,
              color: primaryColor,
              isDarkMode: isDarkMode,
              onPressed: onReset,
              isOutlined: true,
            ),

            const SizedBox(width: 16),

            // Start/Pause/Done button
            TimerActionButton(
              label: isRunning ? 'Pause' : (isCompleted ? 'Done' : 'Start'),
              icon: isRunning ? Icons.pause : (isCompleted ? Icons.check : Icons.play_arrow),
              color: primaryColor,
              isDarkMode: isDarkMode,
              onPressed: isCompleted ? onNavigateToHome : onToggle, // Navigate if completed
            ),
          ],
        ),
      ],
    );
  }
}