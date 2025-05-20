import 'package:flutter/material.dart';

class TimerCircle extends StatelessWidget {
  final bool isDarkMode;
  final Color primaryColor;
  final Color accentColor;
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;
  final bool isCompleted;
  final Animation<double> pulseAnimation;
  final Animation<double> completionAnimation;

  const TimerCircle({
    super.key,
    required this.isDarkMode,
    required this.primaryColor,
    required this.accentColor,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isRunning,
    required this.isCompleted,
    required this.pulseAnimation,
    required this.completionAnimation,
  });

  // Format seconds into mm:ss
  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // Calculate progress based on remaining time
    double progress = remainingSeconds / totalSeconds;

    // Determine the color based on progress
    Color progressColor = Color.lerp(
      const Color(0xFFF44336), // Red when low
      const Color(0xFF4B6EFF), // Green when high
      progress,
    ) ?? primaryColor;

    // Use accent color when completed
    if (isCompleted) {
      progressColor = accentColor;
    }

    return AnimatedBuilder(
      animation: isCompleted ? completionAnimation : pulseAnimation,
      builder: (context, child) {
        // Scale effect on completion
        double scale = isCompleted
            ? 1.0 + (completionAnimation.value * 0.1)
            : 1.0;

        // Pulse effect when running
        double pulseEffect = isRunning
            ? 0.1 * pulseAnimation.value
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
                        progressColor.withOpacity(isRunning || isCompleted ? 1.0 : 0.7),
                      ),
                    ),
                  ),
                ),

                // Smaller inner progress ring with different color
                if (isRunning || isCompleted)
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
                        isCompleted
                            ? "COMPLETED"
                            : (isRunning ? "RUNNING" : "PAUSED"),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isCompleted
                              ? progressColor
                              : (isDarkMode ? Colors.white60 : Colors.black45),
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Time display
                      Text(
                        _formatTime(remainingSeconds),
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
                if (isCompleted)
                  ScaleTransition(
                    scale: completionAnimation,
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
}