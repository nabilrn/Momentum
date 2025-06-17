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

  // REFACTOR: Define a breakpoint for responsive layout
  static const double _desktopBreakpoint = 900.0;

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

    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.authService.isSignedIn) {
      if (mounted) _navigateToHome();
    }
    authProvider.authService.authStateChanges.listen((AuthState state) {
      if (state.event == AuthChangeEvent.signedIn && mounted) {
        _navigateToHome();
      }
    });
    setState(() => _isInitializing = false);
    _animationController.forward();
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (context, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final response = await authProvider.signInWithGoogle();

      if (response == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign-in was canceled'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;
      String errorMsg = 'Sign-in failed. Please try again.';
      // (Error handling logic remains the same)
      if (error is AuthException) {
        errorMsg = 'Authentication error: ${error.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
    final isDarkMode = AppTheme.isDarkMode(context);

    if (_isInitializing) {
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
              : BoxDecoration(color: AppTheme.lightWelcomeBackgroundColor),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
          image: const DecorationImage(
            image: AssetImage('assets/images/light_pattern.png'),
            opacity: 0.05,
            repeat: ImageRepeat.repeat,
          ),
        ),
        child: SafeArea(
          // REFACTOR: Use LayoutBuilder to switch between layouts
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > _desktopBreakpoint) {
                return _buildDesktopLayout(context);
              } else {
                return _buildMobileLayout(context);
              }
            },
          ),
        ),
      ),
    );
  }

  // NEW WIDGET: For desktop layout (screen width > 900)
  Widget _buildDesktopLayout(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDarkMode = AppTheme.isDarkMode(context);
    final primaryColor = const Color(0xFF4B6EFF);
    final secondaryColor = const Color(0xFF8C61FF);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Column: Info and Call to Action
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeTransition(
                      opacity: _fadeInAnimation,
                      child: const MomentumLogo(size: 80),
                    ),
                    const SizedBox(height: 40),
                    SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeInAnimation,
                        child: _buildWelcomeText(context, primaryColor, secondaryColor, isDarkMode),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeTransition(
                      opacity: _fadeInAnimation,
                      child: _buildTagline(context, isDarkMode),
                    ),
                    const SizedBox(height: 40),
                    FadeTransition(
                      opacity: _fadeInAnimation,
                      child: _buildSignInButton(authProvider, primaryColor, secondaryColor, isDarkMode),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 60),
              // Right Column: Visual Showcase (World Map)
              Expanded(
                flex: 3,
                child: FadeTransition(
                  opacity: _fadeInAnimation,
                  child: const Center(child: WorldMap()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // NEW WIDGET: For mobile layout (screen width <= 900)
  Widget _buildMobileLayout(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDarkMode = AppTheme.isDarkMode(context);
    final primaryColor = const Color(0xFF4B6EFF);
    final secondaryColor = const Color(0xFF8C61FF);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(flex: 1),
          FadeTransition(
            opacity: _fadeInAnimation,
            child: const Center(child: MomentumLogo(size: 100)),
          ),
          const SizedBox(height: 40),
          SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeInAnimation,
              child: _buildWelcomeText(context, primaryColor, secondaryColor, isDarkMode),
            ),
          ),
          Expanded(
            flex: 4,
            child: FadeTransition(
              opacity: _fadeInAnimation,
              child: const Center(child: WorldMap()),
            ),
          ),
          FadeTransition(
            opacity: _fadeInAnimation,
            child: _buildTagline(context, isDarkMode),
          ),
          const SizedBox(height: 40),
          FadeTransition(
            opacity: _fadeInAnimation,
            child: _buildSignInButton(authProvider, primaryColor, secondaryColor, isDarkMode),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  // REFACTOR: Extracted widgets to reduce duplication
  Widget _buildWelcomeText(BuildContext context, Color primaryColor, Color secondaryColor, bool isDarkMode) {
    return Column(
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white.withOpacity(0.1) : primaryColor.withOpacity(0.1),
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
    );
  }

  Widget _buildTagline(BuildContext context, bool isDarkMode) {
    return Text(
      '"Think Your Needs, Build Your Future"',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: isDarkMode ? Colors.white70 : Colors.black87,
        fontStyle: FontStyle.italic,
        fontSize: 16,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSignInButton(AuthProvider authProvider, Color primaryColor, Color secondaryColor, bool isDarkMode) {
    // The existing button logic is fine, just calling the appropriate web/mobile version
    return kIsWeb
        ? _buildWebSignInButton(authProvider, primaryColor, secondaryColor, isDarkMode)
        : _buildMobileSignInButton(primaryColor, secondaryColor, isDarkMode);
  }

  // The web and mobile button implementations remain the same as they were
  Widget _buildWebSignInButton(AuthProvider authProvider, Color primaryColor, Color secondaryColor, bool isDarkMode) {
    // ... (kode asli Anda untuk tombol web)
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: isDarkMode ? null : LinearGradient(colors: [primaryColor, secondaryColor], begin: Alignment.centerLeft, end: Alignment.centerRight),
        color: isDarkMode ? Colors.white : null,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.3) : primaryColor.withOpacity(0.3),
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
                    boxShadow: isDarkMode ? null : [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: _isLoading
                      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(isDarkMode ? Colors.black87 : primaryColor)))
                      : Image.asset('assets/images/google_logo.png', height: 20, width: 20),
                ),
                const SizedBox(width: 16),
                Text(
                  _isLoading ? 'SIGNING IN...' : 'CONTINUE WITH GOOGLE',
                  style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.black87 : Colors.white, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileSignInButton(Color primaryColor, Color secondaryColor, bool isDarkMode) {
    // ... (kode asli Anda untuk tombol mobile)
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: isDarkMode ? null : LinearGradient(colors: [primaryColor, secondaryColor], begin: Alignment.centerLeft, end: Alignment.centerRight),
        color: isDarkMode ? Colors.white : null,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black.withOpacity(0.3) : primaryColor.withOpacity(0.3),
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
                    boxShadow: isDarkMode ? null : [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: _isLoading
                      ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(isDarkMode ? Colors.black87 : primaryColor)))
                      : Image.asset('assets/images/google_logo.png', height: 20, width: 20),
                ),
                const SizedBox(width: 16),
                Text(
                  _isLoading ? 'SIGNING IN...' : 'CONTINUE WITH GOOGLE',
                  style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.black87 : Colors.white, letterSpacing: 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}