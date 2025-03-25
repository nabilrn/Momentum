import 'package:flutter/material.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Colors
  static const Color darkSplashGradientStart = Color(0xFF121212);
  static const Color darkSplashGradientEnd = Color(0xFF1E1E30);
  static const Color lightSplashBackgroundColor = Colors.white;
  static const Color darkWelcomeGradientStart = Color(0xFF0F0F1F);
  static const Color darkWelcomeGradientEnd = Color(0xFF1A1A2E);
  static const Color lightWelcomeBackgroundColor = Colors.white;
  static const Color lightButtonGradientStart = Color(0xFF4CC9F0);
  static const Color lightButtonGradientEnd = Color(0xFF4361EE);
  static const Color primaryColor = Colors.white;
  static const Color accentColor = Colors.blue;

  // Bottom Navigation colors
  static const Color darkBottomNav = Color(0xFF080816);
  static const Color lightBottomNav = Color(0xFF6C4BFF);


  // Check if current theme is dark
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // Text styles
  static const TextStyle titleStyle = TextStyle(
    color: primaryColor,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle taglineStyle = TextStyle(
    color: primaryColor,
    fontSize: 16,
    fontStyle: FontStyle.italic,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );

  // Theme data
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightSplashBackgroundColor,
    brightness: Brightness.light,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      displayLarge: titleStyle,
      bodyMedium: taglineStyle,
      labelLarge: buttonTextStyle,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
  );

  // Add dark theme
  static final ThemeData darkTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkSplashGradientStart,
    brightness: Brightness.dark,
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      displayLarge: titleStyle,
      bodyMedium: taglineStyle,
      labelLarge: buttonTextStyle,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
  );
}