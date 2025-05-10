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

  // TODO: Replace with your actual client IDs
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

      // Initialize the web GIS sign-in handler
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

  // Initialize web sign-in with GIS approach
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
      _googleSignIn
          .signInSilently()
          .then((account) {
            debugPrint(
              '🔐 AuthService: Silent sign-in result: ${account?.email ?? 'No user'}',
            );
          })
          .catchError((e) {
            debugPrint('⚠️ AuthService: Silent sign-in error: $e');
          });
    }
  }

  SupabaseClient get _supabaseClient => SupabaseService.client;

  // The new recommended approach for web
  Future<GoogleSignInAccount?> signInWithGoogleWebGIS() async {
    if (!kIsWeb) return null;

    debugPrint('🔐 AuthService: Starting Web GIS Google Sign-In');

    try {
      // Use completer to handle the sign-in process
      _webSignInCompleter = Completer<GoogleSignInAccount?>();

      // Make the web button visible
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

  // Legacy web sign-in method - keep for backward compatibility
  Future<AuthResponse?> signInWithGoogleWeb() async {
    try {
      debugPrint('🔐 AuthService: Starting legacy Web Google Sign-In');

      // Clear any existing sign in first
      try {
        await _googleSignIn.signOut();
        debugPrint(
          '🔐 AuthService: Successfully signed out from previous session',
        );
      } catch (e) {
        debugPrint(
          '⚠️ AuthService: Failed to sign out from previous session: $e',
        );
      }

      // For web, use the new recommended approach
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

      // Clear any existing sign in first
      try {
        await _googleSignIn.signOut();
        debugPrint(
          '🔐 AuthService: Successfully signed out from previous session',
        );
      } catch (e) {
        debugPrint(
          '⚠️ AuthService: Failed to sign out from previous session: $e',
        );
        // Continue regardless of sign-out success
      }

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

    // Get authentication data
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

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
      debugPrint('❌ AuthService: No ID token received from Google');
      throw Exception(
        'No ID token received from Google. Please check your Google Cloud Console configuration and ensure you have set up OAuth correctly for web and mobile platforms.',
      );
    }

    if (accessToken == null) {
      debugPrint('❌ AuthService: No access token received from Google');
      throw Exception('No access token received from Google.');
    }

    debugPrint(
      '✅ AuthService: ID token received: ${idToken.substring(0, min(10, idToken.length))}...',
    );

    // Sign in to Supabase with the ID token
    final response = await _supabaseClient.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    debugPrint('✅ AuthService: Supabase sign-in successful');
    return response;
  }

  // Method to handle button click from the UI (used with renderButton)
  Future<void> handleGoogleSignInButtonClick() async {
    if (!kIsWeb) return;

    try {
      isSigningIn.value = true;

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
    } catch (e) {
      debugPrint('❌ AuthService: Google Sign-Out error: $e');
    }

    try {
      await _supabaseClient.auth.signOut();
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
