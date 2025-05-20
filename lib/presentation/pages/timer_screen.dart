import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import 'package:momentum/data/models/habit_model.dart';
import '../controllers/habit_controller.dart';
import '../widgets/timer/timer_app_bar.dart';
import '../widgets/timer/timer_circle.dart';
import '../widgets/timer/timer_controls.dart';
import '../utils/color_util_random.dart'; // Added ColorUtils import
import 'package:momentum/core/services/habit_completion_service.dart';
import 'package:momentum/data/datasources/supabase_datasource.dart';

class TimerScreen extends StatefulWidget {
  final String? habitId;

  const TimerScreen({super.key, this.habitId});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  // Timer state
  bool _isRunning = false;
  bool _isCompleted = false;
  late int _totalSeconds;
  late int _remainingSeconds;
  Timer? _timer;
  HabitModel? _habit;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _completionController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _completionAnimation;

  @override
  void initState() {
    super.initState();
    // Default values in case habit is not found
    _totalSeconds = 15 * 60;
    _remainingSeconds = _totalSeconds;

    // Pulse animation for the timer circle
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_pulseController);

    // One-time animation for completion
    _completionController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _completionAnimation = CurvedAnimation(
      parent: _completionController,
      curve: Curves.easeOutBack,
    );

    // Load habit data in the next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHabitData();
    });
  }

  void _loadHabitData() {
    if (widget.habitId != null) {
      final habitController = Provider.of<HabitController>(context, listen: false);
      final habit = habitController.getHabitById(widget.habitId!);

      if (habit != null) {
        setState(() {
          _habit = habit;
          // Convert minutes to seconds for the timer
          _totalSeconds = habit.focusTimeMinutes * 60;
          _remainingSeconds = _totalSeconds;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _completionController.dispose();
    super.dispose();
  }

  // Start or pause the timer
  void _toggleTimer() {
    HapticFeedback.mediumImpact();

    if (_isCompleted) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isRunning = !_isRunning;
    });

    if (_isRunning) {
      _startTimer();
    } else {
      _pauseTimer();
    }
  }

  // Reset the timer
  void _resetTimer() {
    HapticFeedback.lightImpact();

    _timer?.cancel();
    setState(() {
      _remainingSeconds = _totalSeconds;
      _isRunning = false;
      _isCompleted = false;
    });
    _completionController.reset();
  }

  // Start the countdown timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _completeTimer();
      }
    });
  }

  // Pause the timer
  void _pauseTimer() {
    _timer?.cancel();
  }

  // Handle timer completion
  void _completeTimer() {
    _timer?.cancel();
    HapticFeedback.heavyImpact();

    setState(() {
      _isRunning = false;
      _isCompleted = true;
    });

    // Catat habit completion jika habit tersedia
    if (_habit != null) {
      final habitCompletionService = HabitCompletionService(SupabaseDataSource());
      habitCompletionService.recordCompletion(_habit!.id!);
    }

    _completionController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = AppTheme.isDarkMode(context);

    // Get color based on habit priority or use default
    final primaryColor = _habit != null
        ? ColorUtils.getPriorityColor(_habit!.priority)
        : const Color(0xFF4B6EFF);

    // Create a slightly different accent color based on the primary
    final accentColor = _habit != null
        ? ColorUtils.getPriorityColor(_habit!.priority).withOpacity(0.8)
        : const Color(0xFF6C4BFF);

    final backgroundColor = isDarkMode ? const Color(0xFF1E1E2C) : Colors.white;

    // Get formatted time for subtitle
    final int minutes = (_totalSeconds / 60).floor();
    final String timeText = "$minutes minutes of focused activity";

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // App bar with back button and habit title
            TimerAppBar(
              title: _habit?.name ?? "Focus Timer",
              subtitle: timeText,
              isDarkMode: isDarkMode,
            ),

            // Progress and timer display
            Expanded(
              child: Center(
                child: TimerCircle(
                  isDarkMode: isDarkMode,
                  primaryColor: primaryColor,
                  accentColor: accentColor,
                  remainingSeconds: _remainingSeconds,
                  totalSeconds: _totalSeconds,
                  isRunning: _isRunning,
                  isCompleted: _isCompleted,
                  pulseAnimation: _pulseAnimation,
                  completionAnimation: _completionAnimation,
                ),
              ),
            ),

            // Control buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: TimerControls(
                isRunning: _isRunning,
                isCompleted: _isCompleted,
                isDarkMode: isDarkMode,
                primaryColor: primaryColor,
                onReset: _resetTimer,
                onToggle: _toggleTimer,
                onNavigateToHome: () {
                  Navigator.of(context).pushReplacementNamed('/home'); // Navigate to home
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}