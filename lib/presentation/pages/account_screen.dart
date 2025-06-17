import 'package:flutter/material.dart';
import 'package:momentum/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:momentum/presentation/providers/auth_provider.dart';
import '../services/navigation_service.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/sidebar_navigation.dart';
import '../utils/platform_helper.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int _currentIndex = 4;

  // Responsive breakpoint
  static const double _breakpoint = 768;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).refreshUserData();
    });
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
      final routes = {
        0: '/home', 1: '/random_habit', 2: '/overview', 3: '/settings'
      };
      if (routes.containsKey(index)) {
        NavigationService.navigateTo(context, routes[index]!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final usesSidebar = screenWidth > _breakpoint;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121117) : const Color(0xFFF8F9FA),
      appBar: usesSidebar ? null : AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Account',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Row(
        children: [
          // Show sidebar for desktop/web
          if (usesSidebar) SidebarNavigation(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
          ),

          // Main content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF121117) : const Color(0xFFF8F9FA),
                gradient: isDarkMode ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF121117), Color(0xFF1A1A24)],
                ) : null,
              ),
              child: _buildContent(isDarkMode, usesSidebar),
            ),
          ),
        ],
      ),
      bottomNavigationBar: usesSidebar ? null : BottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  // REFACTOR: The build content method now routes to a mobile or desktop specific layout.
  Widget _buildContent(bool isDarkMode, bool isDesktop) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (isDesktop) {
          return _buildDesktopLayout(context, authProvider, isDarkMode);
        } else {
          return _buildMobileLayout(context, authProvider, isDarkMode);
        }
      },
    );
  }

  // NEW WIDGET: A dedicated layout for desktop screens (web).
  Widget _buildDesktopLayout(BuildContext context, AuthProvider authProvider, bool isDarkMode) {
    final cardColor = isDarkMode ? const Color(0xFF1E1E2C) : Colors.white;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900, minHeight: 400),
          child: Card(
            color: cardColor,
            elevation: isDarkMode ? 0 : 4,
            shadowColor: isDarkMode ? Colors.transparent : Colors.black.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isDarkMode
                  ? BorderSide(color: Colors.white.withOpacity(0.05))
                  : BorderSide.none,
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Column: Profile Info
                  Expanded(
                    flex: 2,
                    child: _buildDesktopProfileSection(authProvider, isDarkMode),
                  ),

                  // Divider
                  VerticalDivider(width: 1, thickness: 1, color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade200),

                  // Right Column: Actions
                  Expanded(
                    flex: 3,
                    child: _buildDesktopActionsSection(context, authProvider, isDarkMode),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // NEW WIDGET: Helper for the left side of the desktop layout.
  Widget _buildDesktopProfileSection(AuthProvider authProvider, bool isDarkMode) {
    final primaryColor = const Color(0xFF4B6EFF);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final profileImageUrl = authProvider.profileImageUrl;
    final fullName = authProvider.fullName;
    final email = authProvider.email ?? "No email available";

    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
        color: isDarkMode ? Colors.black.withOpacity(0.1) : Colors.transparent,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withBlue(255).withGreen(120)],
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl) : null,
              child: profileImageUrl == null
                  ? Icon(Icons.person_outline, color: Colors.white, size: 60)
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          if (fullName != null) ...[
            Text(
              fullName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            email,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // NEW WIDGET: Helper for the right side of the desktop layout.
  Widget _buildDesktopActionsSection(BuildContext context, AuthProvider authProvider, bool isDarkMode) {
    final primaryColor = const Color(0xFF4B6EFF);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final dangerColor = Colors.red.shade400;
    final provider = authProvider.provider ?? "Google";
    final isLoading = authProvider.isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Detail Akun",
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _infoRow(
            Icons.login_rounded,
            "Metode Sign-in",
            provider,
            isDarkMode,
            primaryColor,
          ),
          const SizedBox(height: 48),

          Text(
            "Zona Berbahaya",
            style: TextStyle(
              color: dangerColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tindakan berikut tidak dapat diurungkan. Harap berhati-hati.",
            style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 14),
          ),
          const SizedBox(height: 24),

          // Logout button
          SizedBox(
            height: 50,
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: isLoading
                  ? const SizedBox()
                  : Icon(Icons.logout_rounded, color: dangerColor),
              label: isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              )
                  : Text("Log out", style: TextStyle(fontSize: 16, color: dangerColor)),
              onPressed: isLoading ? null : () => _showLogoutConfirmationDialog(context, authProvider),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: dangerColor.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // REFACTORED from the original _buildContent into its own method for clarity.
  Widget _buildMobileLayout(BuildContext context, AuthProvider authProvider, bool isDarkMode) {
    final primaryColor = const Color(0xFF4B6EFF);
    final cardColor = isDarkMode ? const Color(0xFF1E1E2C) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    final email = authProvider.email ?? "No email available";
    final profileImageUrl = authProvider.profileImageUrl;
    final fullName = authProvider.fullName;
    final provider = authProvider.provider ?? "Google";
    final isLoading = authProvider.isLoading;

    return SafeArea(
      bottom: true, // Mobile layout needs bottom safe area
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 90),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Card(
              color: cardColor,
              elevation: isDarkMode ? 0 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: isDarkMode
                    ? BorderSide(color: Colors.white.withOpacity(0.05))
                    : BorderSide.none,
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [primaryColor, primaryColor.withBlue(255)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl) : null,
                        child: profileImageUrl == null
                            ? const Icon(Icons.person, color: Colors.white, size: 50)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (fullName != null) ...[
                      Text(
                        fullName,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      email,
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Divider(color: textColor.withOpacity(0.1)),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _infoRow(
                              Icons.login_rounded, "Sign in method", provider, isDarkMode, primaryColor),
                          const SizedBox(height: 32),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton.icon(
                              icon: isLoading ? const SizedBox() : const Icon(Icons.logout_rounded),
                              label: isLoading
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                                  : const Text("Log out", style: TextStyle(fontSize: 16)),
                              onPressed: isLoading ? () {} : () => _showLogoutConfirmationDialog(context, authProvider),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // NEW: Logout confirmation dialog
  Future<void> _showLogoutConfirmationDialog(BuildContext context, AuthProvider authProvider) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Log Out'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Apakah Anda yakin ingin keluar dari akun Anda?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Log Out', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Dismiss the dialog
                try {
                  await authProvider.signOut();
                  if (mounted) {
                    NavigationService.goBackToWelcomeScreen(context);
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sign out failed: $e')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String title, String value, bool isDarkMode, Color primaryColor) {
    final textColor = isDarkMode ? Colors.white : Colors.black;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryColor),
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
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}