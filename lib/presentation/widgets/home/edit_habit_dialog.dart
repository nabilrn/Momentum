import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'package:momentum/data/models/habit_model.dart';
import 'package:momentum/presentation/controllers/habit_controller.dart';
import 'package:momentum/presentation/widgets/add_habit/custom_text_field.dart';
import 'package:momentum/presentation/widgets/add_habit/form_label.dart';
import 'package:momentum/presentation/widgets/add_habit/priority_selector.dart';
import 'package:momentum/presentation/widgets/add_habit/time_selector.dart';
import 'package:provider/provider.dart';

class EditHabitDialog {
  static void show(BuildContext context, Map<String, dynamic> habit) {
    final isDarkMode = AppTheme.isDarkMode(context);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final formKey = GlobalKey<FormState>();

    // Form controllers
    final nameController = TextEditingController(text: habit['name'] ?? '');
    final focusTimeController = TextEditingController(
        text: (habit['focusTimeMinutes'] ?? '').toString());

    // State values
    String selectedPriority = (habit['priority'] ?? 'high').toString();
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
            void showTimePicker() async {
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

            void saveHabit() {
              if (formKey.currentState!.validate()) {
                final controller = Provider.of<HabitController>(context, listen: false);

                // Show loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator()),
                );

                // Create habit model for update
                final habitModel = HabitModel(
                  id: habit['id'],
                  name: nameController.text,
                  focusTimeMinutes: int.parse(focusTimeController.text),
                  priority: selectedPriority.toLowerCase(),
                  startTime: startTime != null ?
                  "${startTime!.hour.toString().padLeft(2, '0')}:${startTime!.minute.toString().padLeft(2, '0')}" : null,
                  userId: habit['userId'],
                );

                // Update the habit
                controller.updateHabit(habitModel).then((updatedHabit) {
                  // Close loading dialog
                  Navigator.pop(context);

                  if (updatedHabit != null) {
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Habit updated successfully!'),
                        backgroundColor: const Color(0xFF4B6EFF),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                      ),
                    );

                    // Close the dialog
                    Navigator.pop(context);
                  } else {
                    // Show error message
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: ${controller.error ?? "Failed to update habit"}'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                      ),
                    );
                  }
                });
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
                        FormLabel(
                          label: 'Habit Name',
                          textColor: textColor,
                          icon: Icons.edit_rounded,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: nameController,
                          hintText: 'e.g., Morning Meditation',
                          prefixIcon: Icons.lightbulb_outline,
                          isDarkMode: isDarkMode,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a habit name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Focus Time
                        FormLabel(
                          label: 'Focus Time (minutes)',
                          textColor: textColor,
                          icon: Icons.hourglass_top_rounded,
                        ),
                        const SizedBox(height: 8),
                        CustomTextField(
                          controller: focusTimeController,
                          hintText: 'e.g., 30',
                          prefixIcon: Icons.timer_outlined,
                          keyboardType: TextInputType.number,
                          isDarkMode: isDarkMode,
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

                        // Priority Selection
                        FormLabel(
                          label: 'Priority Level',
                          textColor: textColor,
                          icon: Icons.flag_rounded,
                        ),
                        const SizedBox(height: 8),
                        PrioritySelector(
                          isDarkMode: isDarkMode,
                          textColor: textColor,
                          selectedType: selectedPriority.capitalize(),
                          onPrioritySelected: (type) {
                            setState(() {
                              selectedPriority = type;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        // Start Time
                        FormLabel(
                          label: 'Start Time',
                          textColor: textColor,
                          icon: Icons.schedule_rounded,
                        ),
                        const SizedBox(height: 8),
                        TimeSelector(
                          isDarkMode: isDarkMode,
                          textColor: textColor,
                          primaryColor: const Color(0xFF4B6EFF),
                          selectedTime: startTime,
                          onTap: showTimePicker,
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
}