import 'package:flutter/material.dart';
import '../../utils/color_util_random.dart';

class TimerCircle extends StatelessWidget {
  final Map<String, dynamic> habit;
  final bool isDarkMode;
  final bool isCountdownActive;
  final Animation<double> animation;

  const TimerCircle({
    super.key,
    required this.habit,
    required this.isDarkMode,
    required this.isCountdownActive,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final Color priorityColor = ColorUtils.getPriorityColor(habit['priority']);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: priorityColor.withOpacity(0.2 + (animation.value * 0.1)),
                blurRadius: 20 + (animation.value * 10),
                spreadRadius: 5,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Animated outer ring
              TweenAnimationBuilder(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 1),
                builder: (context, value, child) {
                  return SizedBox(
                    width: 220,
                    height: 220,
                    child: CircularProgressIndicator(
                      value: isCountdownActive ? null : value,
                      strokeWidth: 12,
                      backgroundColor: isDarkMode
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        priorityColor.withOpacity(isCountdownActive ? 1.0 : 0.7),
                      ),
                    ),
                  );
                },
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${habit['duration']}',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'minutes',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white60 : Colors.black54,
                        fontSize: 16,
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
}