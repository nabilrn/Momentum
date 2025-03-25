import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'package:momentum/presentation/pages/welcome_screen.dart';
import 'package:momentum/presentation/widgets/momentum_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to welcome screen after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.isDarkMode(context);

    return Scaffold(
      body: Container(
        decoration: isDarkMode
            ? const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.darkSplashGradientStart,
              AppTheme.darkSplashGradientEnd,
            ],
          ),
        )
            : BoxDecoration(
          color: AppTheme.lightSplashBackgroundColor,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const MomentumLogo(size: 120),
              const SizedBox(height: 20),
              Text(
                'MOMENTUM',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}