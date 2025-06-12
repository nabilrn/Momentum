import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'package:momentum/presentation/services/navigation_service.dart';
import 'package:momentum/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    // Refresh user data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider.refreshUserData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.isDarkMode(context);
    final primaryColor = const Color(0xFF4B6EFF);
    final backgroundColor = isDarkMode ? const Color(0xFF121117) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? const Color(0xFF252836) : Colors.white;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final email = authProvider.email ?? "No email available";
        final profileImageUrl = authProvider.profileImageUrl;
        final fullName = authProvider.fullName;
        final provider = authProvider.provider ?? "Google";
        final isLoading = authProvider.isLoading;

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'Account',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => NavigationService.goBack(context),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient:
                  isDarkMode
                      ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF121117), Color(0xFF1A1A24)],
                      )
                      : LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [Colors.white, const Color(0xFFF5F7FF)],
                      ),
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),

                        // Profile Image with animation
                        Hero(
                          tag: 'profile-image',
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              color:
                                  isDarkMode
                                      ? const Color(0xFF252836)
                                      : Colors.grey.shade100,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.25),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                              image:
                                  profileImageUrl != null
                                      ? DecorationImage(
                                        image: NetworkImage(profileImageUrl),
                                        fit: BoxFit.cover,
                                      )
                                      : null,
                            ),
                            child:
                                profileImageUrl == null
                                    ? Icon(
                                      Icons.person_rounded,
                                      size: 65,
                                      color:
                                          isDarkMode
                                              ? Colors.white38
                                              : Colors.black26,
                                    )
                                    : null,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Full name if available
                        if (fullName != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Text(
                              fullName,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // User Info Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Account Info",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Email Field
                              _buildInfoItem(
                                context: context,
                                icon: Icons.email_outlined,
                                title: "Email",
                                value: email,
                                isDarkMode: isDarkMode,
                                primaryColor: primaryColor,
                              ),

                              const Divider(height: 24),

                              // Provider info (Google, etc)
                              _buildInfoItem(
                                context: context,
                                icon: Icons.login_rounded,
                                title: "Sign-in method",
                                value: provider.toUpperCase(),
                                isDarkMode: isDarkMode,
                                primaryColor: primaryColor,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Logout Button
                        _buildLogoutButton(
                          context: context,
                          primaryColor: primaryColor,
                          isDarkMode: isDarkMode,
                          isLoading: isLoading,
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required bool isDarkMode,
    required Color primaryColor,
  }) {
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primaryColor, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textColor.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton({
    required BuildContext context,
    required Color primaryColor,
    required bool isDarkMode,
    required bool isLoading,
  }) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withBlue(255)],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed:
            isLoading
                ? null
                : () async {
                  try {
                    // Get provider
                    final authProvider = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    );

                    // Sign out
                    await authProvider.signOut();

                    // Navigate back
                    if (mounted) {
                      NavigationService.goBackToWelcomeScreen(context);
                    }
                  } catch (e) {
                    // Show error message
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sign out failed: ${e.toString()}'),
                        ),
                      );
                    }
                  }
                },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          disabledForegroundColor: Colors.white54,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child:
            isLoading
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout_rounded, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      "Log out",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
