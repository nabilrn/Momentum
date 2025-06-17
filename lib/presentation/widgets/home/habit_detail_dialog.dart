// lib/presentation/dialogs/habit_detail_dialog.dart

import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'package:momentum/presentation/services/navigation_service.dart';
import 'package:momentum/presentation/widgets/home/edit_habit_dialog.dart'; // Import edit dialog

class HabitDetailDialog {
  static void show(BuildContext context, Map<String, dynamic> habit, {Function? onHabitUpdated}) {
    final isDarkMode = AppTheme.isDarkMode(context);
    final primaryColor = const Color(0xFF4B6EFF);
    final accentColor = const Color(0xFF6C4BFF);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        // REFACTOR: Gunakan ConstrainedBox agar dialog tidak terlalu lebar di layar besar
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500), // Batasi lebar maksimum dialog
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1A1A24) : Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(habit['priority'] ?? 'medium').withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getPriorityIcon(habit['priority'] ?? 'medium'),
                        color: _getPriorityColor(habit['priority'] ?? 'medium'),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        habit['name'] ?? 'Unnamed Habit',
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
                const SizedBox(height: 24),
                const Divider(height: 1),
                const SizedBox(height: 24),

                // Habit details
                _buildDetailRow(Icons.timer_outlined, 'Focus Time', '${habit['focusTimeMinutes'] ?? 0} minutes', isDarkMode),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.schedule_rounded, 'Start Time', habit['startTime'] ?? 'Not set', isDarkMode),
                const SizedBox(height: 16),
                _buildDetailRow(
                  _getPriorityIcon(habit['priority'] ?? 'medium'), 'Priority',
                  (habit['priority'] ?? 'medium').toUpperCase(), isDarkMode,
                  valueColor: _getPriorityColor(habit['priority'] ?? 'medium'),
                ),
                const SizedBox(height: 32),

                // Action buttons
                Row(
                  children: [
                    // NEW: Tombol Edit
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context); // Tutup dialog detail
                          EditHabitDialog.show(context, habit, onHabitUpdated: onHabitUpdated); // Buka dialog edit
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: isDarkMode ? Colors.white54 : Colors.grey.shade300),
                        ),
                        child: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Primary action button
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow_rounded, size: 20),
                        label: const Text('Start Timer', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.pop(context);
                          NavigationService.navigateTo(
                              context,
                              '/timer',
                              arguments: {'habitId': habit['id']}
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildDetailRow(IconData icon, String label, String value, bool isDarkMode, {Color? valueColor}) {
    // ... (kode helper tidak berubah)
    return Row(
      children: [
        Icon(icon, size: 18, color: isDarkMode ? Colors.white60 : Colors.black54),
        const SizedBox(width: 16),
        Text(label, style: TextStyle(color: isDarkMode ? Colors.white60 : Colors.black54, fontSize: 14)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? (isDarkMode ? Colors.white : Colors.black),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  static Color _getPriorityColor(String priority) {
    // ... (kode helper tidak berubah)
    switch (priority.toLowerCase()) {
      case 'low': return const Color(0xFF4CAF50);
      case 'medium': return const Color(0xFFFFC107);
      case 'high': return const Color(0xFFF44336);
      default: return const Color(0xFF4B6EFF);
    }
  }

  static IconData _getPriorityIcon(String priority) {
    // ... (kode helper tidak berubah)
    switch (priority.toLowerCase()) {
      case 'low': return Icons.arrow_downward_rounded;
      case 'medium': return Icons.remove_rounded;
      case 'high': return Icons.arrow_upward_rounded;
      default: return Icons.circle;
    }
  }
}