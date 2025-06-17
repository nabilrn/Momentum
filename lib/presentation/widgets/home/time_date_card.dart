import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class TimeDateCard extends StatefulWidget {
  const TimeDateCard({super.key});

  @override
  State<TimeDateCard> createState() => _TimeDateCardState();
}

class _TimeDateCardState extends State<TimeDateCard> {
  late DateTime _currentTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    // Update time every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Make sure to cancel the timer to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) {
          // Determine if we're in a very narrow container
          final isNarrow = constraints.maxWidth < 200;
          final isSuperNarrow = constraints.maxWidth < 120;

          return _buildCard(context, isNarrow, isSuperNarrow);
        }
    );
  }

  Widget _buildCard(BuildContext context, bool isNarrow, bool isSuperNarrow) {
    final isDarkMode = AppTheme.isDarkMode(context);
    final primaryColor = const Color(0xFF4B6EFF);

    // Format the current time and date
    final formattedDay = DateFormat('EEEE').format(_currentTime);
    final formattedDate = DateFormat('MMMM d').format(_currentTime);
    final formattedTime = DateFormat('HH:mm:ss').format(_currentTime);

    return Padding(
      padding: EdgeInsets.all(isNarrow ? 8.0 : 16.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isNarrow ? 12.0 : 20.0),
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E1E2C),
              Color(0xFF0D0D15),
            ],
          )
              : null,
          color: isDarkMode ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: isDarkMode
              ? Border.all(color: Colors.white.withOpacity(0.03))
              : Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Day label - use FittedBox to prevent overflow
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formattedDay.toUpperCase(),
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontSize: isSuperNarrow ? 10 : 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  SizedBox(height: isNarrow ? 5 : 10),

                  // Time display - wrapped in FittedBox
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formattedTime.substring(0, 5), // Hours and minutes
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: isNarrow ? 20 : 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 2),
                        if (!isSuperNarrow) Text(
                          formattedTime.substring(5), // Seconds
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: isNarrow ? 12 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isNarrow ? 3 : 6),

                  // Date - also in FittedBox
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formattedDate,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                        fontSize: isNarrow ? 12 : 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Only show icon if we have enough space
            if (!isSuperNarrow) Container(
              width: isNarrow ? 40 : 60,
              height: isNarrow ? 40 : 60,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.schedule,
                size: isNarrow ? 20 : 28,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}