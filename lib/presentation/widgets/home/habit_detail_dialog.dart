import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'package:momentum/presentation/services/navigation_service.dart';

class HabitDetailDialog {
  static void show(BuildContext context, Map<String, dynamic> habit) {
    final isDarkMode = AppTheme.isDarkMode(context);
    final primaryColor = const Color(0xFF4B6EFF);
    final accentColor = const Color(0xFF6C4BFF);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1A1A24) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title and close button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(habit['priority']).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getPriorityIcon(habit['priority']),
                      color: _getPriorityColor(habit['priority']),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      habit['name'],
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDarkMode ? Colors.white60 : Colors.black45,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Habit details
              _buildDetailRow(
                context,
                Icons.schedule_rounded,
                'Schedule',
                habit['time'],
                isDarkMode,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                context,
                Icons.local_fire_department_rounded,
                'Current Streak',
                '${habit['streak']} days',
                isDarkMode,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                context,
                _getPriorityIcon(habit['priority']),
                'Priority',
                habit['priority'].toUpperCase(),
                isDarkMode,
                valueColor: _getPriorityColor(habit['priority']),
              ),

              const SizedBox(height: 32),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Edit button
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        NavigationService.navigateTo(context, '/edit_habit');
                      },
                      icon: Icon(
                        Icons.edit_rounded,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        size: 24,
                      ),
                      tooltip: 'Edit habit',
                    ),
                  ),

                  // Primary action button
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentColor, primaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        NavigationService.navigateTo(context, '/timer');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer_outlined, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Start Timer',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildDetailRow(
      BuildContext context,
      IconData icon,
      String label,
      String value,
      bool isDarkMode,
      {Color? valueColor}
      ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDarkMode ? Colors.white60 : Colors.black54,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isDarkMode ? Colors.white60 : Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? (isDarkMode ? Colors.white : Colors.black),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'low':
        return const Color(0xFF4CAF50); // Green
      case 'medium':
        return const Color(0xFFFFC107); // Yellow/Amber
      case 'high':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF4B6EFF); // Default blue
    }
  }

  static IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'low':
        return Icons.arrow_downward_rounded;
      case 'medium':
        return Icons.remove_rounded;
      case 'high':
        return Icons.arrow_upward_rounded;
      default:
        return Icons.circle;
    }
  }
}