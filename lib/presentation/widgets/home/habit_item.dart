import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'package:momentum/presentation/utils/color_utils.dart';
import 'habit_detail_dialog.dart';

class HabitItem extends StatelessWidget {
  final Map<String, dynamic> habit;

  const HabitItem({
    super.key,
    required this.habit,
  });

  // Get icon based on priority
  IconData _getPriorityIcon(String? priority) {
    switch (priority?.toLowerCase() ?? 'medium') {
      case 'low':
        return Icons.arrow_downward;
      case 'medium':
        return Icons.remove;
      case 'high':
        return Icons.arrow_upward;
      default:
        return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.isDarkMode(context);
    // Get priority and capitalize first letter to match ColorUtils format
    final priority = habit['priority'] ?? 'medium';
    final priorityFormatted = priority[0].toUpperCase() + priority.substring(1).toLowerCase();
    final priorityColor = ColorUtils.getPriorityColor(priorityFormatted);
    final priorityIcon = _getPriorityIcon(priority);

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HabitDetailDialog.show(context, habit);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Priority indicator
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              habit['name'] ?? 'Unnamed Habit',
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  priorityIcon,
                                  color: priorityColor,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  (habit['priority'] ?? 'medium').toUpperCase(),
                                  style: TextStyle(
                                    color: priorityColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Started at ${habit['startTime'] ?? 'Not set'}',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Focus time indicator
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${habit['focusTimeMinutes'] ?? 0}',
                    style: TextStyle(
                      color: priorityColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}