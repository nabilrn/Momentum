import 'package:flutter/material.dart';

class TimeSelector extends StatelessWidget {
  final bool isDarkMode;
  final Color textColor;
  final Color primaryColor;
  final TimeOfDay? selectedTime;
  final Function() onTap;

  const TimeSelector({
    super.key,
    required this.isDarkMode,
    required this.textColor,
    required this.primaryColor,
    required this.selectedTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF252836) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selectedTime != null
              ? primaryColor.withOpacity(0.5)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: selectedTime != null
                      ? primaryColor
                      : (isDarkMode ? Colors.white54 : Colors.black54),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    selectedTime != null
                        ? selectedTime!.format(context)
                        : 'Select a time',
                    style: TextStyle(
                      color: selectedTime != null
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