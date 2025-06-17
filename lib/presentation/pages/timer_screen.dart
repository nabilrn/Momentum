import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb; // Import for web check
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart' as audio;
import 'package:momentum/presentation/services/navigation_service.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import 'package:momentum/data/models/habit_model.dart';
import '../controllers/habit_controller.dart';
import '../widgets/timer/timer_app_bar.dart'; // DIKEMBALIKAN: Import untuk TimerAppBar
import '../widgets/timer/timer_circle.dart';
import '../widgets/timer/timer_controls.dart';
import '../utils/color_util_random.dart';
import 'package:momentum/core/services/habit_completion_service.dart';
import 'package:momentum/data/datasources/supabase_datasource.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;

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

  // Sound and notification variables
  final _audioPlayer = audio.AudioPlayer();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _totalSeconds = 15 * 60;
    _remainingSeconds = _totalSeconds;

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_pulseController);

    _completionController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _completionAnimation = CurvedAnimation(
      parent: _completionController,
      curve: Curves.easeOutBack,
    );

    _initializeNotifications();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHabitData();
    });
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  void _loadHabitData() {
    if (widget.habitId != null) {
      final habitController = Provider.of<HabitController>(context, listen: false);
      final habit = habitController.getHabitById(widget.habitId!);

      if (habit != null) {
        setState(() {
          _habit = habit;
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
    _audioPlayer.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    HapticFeedback.mediumImpact();
    if (_isCompleted) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _isRunning = !_isRunning);
    if (_isRunning) _startTimer();
    else _pauseTimer();
  }

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

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _completeTimer();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
  }

  void _completeTimer() {
    _timer?.cancel();
    HapticFeedback.heavyImpact();
    _playAlarmSound();
    _showCompletionNotification();
    setState(() {
      _isRunning = false;
      _isCompleted = true;
    });
    if (_habit?.id != null) {
      final habitCompletionService = HabitCompletionService(SupabaseDataSource());
      habitCompletionService.recordCompletion(_habit!.id);
    }
    _completionController.forward();
  }

  Future<void> _playAlarmSound() async {
    try {
      await _audioPlayer.setAsset('assets/audio/alarm.mp3');
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing sound: $e');
      if (!kIsWeb) {
        HapticFeedback.vibrate();
      }
    }
  }

  Future<void> _showCompletionNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'timer_channel',
      'Timer Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true, presentBadge: true, presentSound: true,
    );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails, iOS: iosDetails,
    );
    await _notificationsPlugin.show(
      0,
      _habit?.name ?? "Focus Timer",
      "Time's up! You've completed your focus session.",
      details,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = AppTheme.isDarkMode(context);
    final primaryColor = _habit != null ? ColorUtils.getPriorityColor(_habit!.priority) : const Color(0xFF4B6EFF);
    final accentColor = _habit != null ? ColorUtils.getPriorityColor(_habit!.priority).withOpacity(0.8) : const Color(0xFF6C4BFF);
    final backgroundColor = isDarkMode ? const Color(0xFF1E1E2C) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return _buildDesktopLayout(isDarkMode, primaryColor, accentColor);
          } else {
            return _buildMobileLayout(isDarkMode, primaryColor, accentColor);
          }
        },
      ),
    );
  }

  /// DIKEMBALIKAN: Layout untuk Mobile dikembalikan ke versi asli Anda.
  Widget _buildMobileLayout(bool isDarkMode, Color primaryColor, Color accentColor) {
    final String timeText = "${(_totalSeconds / 60).floor()} minutes of focused activity";
    return SafeArea(
      child: Column(
        children: [
          TimerAppBar(
            title: _habit?.name ?? "Focus Timer",
            subtitle: timeText,
            isDarkMode: isDarkMode,
          ),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
            child: TimerControls(
              isRunning: _isRunning,
              isCompleted: _isCompleted,
              isDarkMode: isDarkMode,
              primaryColor: primaryColor,
              onReset: _resetTimer,
              onToggle: _toggleTimer,
              onNavigateToHome: () => Navigator.of(context).pushReplacementNamed('/home'),
            ),
          ),
        ],
      ),
    );
  }

  /// FIX: Layout untuk Desktop/Web kini memiliki tombol kembali.
  Widget _buildDesktopLayout(bool isDarkMode, Color primaryColor, Color accentColor) {
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    return SafeArea(
      child: Column(
        children: [
          // Top navigation bar with back button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDarkMode ? Colors.white70 : Colors.black87,
                size: 24,
              ),
              onPressed: () {
                // Use a more reliable navigation method for web
                NavigationService.goBack(context);
              },
              tooltip: "Back",
            ),
          ),

          // Main content - centered card
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900, maxHeight: 450),
                  child: Card(
                    color: isDarkMode ? const Color(0xFF1A1A24) : Colors.white,
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: isDarkMode ? BorderSide(color: Colors.white.withOpacity(0.1)) : BorderSide.none,
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          // Left Column: Timer Circle
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.black.withOpacity(0.1) : primaryColor.withOpacity(0.05),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                ),
                              ),
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
                          // Right Column: Info and Controls
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _habit?.name ?? "Focus Timer",
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "${(_totalSeconds / 60).floor()} minutes of focused activity",
                                    style: TextStyle(
                                      color: textColor.withOpacity(0.7),
                                      fontSize: 16,
                                    ),
                                  ),
                                  const Spacer(),
                                  TimerControls(
                                    isRunning: _isRunning,
                                    isCompleted: _isCompleted,
                                    isDarkMode: isDarkMode,
                                    primaryColor: primaryColor,
                                    onReset: _resetTimer,
                                    onToggle: _toggleTimer,
                                    onNavigateToHome: () => Navigator.of(context).pop(),
                                    isDesktop: true,
                                  ),
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
            ),
          ),
        ],
      ),
    );
  }
}