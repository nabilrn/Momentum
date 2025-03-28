import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final bool isDarkMode;
  final int currentIndex;
  final int totalItems;
  final Function(int) onIndicatorTap;

  const ProgressBar({
    super.key,
    required this.isDarkMode,
    required this.currentIndex,
    required this.totalItems,
    required this.onIndicatorTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalItems, (index) {
          return ProgressIndicator(
            isSelected: index == currentIndex,
            isDarkMode: isDarkMode,
            index: index,
            onTap: onIndicatorTap,
          );
        }),
      ),
    );
  }
}

class ProgressIndicator extends StatelessWidget {
  final bool isSelected;
  final bool isDarkMode;
  final int index;
  final Function(int) onTap;

  const ProgressIndicator({
    super.key,
    required this.isSelected,
    required this.isDarkMode,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: isSelected ? 24 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4B6EFF)
              : (isDarkMode ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.1)),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}