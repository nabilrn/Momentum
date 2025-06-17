// lib/presentation/dialogs/edit_habit_dialog.dart

import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'package:momentum/data/models/habit_model.dart';
import 'package:momentum/presentation/controllers/habit_controller.dart';
import 'package:provider/provider.dart';

// Helper String
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class EditHabitDialog {
  static void show(BuildContext context, Map<String, dynamic> habit, {Function? onHabitUpdated}) {
    final isDarkMode = AppTheme.isDarkMode(context);
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
        // StatefulBuilder diperlukan agar state di dalam dialog (seperti waktu) bisa di-update
        return StatefulBuilder(
          builder: (context, setState) {

            // REFACTOR: Method save habit dibuat lebih aman dan menggunakan async/await
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

              // Tampilkan loading indicator
              showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator()));

              final habitModel = HabitModel(
                id: habit['id'],
                name: nameController.text,
                focusTimeMinutes: focusTime,
                priority: selectedPriority.toLowerCase(),
                startTime: startTime != null
                    ? "${startTime?.hour.toString().padLeft(2, '0')}:${startTime?.minute.toString().padLeft(2, '0')}"
                    : null,
                userId: habit['userId'],
              );

              final updatedHabit = await controller.updateHabit(habitModel);

              if (!context.mounted) return;

              Navigator.pop(context); // Tutup loading indicator

              if (updatedHabit != null) {
                if (onHabitUpdated != null) onHabitUpdated();
                await controller.loadHabits();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Habit updated successfully!'), backgroundColor: Colors.green),
                );
                Navigator.pop(context); // Tutup dialog edit
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${controller.error ?? "Failed to update"}'), backgroundColor: Colors.red),
                );
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              backgroundColor: Colors.transparent,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600), // Batasi lebar dialog
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1A1A24) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
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
                              const Expanded(
                                child: Text('Edit Habit', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              ),
                              IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(Icons.close_rounded, color: isDarkMode ? Colors.white60 : Colors.black45),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // REFACTOR: Layout form akan beradaptasi dengan lebar layar
                          LayoutBuilder(
                              builder: (context, constraints) {
                                if (constraints.maxWidth > 500) {
                                  // Tampilan desktop/web dengan 2 kolom
                                  return _buildDesktopFormLayout(
                                      isDarkMode, nameController, focusTimeController,
                                      selectedPriority, startTime,
                                          (newPriority) => setState(() => selectedPriority = newPriority),
                                          () async {
                                        final pickedTime = await showTimePicker(context: context, initialTime: startTime ?? TimeOfDay.now());
                                        if (pickedTime != null) setState(() => startTime = pickedTime);
                                      }
                                  );
                                } else {
                                  // Tampilan mobile dengan 1 kolom
                                  return _buildMobileFormLayout(
                                      isDarkMode, nameController, focusTimeController,
                                      selectedPriority, startTime,
                                          (newPriority) => setState(() => selectedPriority = newPriority),
                                          () async {
                                        final pickedTime = await showTimePicker(context: context, initialTime: startTime ?? TimeOfDay.now());
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

  // NEW: Layout form 1 kolom untuk mobile
  static Widget _buildMobileFormLayout(bool isDarkMode, TextEditingController nameCtrl, TextEditingController timeCtrl, String selectedPriority, TimeOfDay? startTime, Function(String) onPrioritySelect, VoidCallback onTimeTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFormField('Habit Name', nameCtrl, isDarkMode: isDarkMode),
        const SizedBox(height: 16),
        _buildFormField('Focus Time (minutes)', timeCtrl, isDarkMode: isDarkMode, isNumeric: true),
        const SizedBox(height: 16),
        const Text('Priority Level', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildPrioritySelector(selectedPriority, onPrioritySelect),
        const SizedBox(height: 16),
        const Text('Start Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        _buildTimeSelector(startTime, onTimeTap, isDarkMode),
      ],
    );
  }

  // NEW: Layout form 2 kolom untuk desktop/web
  static Widget _buildDesktopFormLayout(bool isDarkMode, TextEditingController nameCtrl, TextEditingController timeCtrl, String selectedPriority, TimeOfDay? startTime, Function(String) onPrioritySelect, VoidCallback onTimeTap) {
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
                  const Text('Priority Level', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  _buildPrioritySelector(selectedPriority, onPrioritySelect),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Start Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            filled: true,
            fillColor: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

  static Widget _buildPrioritySelector(String selectedPriority, Function(String) onSelect) {
    return Row(
      children: ['High', 'Medium', 'Low'].map((p) => _buildPriorityOption(p, selectedPriority, onSelect)).toList(),
    );
  }

  static Widget _buildTimeSelector(TimeOfDay? startTime, VoidCallback onTap, bool isDarkMode) {
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
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildPriorityOption(String priority, String selectedPriority, Function(String) onSelect) {
    // ... (kode helper tidak berubah)
    final isSelected = selectedPriority.toLowerCase() == priority.toLowerCase();
    final color = _getPriorityColor(priority);
    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(priority),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            border: Border.all(color: isSelected ? color : Colors.grey.withOpacity(0.3), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              priority,
              style: TextStyle(color: isSelected ? color : Colors.grey, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
            ),
          ),
        ),
      ),
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
}