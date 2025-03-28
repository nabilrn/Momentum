import 'package:flutter/material.dart';

class PrioritySelector extends StatelessWidget {
  final bool isDarkMode;
  final Color textColor;
  final String selectedType;
  final Function(String) onPrioritySelected;

  const PrioritySelector({
    super.key,
    required this.isDarkMode,
    required this.textColor,
    required this.selectedType,
    required this.onPrioritySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPriorityOption('Low', Colors.green, isDarkMode, textColor),
        _buildPriorityOption('Medium', Colors.orange, isDarkMode, textColor),
        _buildPriorityOption('High', Colors.red, isDarkMode, textColor),
      ],
    );
  }

  Widget _buildPriorityOption(String label, Color color, bool isDarkMode, Color textColor) {
    final isSelected = selectedType == label;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDarkMode ? color.withOpacity(0.3) : color.withOpacity(0.15))
            : (isDarkMode ? const Color(0xFF252836) : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? color : Colors.transparent,
          width: 2,
        ),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          )
        ]
            : null,
      ),
      child: InkWell(
        onTap: () => onPrioritySelected(label),
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            Icon(
              _getPriorityIcon(label),
              color: isSelected ? color : (isDarkMode ? Colors.white54 : Colors.black54),
              size: 24,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'Low':
        return Icons.arrow_downward_rounded;
      case 'Medium':
        return Icons.remove_rounded;
      case 'High':
        return Icons.arrow_upward_rounded;
      default:
        return Icons.remove_rounded;
    }
  }
}