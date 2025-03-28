import 'package:flutter/material.dart';

class WeeklyChart extends StatelessWidget {
  final bool isDarkMode;
  final Color primaryColor;
  final Color secondaryTextColor;
  final List<Map<String, dynamic>> weeklyData;

  const WeeklyChart({
    super.key,
    required this.isDarkMode,
    required this.primaryColor,
    required this.secondaryTextColor,
    required this.weeklyData,
  });

  // Get color based on completion percentage
  Color _getCompletionColor(double percentage) {
    if (percentage >= 0.7) return const Color(0xFF4CAF50); // Success
    if (percentage >= 0.4) return const Color(0xFFFFC107); // Warning
    return const Color(0xFFF44336); // Danger
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        gradient: isDarkMode
            ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF222232),
            Color(0xFF1A1A28),
          ],
        )
            : null,
        color: isDarkMode ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isDarkMode
            ? Border.all(color: Colors.white.withOpacity(0.03))
            : Border.all(color: Colors.grey.shade100),
      ),
      height: 220,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: weeklyData.asMap().entries.map((entry) {
          final int index = entry.key;
          final day = entry.value;
          final double completionPercentage = day['completed'] / day['total'];
          final Color barColor = _getCompletionColor(completionPercentage);

          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 600 + (index * 100)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: barColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${day['completed']}/${day['total']}',
                      style: TextStyle(
                        color: barColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 30,
                    height: 100 * completionPercentage * value,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          barColor,
                          barColor.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: barColor.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: completionPercentage >= 0.8 ?
                    Center(
                      child: Icon(
                        Icons.star,
                        color: Colors.white.withOpacity(0.7),
                        size: 12,
                      ),
                    ) : null,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.black.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: day['day'] == 'Sun' ?
                      Border.all(color: primaryColor.withOpacity(0.3)) : null,
                    ),
                    child: Text(
                      day['day'],
                      style: TextStyle(
                        color: day['day'] == 'Sun' ? primaryColor : secondaryTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }).toList(),
      ),
    );
  }
}