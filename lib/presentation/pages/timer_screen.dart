import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/timer/timer_app_bar.dart';
import '../widgets/timer/timer_circle.dart';
import '../widgets/timer/timer_controls.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  // Timer state
  bool _isRunning = false;
  bool _isCompleted = false;
  final int _totalSeconds = 15 * 60; // 15 minutes in seconds
  int _remainingSeconds = 15 * 60;
  Timer? _timer;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _completionController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _completionAnimation;

  @override
  void initState() {
    super.initState();
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

    _completionController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = AppTheme.isDarkMode(context);
    final primaryColor = const Color(0xFF4B6EFF);
    final accentColor = const Color(0xFF6C4BFF);
    final backgroundColor = isDarkMode ? const Color(0xFF1E1E2C) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // App bar with back button and habit title
            TimerAppBar(
              title: "Morning Meditation",
              subtitle: "15 minutes of focused activity",
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}