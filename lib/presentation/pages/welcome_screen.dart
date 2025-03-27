import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'package:momentum/presentation/pages/home_screen.dart';
import 'package:momentum/presentation/widgets/momentum_logo.dart';
import 'package:momentum/presentation/widgets/world_map.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = AppTheme.isDarkMode(context);
    final primaryColor = const Color(0xFF4B6EFF);
    final secondaryColor = const Color(0xFF8C61FF);

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
          color: AppTheme.lightWelcomeBackgroundColor,
          image: DecorationImage(
            image: const AssetImage('lib/assets/light_pattern.png'),
            opacity: 0.05,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App bar with logo
                Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: FadeTransition(
                    opacity: _fadeInAnimation,
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: const MomentumLogo(size: 100),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Welcome text with animation
                SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeInAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, Welcome',
                          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [primaryColor, secondaryColor],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds),
                          child: Text(
                            'to Momentum!',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 32,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Create habits, build momentum',
                            style: TextStyle(
                              color: isDarkMode
                                  ? Colors.white70
                                  : primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // World map with animation
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeInAnimation,
                    child: const Center(
                      child: WorldMap(),
                    ),
                  ),
                ),

                // Tagline
                FadeTransition(
                  opacity: _fadeInAnimation,
                  child: Text(
                    '"Think Your Needs, Build Your Future"',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Enhanced Google sign-in button
                FadeTransition(
                  opacity: _fadeInAnimation,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: isDarkMode
                          ? null
                          : LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      color: isDarkMode ? Colors.white : null,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(28),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              transitionDuration: const Duration(milliseconds: 500),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: isDarkMode ? null : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'lib/assets/google_logo.png',
                                  height: 20,
                                  width: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                'CONTINUE WITH GOOGLE',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.black87 : Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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