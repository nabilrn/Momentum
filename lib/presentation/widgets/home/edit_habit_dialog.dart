import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'package:momentum/data/models/habit_model.dart';
import 'package:momentum/presentation/controllers/habit_controller.dart';
import 'package:provider/provider.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class EditHabitDialog {
  static void show(BuildContext context, Map<String, dynamic> habit, {Function? onHabitUpdated}) {
    final isDarkMode = AppTheme.isDarkMode(context);
    final theme = Theme.of(context);
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: habit['name'] ?? '');
    final focusTimeController = TextEditingController(text: (habit['focusTimeMinutes'] ?? '').toString());

    String selectedPriority = (habit['priority'] ?? 'high').toString().toLowerCase();
    TimeOfDay? startTime;

    if (habit['startTime'] != null) {
      final timeStr = habit['startTime'];
      try {
        final parts = timeStr.split(':');
        if (parts.length == 2) {
          startTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
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

            void saveHabit() async {
              if (!(formKey.currentState?.validate() ?? false)) return;

              final focusTime = int.tryParse(focusTimeController.text);
              if (focusTime == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Focus time must be a valid number.'), backgroundColor: Colors.red),
                );
                return;
              }

              final controller = Provider.of<HabitController>(context, listen: false);

              // Show loading indicator
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (c) => Center(
                      child: CircularProgressIndicator(
                        color: isDarkMode ? Colors.white : const Color(0xFF4B6EFF),
                      )
                  )
              );

              try {
                List<HabitModel> userHabits = controller.habits;
                String currentUserId = '';

                if (userHabits.isNotEmpty) {
                  currentUserId = userHabits.first.userId;
                }

                if (currentUserId.isEmpty) {
                  currentUserId = habit['userId'] ?? '';
                }

                final habitModel = HabitModel(
                  id: habit['id'] ?? '',
                  name: nameController.text,
                  focusTimeMinutes: focusTime,
                  priority: selectedPriority.toLowerCase(),
                  startTime: startTime != null
                      ? "${startTime?.hour.toString().padLeft(2, '0')}:${startTime?.minute.toString().padLeft(2, '0')}"
                      : null,
                  userId: currentUserId,
                );

                final updatedHabit = await controller.updateHabit(habitModel);

                if (!context.mounted) return;
                Navigator.pop(context); // Close loading indicator

                if (updatedHabit != null) {
                  if (onHabitUpdated != null) onHabitUpdated();
                  await controller.loadHabits();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Habit updated successfully!'), backgroundColor: Colors.green),
                  );
                  Navigator.pop(context); // Close edit dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${controller.error ?? "Failed to update"}'), backgroundColor: Colors.red),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Close loading indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1A1A24) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode ? Colors.black54 : Colors.black12,
                        blurRadius: 10,
                        spreadRadius: 1,
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
                              const Icon(Icons.edit_note_rounded, color: Color(0xFF4B6EFF), size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                    'Edit Habit',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    )
                                ),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(Icons.close_rounded, color: isDarkMode ? Colors.white60 : Colors.black45),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth > 500) {
                                  return _buildDesktopFormLayout(
                                      isDarkMode,
                                      nameController,
                                      focusTimeController,
                                      selectedPriority,
                                      startTime,
                                          (newPriority) => setState(() => selectedPriority = newPriority),
                                          () async {
                                        final pickedTime = await showTimePicker(
                                            context: context,
                                            initialTime: startTime ?? TimeOfDay.now(),
                                            builder: (context, child) {
                                              return Theme(
                                                data: Theme.of(context).copyWith(
                                                  timePickerTheme: TimePickerThemeData(
                                                    backgroundColor: isDarkMode ? const Color(0xFF2A2A3A) : Colors.white,
                                                    hourMinuteTextColor: textColor,
                                                    dayPeriodTextColor: textColor,
                                                  ),
                                                ),
                                                child: child!,
                                              );
                                            }
                                        );
                                        if (pickedTime != null) setState(() => startTime = pickedTime);
                                      }
                                  );
                                } else {
                                  return _buildMobileFormLayout(
                                      isDarkMode,
                                      nameController,
                                      focusTimeController,
                                      selectedPriority,
                                      startTime,
                                          (newPriority) => setState(() => selectedPriority = newPriority),
                                          () async {
                                        final pickedTime = await showTimePicker(
                                            context: context,
                                            initialTime: startTime ?? TimeOfDay.now(),
                                            builder: (context, child) {
                                              return Theme(
                                                data: Theme.of(context).copyWith(
                                                  timePickerTheme: TimePickerThemeData(
                                                    backgroundColor: isDarkMode ? const Color(0xFF2A2A3A) : Colors.white,
                                                    hourMinuteTextColor: textColor,
                                                    dayPeriodTextColor: textColor,
                                                  ),
                                                ),
                                                child: child!,
                                              );
                                            }
                                        );
                                        if (pickedTime != null) setState(() => startTime = pickedTime);
                                      }
                                  );
                                }
                              }
                          ),
                          const SizedBox(height: 32),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: saveHabit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4B6EFF),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: isDarkMode ? 4 : 2,
                              ),
                              child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
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

  static Widget _buildMobileFormLayout(bool isDarkMode, TextEditingController nameCtrl, TextEditingController timeCtrl, String selectedPriority, TimeOfDay? startTime, Function(String) onPrioritySelect, VoidCallback onTimeTap) {
    final labelColor = isDarkMode ? Colors.white70 : Colors.black87;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormField('Habit Name', nameCtrl, isDarkMode: isDarkMode),
        const SizedBox(height: 16),
        _buildFormField('Focus Time (minutes)', timeCtrl, isDarkMode: isDarkMode, isNumeric: true),
        const SizedBox(height: 16),
        Text('Priority Level', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: labelColor)),
        const SizedBox(height: 8),
        _buildPrioritySelector(selectedPriority, onPrioritySelect, isDarkMode),
        const SizedBox(height: 16),
        Text('Start Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: labelColor)),
        const SizedBox(height: 8),
        _buildTimeSelector(startTime, onTimeTap, isDarkMode),
      ],
    );
  }

  static Widget _buildDesktopFormLayout(bool isDarkMode, TextEditingController nameCtrl, TextEditingController timeCtrl, String selectedPriority, TimeOfDay? startTime, Function(String) onPrioritySelect, VoidCallback onTimeTap) {
    final labelColor = isDarkMode ? Colors.white70 : Colors.black87;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildFormField('Habit Name', nameCtrl, isDarkMode: isDarkMode)),
            const SizedBox(width: 16),
            Expanded(child: _buildFormField('Focus Time (minutes)', timeCtrl, isDarkMode: isDarkMode, isNumeric: true)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Priority Level', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: labelColor)),
                  const SizedBox(height: 8),
                  _buildPrioritySelector(selectedPriority, onPrioritySelect, isDarkMode),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Start Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: labelColor)),
                  const SizedBox(height: 8),
                  _buildTimeSelector(startTime, onTimeTap, isDarkMode),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }

  static Widget _buildFormField(String label, TextEditingController controller, {required bool isDarkMode, bool isNumeric = false}) {
    final labelColor = isDarkMode ? Colors.white70 : Colors.black87;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final hintColor = isDarkMode ? Colors.white38 : Colors.black38;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: labelColor)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            filled: true,
            fillColor: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            hintStyle: TextStyle(color: hintColor),
            errorStyle: TextStyle(color: isDarkMode ? Colors.redAccent : Colors.red),
          ),
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Required';
            if (isNumeric && int.tryParse(value) == null) return 'Invalid number';
            return null;
          },
        ),
      ],
    );
  }

  static Widget _buildPrioritySelector(String selectedPriority, Function(String) onSelect, bool isDarkMode) {
    return Row(
      children: ['High', 'Medium', 'Low'].map((p) => _buildPriorityOption(p, selectedPriority, onSelect, isDarkMode)).toList(),
    );
  }

  static Widget _buildTimeSelector(TimeOfDay? startTime, VoidCallback onTap, bool isDarkMode) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.schedule_rounded, color: isDarkMode ? Colors.white70 : Colors.grey.shade700),
            const SizedBox(width: 12),
            Text(
              startTime != null
                  ? '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}'
                  : 'Select a time',
              style: TextStyle(fontSize: 16, color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildPriorityOption(String priority, String selectedPriority, Function(String) onSelect, bool isDarkMode) {
    final isSelected = selectedPriority.toLowerCase() == priority.toLowerCase();
    final color = _getPriorityColor(priority);
    final unselectedTextColor = isDarkMode ? Colors.white60 : Colors.grey.shade700;

    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(priority),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(isDarkMode ? 0.3 : 0.2) : Colors.transparent,
            border: Border.all(
                color: isSelected ? color : (isDarkMode ? Colors.white24 : Colors.grey.withOpacity(0.3)),
                width: 1.5
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              priority,
              style: TextStyle(
                  color: isSelected ? color : unselectedTextColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'low': return const Color(0xFF4CAF50);
      case 'medium': return const Color(0xFFFFC107);
      case 'high': return const Color(0xFFF44336);
      default: return const Color(0xFF4B6EFF);
    }
  }
}