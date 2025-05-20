import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'package:momentum/presentation/pages/home_screen.dart';
import 'package:momentum/presentation/widgets/momentum_logo.dart';
import 'package:momentum/presentation/widgets/world_map.dart';
import 'package:momentum/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isInitializing = true;
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

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    // Check if user is already signed in
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Check if already authenticated
    if (authProvider.authService.isSignedIn) {
      debugPrint('✅ User is already signed in');
      if (mounted) {
        _navigateToHome();
      }
    }

    // Listen for auth state changes
    authProvider.authService.authStateChanges.listen((AuthState state) {
      if (state.event == AuthChangeEvent.signedIn) {
        debugPrint('✅ Auth state change: Signed in');
        if (mounted) {
          _navigateToHome();
        }
      }
    });

    setState(() => _isInitializing = false);
    _animationController.forward();
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return; // Prevent multiple taps

    setState(() => _isLoading = true);
    debugPrint('🔐 Sign-in process started');

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      debugPrint('🔐 Calling Google Sign-In method');
      final response = await authProvider.signInWithGoogle();

      if (response == null) {
        debugPrint('❌ Sign-in canceled or returned null');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign-in was canceled'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        debugPrint('✅ Sign-in successful - User: ${response.user?.email}');
        // The auth state listener will handle navigation
      }
    } catch (error) {
      debugPrint('❌ Sign-in error: $error');
      String errorMsg = 'Sign-in failed';

      if (error is AuthException) {
        debugPrint('❌ Auth error code: ${error.statusCode}');
        debugPrint('❌ Auth error message: ${error.message}');

        if (error.message.contains('Email not confirmed')) {
          errorMsg = 'Please verify your email address';
        } else {
          errorMsg = 'Authentication error: ${error.message}';
        }
      } else {
        // Handle other types of errors
        final errorString = error.toString();
        if (errorString.contains('network_error') ||
            errorString.contains('connection')) {
          errorMsg = 'Network error. Please check your connection.';
        } else if (errorString.contains('canceled')) {
          errorMsg = 'Sign-in was canceled';
        } else {
          errorMsg = 'Sign-in failed: ${errorString.split('\n')[0]}';
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint('🔐 Sign-in process completed');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isDarkMode = AppTheme.isDarkMode(context);
    final primaryColor = const Color(0xFF4B6EFF);
    final secondaryColor = const Color(0xFF8C61FF);

    if (_isInitializing) {
      return Scaffold(
        body: Container(
          decoration:
          isDarkMode
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
              : BoxDecoration(color: AppTheme.lightWelcomeBackgroundColor),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration:
        isDarkMode
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
                          style: Theme.of(
                            context,
                          ).textTheme.displayLarge?.copyWith(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ShaderMask(
                          shaderCallback:
                              (bounds) => LinearGradient(
                            colors: [primaryColor, secondaryColor],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ).createShader(bounds),
                          child: Text(
                            'to Momentum!',
                            style: Theme.of(
                              context,
                            ).textTheme.displayLarge?.copyWith(
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
                            color:
                            isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Create habits, build momentum',
                            style: TextStyle(
                              color: isDarkMode ? Colors.white70 : primaryColor,
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
                    child: const Center(child: WorldMap()),
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

                // Sign-in button with web vs mobile handling
                FadeTransition(
                  opacity: _fadeInAnimation,
                  child:
                  kIsWeb
                      ? _buildWebSignInButton(
                    authProvider,
                    primaryColor,
                    secondaryColor,
                    isDarkMode,
                  )
                      : _buildMobileSignInButton(
                    primaryColor,
                    secondaryColor,
                    isDarkMode,
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

  // New method for web sign-in that uses the recommended renderButton approach
  Widget _buildWebSignInButton(
      AuthProvider authProvider,
      Color primaryColor,
      Color secondaryColor,
      bool isDarkMode,
      ) {
    return ValueListenableBuilder<bool>(
      valueListenable: authProvider.authService.isSigningIn,
      builder: (context, isSigningIn, child) {
        return Container(
          height: 56,
          decoration: BoxDecoration(
            gradient:
            isDarkMode
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
                color:
                isDarkMode
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
              onTap:
              isSigningIn
                  ? null
                  : () {
                // For web, use the recommended approach
                authProvider.authService
                    .handleGoogleSignInButtonClick();
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
                        boxShadow:
                        isDarkMode
                            ? null
                            : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child:
                      isSigningIn
                          ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDarkMode ? Colors.black87 : primaryColor,
                          ),
                        ),
                      )
                          : Image.asset(
                        'lib/assets/google_logo.png',
                        height: 20,
                        width: 20,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      isSigningIn ? 'SIGNING IN...' : 'CONTINUE WITH GOOGLE',
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
        );
      },
    );
  }

  // Mobile sign-in button remains the same
  Widget _buildMobileSignInButton(
      Color primaryColor,
      Color secondaryColor,
      bool isDarkMode,
      ) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient:
        isDarkMode
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
            color:
            isDarkMode
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
          onTap: _isLoading ? null : _handleGoogleSignIn,
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
                    boxShadow:
                    isDarkMode
                        ? null
                        : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child:
                  _isLoading
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDarkMode ? Colors.black87 : primaryColor,
                      ),
                    ),
                  )
                      : Image.asset(
                    'lib/assets/google_logo.png',
                    height: 20,
                    width: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  _isLoading ? 'SIGNING IN...' : 'CONTINUE WITH GOOGLE',
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
    );
  }
}
