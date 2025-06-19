import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import '../widgets/add_habit/form_label.dart';
import '../widgets/add_habit/custom_text_field.dart';
import '../widgets/add_habit/priority_selector.dart';
import '../widgets/add_habit/time_selector.dart';
import 'package:momentum/presentation/controllers/habit_controller.dart';
import 'package:provider/provider.dart';
import 'package:momentum/presentation/services/navigation_service.dart';
import '../utils/platform_helper.dart';

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
  bool _isSaving = false; // REFACTOR: State to handle loading on the button itself

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

  // REFACTOR: Converted to async/await for better readability and state handling.
  Future<void> _saveHabit() async {
    // FIX: Safer form validation
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // FIX: Safer integer parsing
    final focusTime = int.tryParse(_focusTimeController.text);
    if (focusTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Focus time must be a valid number.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final controller = Provider.of<HabitController>(context, listen: false);

    final habit = await controller.createHabit(
      name: _habitNameController.text,
      focusTimeMinutes: focusTime,
      priority: _selectedType.toLowerCase(),
      startTime: _startTime,
    );

    // FIX: Check if the widget is still mounted before using its context.
    if (!mounted) return;

    setState(() => _isSaving = false);

    if (habit != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Habit saved successfully!'),
          backgroundColor: const Color(0xFF4CAF50), // Green for success
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        ),
      );
      NavigationService.goBack(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${controller.error ?? "Failed to save habit"}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.isDarkMode(context);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = isDarkMode ? const Color(0xFF121117) : Color.fromARGB(255, 244, 245, 247);
    final primaryColor = const Color(0xFF4B6EFF);
    final accentColor = const Color(0xFF6C4BFF);
    final screenWidth = MediaQuery.of(context).size.width;
    final useDesktopLayout = PlatformHelper.isDesktop || screenWidth > 768;

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
            colors: [Color(0xFF121117), Color(0xFF1A1A24)],
          )
              : const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.white, Color(0xFFF5F7FF)],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                useDesktopLayout ? screenWidth * 0.1 : 24.0,
                useDesktopLayout ? 80.0 : 100.0,
                useDesktopLayout ? screenWidth * 0.1 : 24.0,
                24.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: useDesktopLayout ? 900 : double.infinity,
                ),
                child: Card(
                  color: isDarkMode ? const Color(0xFF1E1E2C) : Colors.white,
                  elevation: isDarkMode ? 0 : 5,
                  shadowColor: isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isDarkMode
                        ? BorderSide(color: Colors.white.withOpacity(0.05))
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Form(
                      key: _formKey,
                      child: useDesktopLayout
                          ? _buildDesktopLayout(isDarkMode, textColor, primaryColor, accentColor)
                          : _buildMobileLayout(isDarkMode, textColor, primaryColor, accentColor),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(bool isDarkMode, Color textColor, Color primaryColor, Color accentColor) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Make column only as tall as its content
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                ],
              ),
            ),
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.fitness_center,
                color: primaryColor.withOpacity(0.7),
                size: 40,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormLabel(label: 'Habit Name', textColor: textColor, icon: Icons.edit_rounded),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _habitNameController,
                    hintText: 'e.g., Morning Meditation',
                    prefixIcon: Icons.lightbulb_outline,
                    isDarkMode: isDarkMode,
                    validator: (value) => (value == null || value.isEmpty) ? 'Please enter a habit name' : null,
                  ),
                  const SizedBox(height: 28),
                  FormLabel(label: 'Focus Time (minutes)', textColor: textColor, icon: Icons.hourglass_top_rounded),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: _focusTimeController,
                    hintText: 'e.g., 30',
                    prefixIcon: Icons.timer_outlined,
                    keyboardType: TextInputType.number,
                    isDarkMode: isDarkMode,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter focus time';
                      if (int.tryParse(value) == null) return 'Please enter a valid number';
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormLabel(label: 'Priority Level', textColor: textColor, icon: Icons.flag_rounded),
                  const SizedBox(height: 16),
                  PrioritySelector(
                    isDarkMode: isDarkMode,
                    textColor: textColor,
                    selectedType: _selectedType,
                    onPrioritySelected: (type) => setState(() => _selectedType = type),
                  ),
                  const SizedBox(height: 28),
                  FormLabel(label: 'Start Time', textColor: textColor, icon: Icons.schedule_rounded),
                  const SizedBox(height: 12),
                  TimeSelector(
                    isDarkMode: isDarkMode,
                    textColor: textColor,
                    primaryColor: primaryColor,
                    selectedTime: _startTime,
                    onTap: _showTimePicker,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        Align(
          alignment: Alignment.center,
          child: _buildSaveButton(primaryColor, accentColor),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(bool isDarkMode, Color textColor, Color primaryColor, Color accentColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            height: 80, width: 80,
            decoration: BoxDecoration(
              color: isDarkMode ? primaryColor.withOpacity(0.1) : primaryColor.withOpacity(0.07),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.fitness_center, color: primaryColor.withOpacity(0.7), size: 40),
          ),
        ),
        const SizedBox(height: 16),
        Text('Create a new habit', style: TextStyle(color: textColor, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Text('Fill in the details below to add a new habit to track', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54, fontSize: 16)),
        const SizedBox(height: 40),
        FormLabel(label: 'Habit Name', textColor: textColor, icon: Icons.edit_rounded),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _habitNameController,
          hintText: 'e.g., Morning Meditation',
          prefixIcon: Icons.lightbulb_outline,
          isDarkMode: isDarkMode,
          validator: (value) => (value == null || value.isEmpty) ? 'Please enter a habit name' : null,
        ),
        const SizedBox(height: 28),
        FormLabel(label: 'Focus Time (minutes)', textColor: textColor, icon: Icons.hourglass_top_rounded),
        const SizedBox(height: 12),
        CustomTextField(
          controller: _focusTimeController,
          hintText: 'e.g., 30',
          prefixIcon: Icons.timer_outlined,
          keyboardType: TextInputType.number,
          isDarkMode: isDarkMode,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Please enter focus time';
            if (int.tryParse(value) == null) return 'Please enter a valid number';
            return null;
          },
        ),
        const SizedBox(height: 28),
        FormLabel(label: 'Priority Level', textColor: textColor, icon: Icons.flag_rounded),
        const SizedBox(height: 16),
        PrioritySelector(
          isDarkMode: isDarkMode,
          textColor: textColor,
          selectedType: _selectedType,
          onPrioritySelected: (type) => setState(() => _selectedType = type),
        ),
        const SizedBox(height: 28),
        FormLabel(label: 'Start Time', textColor: textColor, icon: Icons.schedule_rounded),
        const SizedBox(height: 12),
        TimeSelector(
          isDarkMode: isDarkMode,
          textColor: textColor,
          primaryColor: primaryColor,
          selectedTime: _startTime,
          onTap: _showTimePicker,
        ),
        const SizedBox(height: 48),
        _buildSaveButton(primaryColor, accentColor),
      ],
    );
  }

  // NEW: Extracted button to a separate widget to reduce code duplication.
  Widget _buildSaveButton(Color primaryColor, Color accentColor) {
    return Container(
      width: double.infinity, // Make button full width on mobile, and respect parent on desktop
      constraints: const BoxConstraints(maxWidth: 220), // Max width for desktop
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: _isSaving ? [] : [ // No shadow when loading
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
        onPressed: _isSaving ? null : _saveHabit, // Disable button when saving
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          disabledForegroundColor: Colors.white70, // Style for disabled state
        ),
        child: _isSaving
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Save Habit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded),
          ],
        ),
      ),
    );
  }
}