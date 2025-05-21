import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'package:momentum/data/models/habit_model.dart';
import 'package:momentum/presentation/controllers/habit_controller.dart';
import 'package:provider/provider.dart';
import 'package:momentum/core/services/auth_service.dart';
import 'package:momentum/core/services/notification_service.dart';
// Add the StringExtension
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class EditHabitDialog {
  static void show(BuildContext context, Map<String, dynamic> habit) {
    final isDarkMode = AppTheme.isDarkMode(context);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final formKey = GlobalKey<FormState>();

    // Form controllers
    final nameController = TextEditingController(text: habit['name'] ?? '');
    final focusTimeController = TextEditingController(
        text: (habit['focusTimeMinutes'] ?? '').toString());

    // State values - perlu dibuat StatefulBuilder untuk menyimpan state
    String selectedPriority = (habit['priority'] ?? 'high').toString().toLowerCase();
    TimeOfDay? startTime;

    // Parse start time if available
    if (habit['startTime'] != null) {
      final timeStr = habit['startTime'];
      try {
        final parts = timeStr.split(':');
        if (parts.length == 2) {
          int hour = int.parse(parts[0]);
          int minute = int.parse(parts[1]);
          startTime = TimeOfDay(hour: hour, minute: minute);
        }
      } catch (e) {
        debugPrint('Error parsing time: $e');
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void showTimePickerDialog() async {
              final initialTime = startTime ?? TimeOfDay.now();

              final pickedTime = await showTimePicker(
                context: context,
                initialTime: initialTime,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      timePickerTheme: TimePickerThemeData(
                        backgroundColor: isDarkMode
                            ? const Color(0xFF1A1A24)
                            : Colors.white,
                        hourMinuteTextColor: isDarkMode
                            ? Colors.white
                            : Colors.black87,
                        dayPeriodTextColor: isDarkMode
                            ? Colors.white70
                            : Colors.black54,
                        dialBackgroundColor: isDarkMode
                            ? const Color(0xFF252836)
                            : Colors.grey.shade100,
                        dialHandColor: const Color(0xFF4B6EFF),
                      ),
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: const Color(0xFF4B6EFF),
                        brightness: isDarkMode ? Brightness.dark : Brightness.light,
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedTime != null) {
                setState(() {
                  startTime = pickedTime;
                });
              }
            }

            // Fungsi untuk menangani pemilihan prioritas
            void selectPriority(String priority) {
              setState(() {
                selectedPriority = priority.toLowerCase();
              });
              print('Selected priority: $selectedPriority'); // Debug
            }

            void saveHabit() async {
              if (formKey.currentState!.validate()) {
                final controller = Provider.of<HabitController>(context, listen: false);

                try {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) => const Center(child: CircularProgressIndicator()),
                  );
                  final authService = AuthService();
                  final currentUserId = authService.currentUser?.id;

                  print("Current user ID from AuthService: $currentUserId");
                  print("Selected priority when saving: $selectedPriority"); // Debug

                  if (currentUserId == null) {
                    Navigator.of(context, rootNavigator: true).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error: You must be logged in'), backgroundColor: Colors.red),
                    );
                    return;
                  }
                  final habitModel = HabitModel(
                    id: habit['id'],
                    name: nameController.text,
                    focusTimeMinutes: int.parse(focusTimeController.text),
                    priority: selectedPriority.toLowerCase(), // Pastikan priority disimpan dengan benar
                    startTime: startTime != null ?
                    "${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}" : null,
                    userId: currentUserId, // Use the user ID we got from AuthService
                  );

                  print("Updating habit with model: ${habitModel.toMap()}");

                  // Update the habit - wait for completion
                  final updatedHabit = await controller.updateHabit(habitModel);

                  // Close loading dialog
                  Navigator.of(context, rootNavigator: true).pop();

                  if (updatedHabit != null) {

                    // Success handling
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Habit updated successfully!'),
                        backgroundColor: Color(0xFF4B6EFF),
                      ),
                    );

                    // Close the edit dialog
                    Navigator.of(context, rootNavigator: true).pop();
                  } else {
                    // Error handling
                    print("Error from controller: ${controller.error}");
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${controller.error ?? "Failed to update habit"}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  print("Edit habit error: $e");
                  // Close loading dialog if there's an error
                  Navigator.of(context, rootNavigator: true).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            }
            return Dialog(
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
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
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
                                color: const Color(0xFF4B6EFF).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                color: Color(0xFF4B6EFF),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Edit Habit',
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

                        // Habit Name
                        Text(
                          'Habit Name',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            hintText: 'e.g., Morning Meditation',
                            prefixIcon: const Icon(Icons.lightbulb_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a habit name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Focus Time
                        Text(
                          'Focus Time (minutes)',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: focusTimeController,
                          decoration: InputDecoration(
                            hintText: 'e.g., 30',
                            prefixIcon: const Icon(Icons.timer_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter focus time';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Priority Selection - Gunakan fungsi selectPriority yang baru
                        Text(
                          'Priority Level',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildPriorityOption(context, 'High', selectedPriority, selectPriority),
                            const SizedBox(width: 8),
                            _buildPriorityOption(context, 'Medium', selectedPriority, selectPriority),
                            const SizedBox(width: 8),
                            _buildPriorityOption(context, 'Low', selectedPriority, selectPriority),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Start Time
                        Text(
                          'Start Time',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: showTimePickerDialog,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDarkMode ? Colors.transparent : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  startTime != null
                                      ? '${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}'
                                      : 'Select a time',
                                  style: TextStyle(
                                    color: textColor.withOpacity(startTime != null ? 1.0 : 0.7),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: saveHabit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4B6EFF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildPriorityOption(
      BuildContext context,
      String priority,
      String selectedPriority,
      Function(String) onSelect) {

    final isSelected = selectedPriority.toLowerCase() == priority.toLowerCase();
    final color = _getPriorityColor(priority);

    return Expanded(
      child: InkWell(
        onTap: () {
          onSelect(priority); // Gunakan fungsi callback untuk update state
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : Colors.grey.withOpacity(0.3),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              priority,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
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
}