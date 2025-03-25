import 'package:flutter/material.dart';
import '../services/navigation_service.dart';
import 'package:momentum/core/theme/app_theme.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _habitNameController = TextEditingController();
  final _focusTimeController = TextEditingController();
  String _selectedType = 'High';
  TimeOfDay? _startTime;

  void _showTimePicker() async {
    final initialTime = _startTime ?? TimeOfDay.now();
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppTheme.isDarkMode(context)
                  ? const Color(0xFF1A1A24)
                  : Colors.white,
              hourMinuteTextColor: AppTheme.isDarkMode(context)
                  ? Colors.white
                  : Colors.black87,
              dayPeriodTextColor: AppTheme.isDarkMode(context)
                  ? Colors.white70
                  : Colors.black54,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null && pickedTime != _startTime) {
      setState(() {
        _startTime = pickedTime;
      });
    }
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      // Simulate saving the habit (replace with actual logic)
      print('Habit Name: ${_habitNameController.text}');
      print('Focus Time: ${_focusTimeController.text}');
      print('Type: $_selectedType');
      print('Start Time: ${_startTime?.format(context)}');

      // Navigate back to the previous screen after saving
      NavigationService.goBack(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.isDarkMode(context);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = isDarkMode
        ? const Color(0xFF121117)
        : Colors.white;
    final cardColor = isDarkMode
        ? const Color(0xFF1A1A24)
        : Colors.white;
    final primaryColor = Colors.blueAccent;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Add New Habit',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => NavigationService.goBack(context),
        ),
      ),
      body: Container(
        decoration: isDarkMode
            ? const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF121117),
              Color(0xFF1A1A24),
            ],
          ),
        )
            : const BoxDecoration(
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and description
                Text(
                  'Create a new habit',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fill in the details below to add a new habit to track',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),

                // Habit Name
                _buildFormLabel('Habit Name', textColor),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _habitNameController,
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
                const SizedBox(height: 24),

                // Focus Time
                _buildFormLabel('Focus Time (minutes)', textColor),
                const SizedBox(height: 8),
                _buildTextField(
                  controller: _focusTimeController,
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
                const SizedBox(height: 24),

                // Type Selection
                _buildFormLabel('Priority Level', textColor),
                const SizedBox(height: 16),
                _buildPrioritySelector(isDarkMode, textColor),
                const SizedBox(height: 24),

                // Start Time
                _buildFormLabel('Start Time', textColor),
                const SizedBox(height: 8),
                _buildTimeSelector(isDarkMode, textColor, primaryColor),
                const SizedBox(height: 40),

                // Done Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveHabit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Save Habit',
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
  }

  Widget _buildFormLabel(String label, Color textColor) {
    return Text(
      label,
      style: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required bool isDarkMode,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.white38 : Colors.black38,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: isDarkMode ? Colors.white54 : Colors.black54,
        ),
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF252836) : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPrioritySelector(bool isDarkMode, Color textColor) {
    final selectedColor = Colors.blueAccent;
    final unselectedColor = isDarkMode ? Colors.white30 : Colors.black26;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPriorityOption('Low', Colors.green, isDarkMode, textColor),
        _buildPriorityOption('Medium', Colors.orange, isDarkMode, textColor),
        _buildPriorityOption('High', Colors.red, isDarkMode, textColor),
      ],
    );
  }

  Widget _buildPriorityOption(String label, Color color, bool isDarkMode, Color textColor) {
    final isSelected = _selectedType == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = label;
        });
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? color.withOpacity(0.3) : color.withOpacity(0.1))
              : (isDarkMode ? const Color(0xFF252836) : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _getPriorityIcon(label),
              color: isSelected ? color : (isDarkMode ? Colors.white54 : Colors.black54),
              size: 22,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'Low':
        return Icons.arrow_downward;
      case 'Medium':
        return Icons.remove;
      case 'High':
        return Icons.arrow_upward;
      default:
        return Icons.remove;
    }
  }

  Widget _buildTimeSelector(bool isDarkMode, Color textColor, Color primaryColor) {
    return GestureDetector(
      onTap: _showTimePicker,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF252836) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: isDarkMode ? Colors.white54 : Colors.black54,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _startTime != null
                    ? _startTime!.format(context)
                    : 'Select a time',
                style: TextStyle(
                  color: _startTime != null
                      ? textColor
                      : (isDarkMode ? Colors.white38 : Colors.black38),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDarkMode ? Colors.white30 : Colors.black26,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}