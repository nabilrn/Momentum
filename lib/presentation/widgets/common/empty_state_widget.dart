import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData? icon;
  final String? lottieAsset;
  final VoidCallback? onActionPressed;
  final String? actionLabel;
  final Widget? customAction;

  const EmptyStateWidget({
    Key? key,
    required this.title,
    required this.message,
    this.icon,
    this.lottieAsset = 'assets/lottie/empty_state.json',
    this.onActionPressed,
    this.actionLabel,
    this.customAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (lottieAsset != null)
            SizedBox(
              height: 200,
              width: 200,
              child: Lottie.asset(lottieAsset!, repeat: true, animate: true),
            )
          else if (icon != null)
            Icon(
              icon!,
              size: 80,
              color:
                  isDarkMode
                      ? Colors.white.withOpacity(0.5)
                      : Colors.black.withOpacity(0.5),
            ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color:
                    isDarkMode
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black.withOpacity(0.7),
              ),
            ),
          ),
          if (onActionPressed != null && actionLabel != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onActionPressed,
              icon: const Icon(Icons.add),
              label: Text(actionLabel!),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B6EFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
          if (customAction != null) ...[
            const SizedBox(height: 24),
            customAction!,
          ],
        ],
      ),
    );
  }
}
