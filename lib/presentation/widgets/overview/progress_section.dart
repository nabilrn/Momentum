import 'package:flutter/material.dart';
import 'legend_item.dart';

class ProgressSection extends StatelessWidget {
  final bool isDarkMode;
  final Color textColor;
  final Color secondaryTextColor;
  final Color primaryColor;
  final Color accentColor;
  final int completedHabits;
  final int totalHabits;
  final double completionRate;

  const ProgressSection({
    super.key,
    required this.isDarkMode,
    required this.textColor,
    required this.secondaryTextColor,
    required this.primaryColor,
    required this.accentColor,
    required this.completedHabits,
    required this.totalHabits,
    required this.completionRate,
  });

  // Get color based on completion percentage
  Color _getCompletionColor(double percentage) {
    if (percentage >= 0.7) return const Color(0xFF4CAF50); // Success
    if (percentage >= 0.4) return const Color(0xFFFFC107); // Warning
    return const Color(0xFFF44336); // Danger
  }

  @override
  Widget build(BuildContext context) {
    final completionColor = _getCompletionColor(completionRate);

    return Container(
      padding: const EdgeInsets.all(24),
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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: completionColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isDarkMode
            ? Border.all(color: Colors.white.withOpacity(0.03))
            : Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.insights_rounded,
                color: completionColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Habit Completion Rate',
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: completionRate),
                  duration: const Duration(milliseconds: 1500),
                  builder: (context, value, _) {
                    return Stack(
                      children: [
                        SizedBox(
                          width: 120,
                          height: 120,
                          child: CircularProgressIndicator(
                            value: value,
                            strokeWidth: 10,
                            backgroundColor: isDarkMode
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(completionColor),
                          ),
                        ),
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: CircularProgressIndicator(
                              value: value * 0.8,
                              strokeWidth: 5,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                accentColor.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${(value * 100).toInt()}%',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                value > 0.6 ? 'Good' : 'Keep going',
                                style: TextStyle(
                                  color: completionColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LegendItem(
                    title: 'Completed',
                    value: '$completedHabits habits',
                    dotColor: const Color(0xFF4CAF50),
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                  const SizedBox(height: 16),
                  LegendItem(
                    title: 'Remaining',
                    value: '${totalHabits - completedHabits} habits',
                    dotColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
                    textColor: textColor,
                    secondaryTextColor: secondaryTextColor,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}