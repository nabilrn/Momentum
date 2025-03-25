import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'package:momentum/presentation/pages/home_screen.dart';
import 'package:momentum/presentation/widgets/momentum_logo.dart';
import 'package:momentum/presentation/widgets/world_map.dart';

// In welcome_screen.dart
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = AppTheme.isDarkMode(context);

    return Scaffold(
      body: Container(
        decoration: isDarkMode
            ? BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.darkWelcomeGradientStart,
              AppTheme.darkWelcomeGradientEnd,
            ],
          ),
        )
            : BoxDecoration(
          color: AppTheme.lightWelcomeBackgroundColor, // White in light mode
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App bar section
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 24),
                      const MomentumLogo(size: 80),
                      SizedBox(
                        width: 24,
                        height: 12,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                // Welcome text - Need to adjust text color for light mode
                Text(
                  'Hi, Welcome',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black, // Black text in light mode
                  ),
                ),
                Text(
                  'to Momentum!',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black, // Black text in light mode
                  ),
                ),

                const SizedBox(height: 60),

                // World map
                const Expanded(
                  child: Center(
                    child: WorldMap(),
                  ),
                ),

                // Tagline - Adjust text color for light mode
                Text(
                  '"Think Your Needs, Build Your Future"',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDarkMode ? Colors.white : Colors.black, // Black text in light mode
                  ),
                ),

                const SizedBox(height: 40),

                // Google sign-in button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.white : Colors.grey[200], // Lighter button in light mode
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/assets/google_logo.png',
                        height: 24,
                        width: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'CONTINUE WITH GOOGLE',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}