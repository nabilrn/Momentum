import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:momentum/core/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // State variables
  bool _isLoading = false;
  User? _currentUser;
  String? _profileImageUrl;
  String? _fullName;
  String? _email;
  String? _provider;
  AuthError? _lastError;

  // Getters
  bool get isLoading => _isLoading;
  User? get currentUser => _currentUser;
  String? get profileImageUrl => _profileImageUrl;
  String? get fullName => _fullName;
  String? get email => _email;
  String? get provider => _provider;
  AuthError? get lastError => _lastError;
  bool get isAuthenticated => _currentUser != null;

  // Access the underlying AuthService
  AuthService get authService => _authService;

  // Constructor to initialize and listen for auth state changes
  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    // Load initial user data
    _loadCurrentUser();

    // Listen for auth state changes
    _authService.authStateChanges.listen((AuthState state) {
      if (state.event == AuthChangeEvent.signedIn) {
        _loadCurrentUser();
      } else if (state.event == AuthChangeEvent.signedOut) {
        _clearUserData();
      } else if (state.event == AuthChangeEvent.userUpdated) {
        _loadCurrentUser();
      } else if (state.event == AuthChangeEvent.tokenRefreshed) {
        // Usually don't need to reload user data for token refresh
      }
    });
  }

  // Load current user data from AuthService
  void _loadCurrentUser() {
    _currentUser = _authService.currentUser;

    if (_currentUser != null) {
      _email = _currentUser!.email;

      // Extract user metadata
      final metadata = _currentUser!.userMetadata;
      if (metadata != null) {
        // Try to get profile image URL from common fields
        _profileImageUrl =
            metadata['avatar_url'] as String? ??
            metadata['picture'] as String? ??
            metadata['profile_picture'] as String?;

        // Try to get full name from common fields
        _fullName =
            metadata['full_name'] as String? ??
            metadata['name'] as String? ??
            metadata['display_name'] as String?;
      }

      // Get authentication provider
      final appMetadata = _currentUser!.appMetadata;
      if (appMetadata != null && appMetadata.containsKey('provider')) {
        _provider = appMetadata['provider'] as String?;
      }
    }

    notifyListeners();
  }

  // Clear user data on sign out
  void _clearUserData() {
    _currentUser = null;
    _profileImageUrl = null;
    _fullName = null;
    _email = null;
    _provider = null;
    notifyListeners();
  }

  // Sign in with Google
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      _setLoading(true);
      _lastError = null;

      final response = await _authService.signInWithGoogle();

      // If we got a response or we're on web (where response is null but auth continues)
      if (response != null || kIsWeb) {
        _loadCurrentUser(); // Reload user data
      }

      return response;
    } catch (e) {
      debugPrint('❌ AuthProvider: Error during Google sign-in: $e');

      if (e is AuthException) {
        _lastError = AuthError(
          code: e.statusCode?.toString() ?? 'unknown',
          message: e.message,
        );
      } else {
        _lastError = AuthError(code: 'unknown', message: e.toString());
      }

      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      _lastError = null;
      await _authService.signOut();
      // The auth state listener will handle clearing user data
    } catch (e) {
      if (e is AuthException) {
        _lastError = AuthError(
          code: e.statusCode?.toString() ?? 'unknown',
          message: e.message,
        );
      } else {
        _lastError = AuthError(code: 'unknown', message: e.toString());
      }

      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Helper to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Refresh user data - call this when you need to manually refresh the user data
  Future<void> refreshUserData() async {
    _loadCurrentUser();
  }

  // Check if user is authenticated - returns true if there's a valid current user
  bool checkAuthenticated() {
    final isValid = _authService.isSignedIn;
    if (!isValid) {
      _clearUserData();
    }
    return isValid;
  }
}

// Error class for auth errors
class AuthError {
  final String code;
  final String message;

  AuthError({required this.code, required this.message});

  @override
  String toString() => 'AuthError: [$code] $message';
}
