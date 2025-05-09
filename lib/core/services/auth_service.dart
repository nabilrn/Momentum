// lib/core/services/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:momentum/core/services/supabase_service.dart';

class AuthService {
  late final GoogleSignIn _googleSignIn;

  // TODO: Replace with your actual client IDs
  static const String _webClientId = '691097230046-gqdce2jcd9vpmkmfq9vjn2dfji4jv7k1.apps.googleusercontent.com';
  static const String _iosClientId = '691097230046-rmriho3d8kft2jv9q7uku4io32ec3i86.apps.googleusercontent.com';
  // Android uses the web client ID as the serverClientId

  AuthService() {
    if (kIsWeb) {
      _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
          'https://www.googleapis.com/auth/userinfo.email',
          'https://www.googleapis.com/auth/userinfo.profile',
          'openid'
        ],
        clientId: _webClientId,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
          'https://www.googleapis.com/auth/userinfo.email',
          'https://www.googleapis.com/auth/userinfo.profile',
          'openid'
        ],
        clientId: _iosClientId,
        serverClientId: _webClientId,
      );
    } else {
      // Android and other platforms
      _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'profile',
          'https://www.googleapis.com/auth/userinfo.email',
          'https://www.googleapis.com/auth/userinfo.profile',
          'openid'
        ],
        serverClientId: _webClientId,
      );
    }
  }

  SupabaseClient get _supabaseClient => SupabaseService.client;

  Future<AuthResponse?> signInWithGoogle() async {
    try {
      debugPrint('🔐 AuthService: Starting Google Sign-In');
      debugPrint('🔐 AuthService: Running on ${kIsWeb ? 'Web' : defaultTargetPlatform.name}');

      // Clear any existing sign in first
      try {
        await _googleSignIn.signOut();
        debugPrint('🔐 AuthService: Successfully signed out from previous session');
      } catch (e) {
        debugPrint('⚠️ AuthService: Failed to sign out from previous session: $e');
        // Continue regardless of sign-out success
      }

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('❌ AuthService: User canceled Google Sign-In');
        return null;
      }

      debugPrint('🔐 AuthService: Google account selected: ${googleUser.email}');

      // Get authentication data
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Verify we have the required tokens
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        debugPrint('❌ AuthService: No ID token received from Google');
        throw Exception('No ID token received from Google. Please check your Google Cloud Console configuration.');
      }

      if (accessToken == null) {
        debugPrint('❌ AuthService: No access token received from Google');
        throw Exception('No access token received from Google.');
      }

      debugPrint('✅ AuthService: ID token received: ${idToken.substring(0, min(10, idToken.length))}...');

      // Sign in to Supabase with the ID token
      final response = await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      debugPrint('✅ AuthService: Supabase sign-in successful');
      return response;
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

  Stream<AuthState> get authStateChanges => _supabaseClient.auth.onAuthStateChange;
}

// Helper function to safely get substring
int min(int a, int b) {
  return a < b ? a : b;
}