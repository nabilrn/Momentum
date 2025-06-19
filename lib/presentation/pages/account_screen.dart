import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:momentum/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:momentum/presentation/providers/auth_provider.dart';
import '../services/navigation_service.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/sidebar_navigation.dart';
import '../utils/platform_helper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int _currentIndex = 4;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AuthProvider>(context, listen: false).refreshUserData();
      }
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

  bool _isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;

    try {
      Uri? uri = Uri.tryParse(url);
      if (uri == null) return false;

      // Check if it's a valid HTTP/HTTPS URL
      if (!(uri.scheme == 'http' || uri.scheme == 'https')) return false;
      if (uri.host.isEmpty) return false;

      // Additional validation for common image file extensions
      final path = uri.path.toLowerCase();
      final validExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];

      // If the URL has a path, check if it ends with a valid image extension
      // or if it's a known image service (like Google profile pictures)
      if (path.isNotEmpty && !path.contains('googleusercontent') && !path.contains('graph.facebook')) {
        bool hasValidExtension = validExtensions.any((ext) => path.endsWith(ext));
        if (!hasValidExtension && !path.contains('avatar') && !path.contains('profile')) {
          return false;
        }
      }

      return true;
    } catch (e) {
      debugPrint('URL validation error: $e');
      return false;
    }
  }

  Widget _buildProfileImage(String? profileImageUrl, double size, bool isDarkMode) {
    final primaryColor = const Color(0xFF4B6EFF);

    return Container(
      width: size,
      height: size,
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
        child: _isValidUrl(profileImageUrl)
            ? ClipOval(
          child: CachedNetworkImage(
            imageUrl: profileImageUrl!,
            placeholder: (context, url) => Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
            errorWidget: (context, url, error) {
              debugPrint('Failed to load profile image from URL: $url');
              debugPrint('Error details: $error');

              // Return fallback icon
              return _buildFallbackProfileIcon(size);
            },
            fit: BoxFit.cover,
            width: size,
            height: size,
            maxHeightDiskCache: 512,
            memCacheHeight: 512,
            // Add additional error handling
            httpHeaders: const {
              'User-Agent': 'Mozilla/5.0 (compatible; FlutterApp/1.0)',
            },
            // Set timeout for network requests
            fadeInDuration: const Duration(milliseconds: 300),
            fadeOutDuration: const Duration(milliseconds: 300),
          ),
        )
            : _buildFallbackProfileIcon(size),
      ),
    );
  }

  Widget _buildFallbackProfileIcon(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      child: Icon(
        Icons.person_outline,
        color: Colors.white,
        size: size * 0.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = AppTheme.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;

    final usesSidebar = PlatformHelper.isDesktop || kIsWeb || screenWidth > 768;

    return Container(
      decoration: _buildBackgroundDecoration(isDarkMode),
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
            if (usesSidebar) SidebarNavigation(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
            ),
            Expanded(
              child: _buildContent(isDarkMode, usesSidebar),
            ),
          ],
        ),
        bottomNavigationBar: usesSidebar ? null : BottomNavigation(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }

  BoxDecoration _buildBackgroundDecoration(bool isDarkMode) {
    return isDarkMode ? const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF121117), Color(0xFF1A1A24)],
      ),
    ) : const BoxDecoration(color: Colors.white);
  }

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
                  Expanded(
                    flex: 2,
                    child: _buildDesktopProfileSection(authProvider, isDarkMode),
                  ),
                  VerticalDivider(width: 1, thickness: 1, color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.shade200),
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

  Widget _buildDesktopProfileSection(AuthProvider authProvider, bool isDarkMode) {
    final textColor = isDarkMode ? Colors.white : Colors.black;
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
          _buildProfileImage(authProvider.profileImageUrl, 120, isDarkMode),
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

  Widget _buildDesktopActionsSection(BuildContext context, AuthProvider authProvider, bool isDarkMode) {
    final primaryColor = const Color(0xFF4B6EFF);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final provider = authProvider.provider ?? "Google";

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
          SizedBox(
            height: 50,
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: _isLoading
                  ? const SizedBox()
                  : const Icon(Icons.logout_rounded, color: Colors.red),
              label: _isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              )
                  : const Text("Log out", style: TextStyle(fontSize: 16, color: Colors.red)),
              onPressed: _isLoading ? null : () => _showLogoutConfirmationDialog(context, authProvider),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
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

  Widget _buildMobileLayout(BuildContext context, AuthProvider authProvider, bool isDarkMode) {
    final primaryColor = const Color(0xFF4B6EFF);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final email = authProvider.email ?? "No email available";
    final fullName = authProvider.fullName;
    final provider = authProvider.provider ?? "Google";

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 90),
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileImage(authProvider.profileImageUrl, 100, isDarkMode),
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
            const SizedBox(height: 24),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Detail Akun",
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _infoRow(
                Icons.login_rounded,
                "Sign in method",
                provider,
                isDarkMode,
                primaryColor
            ),
            const SizedBox(height: 40),

            SizedBox(
              height: 50,
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: _isLoading
                    ? const SizedBox()
                    : const Icon(Icons.logout_rounded, color: Colors.red),
                label: _isLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                )
                    : const Text("Log out", style: TextStyle(fontSize: 16, color: Colors.red)),
                onPressed: _isLoading ? null : () => _showLogoutConfirmationDialog(context, authProvider),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLogoutConfirmationDialog(BuildContext context, AuthProvider authProvider) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
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
                Navigator.of(dialogContext).pop();
                try {
                  setState(() => _isLoading = true);
                  await authProvider.signOut();
                  if (mounted) {
                    setState(() => _isLoading = false);
                    NavigationService.goBackToWelcomeScreen(context);
                  }
                } catch (e) {
                  if (mounted) {
                    setState(() => _isLoading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sign out failed: $e')),
                    );
                  }
                }
              },
            )
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