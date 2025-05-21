import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:momentum/core/services/supabase_service.dart';
import 'dart:async';

class AuthService {
  late final GoogleSignIn _googleSignIn;
  // Controller for web sign-in button
  final ValueNotifier<bool> webSignInButtonVisible = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isSigningIn = ValueNotifier<bool>(false);

  // Completer to handle the web sign-in flow
  Completer<GoogleSignInAccount?>? _webSignInCompleter;

  // TODO: Replace with your actual client IDs (note: you already have these filled in)
  static const String _webClientId =
      '691097230046-gqdce2jcd9vpmkmfq9vjn2dfji4jv7k1.apps.googleusercontent.com';
  static const String _iosClientId =
      '691097230046-rmriho3d8kft2jv9q7uku4io32ec3i86.apps.googleusercontent.com';
  // Android uses the web client ID as the serverClientId

  AuthService() {
    if (kIsWeb) {
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile', 'openid'],
        clientId: _webClientId,
      );

      // Initialize the web sign-in handler
      _initializeWebSignIn();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile', 'openid'],
        clientId: _iosClientId,
        serverClientId: _webClientId,
      );
    } else {
      // Android and other platforms
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile', 'openid'],
        serverClientId: _webClientId,
      );
    }
  }

  // Initialize web sign-in with proper listener setup
  void _initializeWebSignIn() {
    if (kIsWeb) {
      // Set up the onCurrentUserChanged listener to handle authentication
      _googleSignIn.onCurrentUserChanged.listen((
          GoogleSignInAccount? account,
          ) async {
        if (account != null) {
          debugPrint('🔐 AuthService: Current user changed: ${account.email}');
          isSigningIn.value = true;
          try {
            final response = await _processGoogleSignIn(account);
            if (_webSignInCompleter != null &&
                !_webSignInCompleter!.isCompleted) {
              _webSignInCompleter!.complete(account);
            }
          } catch (e) {
            debugPrint('❌ AuthService: Error processing web sign-in: $e');
            if (_webSignInCompleter != null &&
                !_webSignInCompleter!.isCompleted) {
              _webSignInCompleter!.completeError(e);
            }
          } finally {
            isSigningIn.value = false;
          }
        }
      });

      // Try silent sign-in to check if user is already authenticated
      _trySilentSignIn();
    }
  }

  // Helper method to attempt silent sign-in
  Future<void> _trySilentSignIn() async {
    try {
      final account = await _googleSignIn.signInSilently();
      debugPrint(
        '🔐 AuthService: Silent sign-in result: ${account?.email ?? 'No user'}',
      );
    } catch (e) {
      debugPrint('⚠️ AuthService: Silent sign-in error: $e');
    }
  }

  SupabaseClient get _supabaseClient => SupabaseService.client;

  // Web GIS sign-in method - the recommended approach for web
  Future<GoogleSignInAccount?> signInWithGoogleWebGIS() async {
    if (!kIsWeb) return null;

    debugPrint('🔐 AuthService: Starting Web GIS Google Sign-In');

    try {
      // First clear existing sessions
      await _cleanupPreviousSessions();

      // Use completer to handle the sign-in process
      _webSignInCompleter = Completer<GoogleSignInAccount?>();

      // Attempt signInSilently first to refresh tokens
      final silentUser = await _googleSignIn.signInSilently();
      if (silentUser != null) {
        debugPrint('🔐 AuthService: Silent sign-in successful: ${silentUser.email}');
        return silentUser;
      }

      // If silent sign-in fails, make the web button visible for explicit sign-in
      webSignInButtonVisible.value = true;

      // Wait for the user to click the button and complete the sign-in
      return await _webSignInCompleter!.future;
    } catch (e) {
      debugPrint('❌ AuthService: Web GIS sign-in error: $e');
      rethrow;
    } finally {
      // Hide the button after sign-in attempt
      webSignInButtonVisible.value = false;
    }
  }

  // Helper method to clean up previous sessions
  Future<void> _cleanupPreviousSessions() async {
    // Clear Google Sign-In session
    try {
      await _googleSignIn.signOut();
      debugPrint(
        '🔐 AuthService: Successfully signed out from previous Google session',
      );

      // Clear any cookies or in-memory tokens that might be causing issues
      if (kIsWeb) {
        debugPrint('🔐 AuthService: Web platform detected, performing additional cleanup');
        // Allow a brief pause for token clearing
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } catch (e) {
      debugPrint(
        '⚠️ AuthService: Failed to sign out from previous Google session: $e',
      );
    }

    // Optionally clear Supabase session if needed
    // Uncomment if you want to force Supabase signout as well
    /*
    try {
      await _supabaseClient.auth.signOut(scope: SignOutScope.local);
      debugPrint('🔐 AuthService: Successfully signed out from previous Supabase session');
    } catch (e) {
      debugPrint('⚠️ AuthService: Failed to sign out from previous Supabase session: $e');
    }
    */
  }

  // Web sign-in method wrapper (uses the GIS approach)
  Future<AuthResponse?> signInWithGoogleWeb() async {
    try {
      debugPrint('🔐 AuthService: Starting Web Google Sign-In');

      // For web, use the recommended GIS approach
      final GoogleSignInAccount? googleUser = await signInWithGoogleWebGIS();

      if (googleUser == null) {
        debugPrint('❌ AuthService: Web sign-in was canceled');
        return null;
      }

      return await _processGoogleSignIn(googleUser);
    } catch (error) {
      debugPrint('❌ AuthService: Error signing in with Google on web: $error');
      rethrow;
    }
  }

  // Main sign-in method that handles both web and mobile
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      debugPrint('🔐 AuthService: Starting Google Sign-In');
      debugPrint(
        '🔐 AuthService: Running on ${kIsWeb ? 'Web' : defaultTargetPlatform.name}',
      );

      // For web platform, use the web-specific method
      if (kIsWeb) {
        return await signInWithGoogleWeb();
      }

      // Clean up previous sessions
      await _cleanupPreviousSessions();

      // For mobile platforms, use the standard approach
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('❌ AuthService: User canceled Google Sign-In');
        return null;
      }

      return await _processGoogleSignIn(googleUser);
    } catch (error) {
      debugPrint('❌ AuthService: Error signing in with Google: $error');
      if (error is PlatformException) {
        debugPrint('❌ AuthService: Platform error code: ${error.code}');
        debugPrint('❌ AuthService: Platform error message: ${error.message}');
        debugPrint('❌ AuthService: Error details: ${error.details}');
      }
      rethrow;
    }
  }

  // Helper method to process Google Sign-In and authenticate with Supabase
  Future<AuthResponse?> _processGoogleSignIn(
      GoogleSignInAccount googleUser,
      ) async {
    debugPrint(
      '🔐 AuthService: Processing Google account: ${googleUser.email}',
    );

    // Get authentication data with retries for web
    final GoogleSignInAuthentication googleAuth = await _getGoogleAuthWithRetry(googleUser);

    // Verify we have the required tokens
    final String? idToken = googleAuth.idToken;
    final String? accessToken = googleAuth.accessToken;

    debugPrint(
      '🔐 AuthService: ID token: ${idToken != null ? 'present' : 'missing'}',
    );
    debugPrint(
      '🔐 AuthService: Access token: ${accessToken != null ? 'present' : 'missing'}',
    );

    if (idToken == null) {
      if (kIsWeb && accessToken != null) {
        // Special handling for web when we only have an access token
        debugPrint('⚠️ AuthService: No ID token on web, but access token is present. Using custom sign-in flow.');
        // Use a custom sign-in method for this scenario
        return await _signInWithAccessTokenOnly(accessToken, googleUser.email);
      } else {
        // Standard error for missing ID token
        debugPrint('❌ AuthService: No ID token received from Google');
        throw Exception(
          'No ID token received from Google. Please check your Google Cloud Console configuration and ensure you have set up OAuth correctly for web and mobile platforms.',
        );
      }
    }

    // For Web with FedCM, the accessToken might be null - adapt accordingly
    if (accessToken == null && kIsWeb) {
      debugPrint('⚠️ AuthService: No access token received from Google on web. Proceeding with ID token only.');

      // Use ID token only authentication for web
      final response = await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        // Skip accessToken parameter for web
      );

      debugPrint('✅ AuthService: Supabase sign-in successful with ID token only');
      return response;
    } else if (accessToken == null) {
      // For mobile platforms, still require access token
      debugPrint('❌ AuthService: No access token received from Google on mobile');
      throw Exception('No access token received from Google.');
    }

    debugPrint(
      '✅ AuthService: ID token received: ${idToken.substring(0, min(10, idToken.length))}...',
    );

    // Standard sign-in with both tokens
    final response = await _supabaseClient.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    debugPrint('✅ AuthService: Supabase sign-in successful');
    return response;
  }

  // Helper method to get Google authentication with retry logic for web
  Future<GoogleSignInAuthentication> _getGoogleAuthWithRetry(GoogleSignInAccount googleUser) async {
    int retryCount = 0;
    const maxRetries = 2;

    while (true) {
      try {
        final auth = await googleUser.authentication;

        // If we have at least one token, or we've reached max retries, return what we have
        if (auth.idToken != null || auth.accessToken != null || retryCount >= maxRetries) {
          return auth;
        }

        // If we get here, we didn't get any tokens - retry after a short delay
        retryCount++;
        debugPrint('⚠️ AuthService: No tokens received, retrying ($retryCount/$maxRetries)');
        await Future.delayed(Duration(milliseconds: 500));

      } catch (e) {
        debugPrint('❌ AuthService: Error getting Google authentication: $e');
        if (retryCount >= maxRetries) {
          rethrow;
        }
        retryCount++;
        await Future.delayed(Duration(milliseconds: 500));
      }
    }
  }

  // Custom method for handling sign-in with only access token (web fallback)
  Future<AuthResponse?> _signInWithAccessTokenOnly(String accessToken, String email) async {
    try {
      // Option 1: Try to exchange the access token for an ID token using your backend
      // This would be the best approach but requires server-side implementation
      // return await _exchangeAccessTokenForIdToken(accessToken);

      // Option 2: Use magic link as a fallback
      debugPrint('⚠️ AuthService: Attempting to sign in with access token only');

      // Simple email validation check
      if (!email.contains('@')) {
        throw Exception('Invalid email address format');
      }

      // Option 3: Use password authentication if the user already exists
      // This is just a fallback option if you have pre-registered users

      // For now, we'll throw an error to prompt you to implement a proper solution
      throw Exception(
        'ID token is required but was missing. You may need to implement token exchange on your backend.',
      );
    } catch (e) {
      debugPrint('❌ AuthService: Error in access token only flow: $e');
      rethrow;
    }
  }

  // Method to handle button click from the UI (used with renderButton)
  Future<void> handleGoogleSignInButtonClick() async {
    if (!kIsWeb) return;

    try {
      isSigningIn.value = true;

      // Reset Google Sign-In state to force a fresh authentication
      await _googleSignIn.signOut();

      // Brief delay to ensure any token clearing has completed
      await Future.delayed(const Duration(milliseconds: 300));

      // This prompts the OAuth consent screen
      final GoogleSignInAccount? account = await _googleSignIn.signIn();

      // If successful, the onCurrentUserChanged listener will handle the rest
      if (account == null) {
        // User canceled the sign-in
        if (_webSignInCompleter != null && !_webSignInCompleter!.isCompleted) {
          _webSignInCompleter!.complete(null);
        }
      }
    } catch (e) {
      debugPrint('❌ AuthService: Error during button click handler: $e');
      if (_webSignInCompleter != null && !_webSignInCompleter!.isCompleted) {
        _webSignInCompleter!.completeError(e);
      }
    } finally {
      isSigningIn.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      debugPrint('✅ AuthService: Google Sign-Out successful');

      // For web, add a small delay to allow token clearing
      if (kIsWeb) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } catch (e) {
      debugPrint('❌ AuthService: Google Sign-Out error: $e');
    }

    try {
      // Make sure to sign out from Supabase with both local and global scopes
      await _supabaseClient.auth.signOut(scope: SignOutScope.local);
      debugPrint('✅ AuthService: Supabase Sign-Out successful');
    } catch (e) {
      debugPrint('❌ AuthService: Supabase Sign-Out error: $e');
    }
  }

  bool get isSignedIn => _supabaseClient.auth.currentSession != null;

  User? get currentUser => _supabaseClient.auth.currentUser;

  Stream<AuthState> get authStateChanges =>
      _supabaseClient.auth.onAuthStateChange;
}

// Helper function to safely get substring
int min(int a, int b) {
  return a < b ? a : b;
}