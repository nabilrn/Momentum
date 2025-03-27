import 'package:flutter/material.dart';
import '../services/navigation_service.dart';
import 'package:momentum/core/theme/app_theme.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _habitNameController = TextEditingController();
  final _focusTimeController = TextEditingController();
  String _selectedType = 'High';
  TimeOfDay? _startTime;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _habitNameController.dispose();
    _focusTimeController.dispose();
    super.dispose();
  }

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
              dialBackgroundColor: AppTheme.isDarkMode(context)
                  ? const Color(0xFF252836)
                  : Colors.grey.shade100,
              dialHandColor: const Color(0xFF4B6EFF),
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4B6EFF),
              brightness: AppTheme.isDarkMode(context) ? Brightness.dark : Brightness.light,
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
      // Create visual feedback with a temporary overlay
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Habit saved successfully!'),
          backgroundColor: const Color(0xFF4B6EFF),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        ),
      );

      // Simulate saving the habit
      print('Habit Name: ${_habitNameController.text}');
      print('Focus Time: ${_focusTimeController.text}');
      print('Type: $_selectedType');
      print('Start Time: ${_startTime?.format(context)}');

      // Navigate back with a short delay for animation
      Future.delayed(const Duration(milliseconds: 300), () {
        NavigationService.goBack(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.isDarkMode(context);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = isDarkMode ? const Color(0xFF121117) : Colors.white;
    final primaryColor = const Color(0xFF4B6EFF);
    final accentColor = const Color(0xFF6C4BFF);

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true,
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
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF121117),
              Color(0xFF1A1A24),
            ],
          )
              : LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Colors.white,
              const Color(0xFFF5F7FF),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24.0, 100.0, 24.0, 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Decorative Element
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? primaryColor.withOpacity(0.1)
                            : primaryColor.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        color: primaryColor.withOpacity(0.7),
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title and description
                  Text(
                    'Create a new habit',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Fill in the details below to add a new habit to track',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Habit Name
                  _buildFormLabel('Habit Name', textColor, Icons.edit_rounded),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 28),

                  // Focus Time
                  _buildFormLabel('Focus Time (minutes)', textColor, Icons.hourglass_top_rounded),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 28),

                  // Type Selection
                  _buildFormLabel('Priority Level', textColor, Icons.flag_rounded),
                  const SizedBox(height: 16),
                  _buildPrioritySelector(isDarkMode, textColor, primaryColor),
                  const SizedBox(height: 28),

                  // Start Time
                  _buildFormLabel('Start Time', textColor, Icons.schedule_rounded),
                  const SizedBox(height: 12),
                  _buildTimeSelector(isDarkMode, textColor, primaryColor),
                  const SizedBox(height: 48),

                  // Save Button
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      gradient: LinearGradient(
                        colors: [accentColor, primaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: _saveHabit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Save Habit',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormLabel(String label, Color textColor, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF4B6EFF),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.white38 : Colors.black38,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: const Color(0xFF4B6EFF),
          size: 22,
        ),
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF252836) : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: const Color(0xFF4B6EFF),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        errorStyle: const TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.w500,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildPrioritySelector(bool isDarkMode, Color textColor, Color primaryColor) {
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDarkMode ? color.withOpacity(0.3) : color.withOpacity(0.15))
            : (isDarkMode ? const Color(0xFF252836) : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? color : Colors.transparent,
          width: 2,
        ),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          )
        ]
            : null,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedType = label;
          });
        },
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            Icon(
              _getPriorityIcon(label),
              color: isSelected ? color : (isDarkMode ? Colors.white54 : Colors.black54),
              size: 24,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
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
        return Icons.arrow_downward_rounded;
      case 'Medium':
        return Icons.remove_rounded;
      case 'High':
        return Icons.arrow_upward_rounded;
      default:
        return Icons.remove_rounded;
    }
  }

  Widget _buildTimeSelector(bool isDarkMode, Color textColor, Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF252836) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _startTime != null
              ? primaryColor.withOpacity(0.5)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showTimePicker,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: _startTime != null
                      ? primaryColor
                      : (isDarkMode ? Colors.white54 : Colors.black54),
                  size: 22,
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
                      fontSize: 16,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isDarkMode ? Colors.white38 : Colors.black38,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}