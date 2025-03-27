import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../services/navigation_service.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with TickerProviderStateMixin {
  // Timer state
  bool _isRunning = false;
  bool _isCompleted = false;
  int _totalSeconds = 15 * 60; // 15 minutes in seconds
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

  // Format seconds into mm:ss
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
            _buildAppBar(isDarkMode),

            // Progress and timer display
            Expanded(
              child: Center(
                child: _buildTimerCircle(isDarkMode, primaryColor, accentColor),
              ),
            ),

            // Control buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildControls(isDarkMode, primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [

          IconButton(
            onPressed: () => NavigationService.goBack(context),
            icon: Icon(
              Icons.arrow_back,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),

          Expanded(
            child: Column(
              children: [
                Text(
                  "Morning Meditation",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '15 minutes of focused activity',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Placeholder for balance
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildTimerCircle(bool isDarkMode, Color primaryColor, Color accentColor) {
    // Calculate progress based on remaining time
    double progress = _remainingSeconds / _totalSeconds;

    // Determine the color based on progress
    Color progressColor = Color.lerp(
      const Color(0xFFF44336), // Red when low
      const Color(0xFF4CAF50), // Green when high
      progress,
    ) ?? primaryColor;

    // Use accent color when completed
    if (_isCompleted) {
      progressColor = accentColor;
    }

    return AnimatedBuilder(
      animation: _isCompleted ? _completionAnimation : _pulseAnimation,
      builder: (context, child) {
        // Scale effect on completion
        double scale = _isCompleted
            ? 1.0 + (_completionAnimation.value * 0.1)
            : 1.0;

        // Pulse effect when running
        double pulseEffect = _isRunning
            ? 0.1 * _pulseAnimation.value
            : 0;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDarkMode
                  ? const Color(0xFF252836).withOpacity(0.7)
                  : Colors.grey.shade50,
              boxShadow: [
                BoxShadow(
                  color: progressColor.withOpacity(0.2 + pulseEffect),
                  blurRadius: 20 + (pulseEffect * 30),
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background track
                Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.shade100,
                  ),
                ),

                // Progress indicator - use animated rotation for effect
                SizedBox(
                  width: 240,
                  height: 240,
                  child: Transform.rotate(
                    angle: -3.14 / 2, // Start from top
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 14,
                      backgroundColor: isDarkMode
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progressColor.withOpacity(_isRunning || _isCompleted ? 1.0 : 0.7),
                      ),
                    ),
                  ),
                ),

                // Smaller inner progress ring with different color
                if (_isRunning || _isCompleted)
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Transform.rotate(
                      angle: 3.14 / 2, // Counter-rotate for effect
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 4,
                        backgroundColor: Colors.transparent,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          accentColor.withOpacity(0.7),
                        ),
                      ),
                    ),
                  ),

                // Timer display circle
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDarkMode
                          ? [const Color(0xFF2A2C3E), const Color(0xFF252836)]
                          : [Colors.white, Colors.grey.shade50],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: -5,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Status indicator
                      Text(
                        _isCompleted
                            ? "COMPLETED"
                            : (_isRunning ? "RUNNING" : "PAUSED"),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _isCompleted
                              ? progressColor
                              : (isDarkMode ? Colors.white60 : Colors.black45),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Time display
                      Text(
                        _formatTime(_remainingSeconds),
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),

                      // Percentage display
                      Text(
                        "${(progress * 100).toInt()}%",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: progressColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Completed checkmark
                if (_isCompleted)
                  ScaleTransition(
                    scale: _completionAnimation,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls(bool isDarkMode, Color primaryColor) {
    return Column(
      children: [
        // Completed message
        if (_isCompleted)
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4B6EFF), Color(0xFF6C4BFF)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.celebration,
                    color: Colors.white,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Great job! You completed this habit.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Reset button
            _buildActionButton(
              'Reset',
              Icons.refresh,
              primaryColor,
              isDarkMode,
              _resetTimer,
              isOutlined: true,
            ),

            const SizedBox(width: 16),

            // Start/Pause button
            _buildActionButton(
              _isRunning ? 'Pause' : (_isCompleted ? 'Done' : 'Start'),
              _isRunning ? Icons.pause : (_isCompleted ? Icons.check : Icons.play_arrow),
              primaryColor,
              isDarkMode,
              _toggleTimer,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String label,
      IconData icon,
      Color color,
      bool isDarkMode,
      VoidCallback onPressed, {
        bool isOutlined = false,
      }) {
    return Expanded(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: isOutlined
              ? null
              : const LinearGradient(
            colors: [
              Color(0xFF4B6EFF),
              Color(0xFF3B5AF8),
            ],
          ),
          color: isOutlined ? Colors.transparent : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isOutlined
              ? null
              : [
            BoxShadow(
              color: const Color(0xFF4B6EFF).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: isOutlined
              ? Border.all(
            color: isDarkMode ? Colors.white24 : Colors.black12,
            width: 2,
          )
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: isOutlined
                        ? (isDarkMode ? Colors.white : Colors.black)
                        : Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      color: isOutlined
                          ? (isDarkMode ? Colors.white : Colors.black)
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
}