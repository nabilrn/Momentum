// lib/core/services/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:momentum/core/services/supabase_service.dart';
import 'package:momentum/core/services/fcm_service.dart';
import 'dart:async';

class AuthService {
  late final GoogleSignIn _googleSignIn;
  final ValueNotifier<bool> isSigningIn = ValueNotifier<bool>(false);
  StreamSubscription<AuthState>? _authSubscription;

  // TODO: Replace with your actual client IDs
  static const String _webClientId =
      '691097230046-gqdce2jcd9vpmkmfq9vjn2dfji4jv7k1.apps.googleusercontent.com';
  static const String _iosClientId =
      '691097230046-rmriho3d8kft2jv9q7uku4io32ec3i86.apps.googleusercontent.com';

  AuthService() {
    if (kIsWeb) {
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile', 'openid'],
        clientId: _webClientId,
      );

      // Listen for auth state changes to handle FCM registration on web
      _authSubscription = authStateChanges.listen((state) {
        if (state.event == AuthChangeEvent.signedIn) {
          debugPrint('🔔 AuthService: Auth state changed to signed in on web');
          _registerFcmForWeb();
        }
      });
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile', 'openid'],
        clientId: _iosClientId,
        serverClientId: _webClientId,
      );
    } else {
      _googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile', 'openid'],
        serverClientId: _webClientId,
      );
    }
  }

  Future<void> _registerFcmForWeb() async {
    if (kIsWeb) {
      debugPrint('🔔 AuthService: Attempting to register FCM token for web');
      try {
        await FCMService.registerTokenAfterLogin();
        debugPrint('✅ AuthService: Successfully registered FCM token for web');
      } catch (e) {
        debugPrint('❌ AuthService: Failed to register FCM token for web: $e');
      }
    }
  }

  SupabaseClient get _supabaseClient => SupabaseService.client;

  // Main sign-in method that handles both web and mobile
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      debugPrint('🔐 AuthService: Starting Google Sign-In');
      debugPrint(
        '🔐 AuthService: Running on ${kIsWeb ? 'Web' : defaultTargetPlatform.name}',
      );

      isSigningIn.value = true;

      if (kIsWeb) {
        // Web: use Supabase OAuth only
        await _supabaseClient.auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: Uri.base.origin,
        );
        debugPrint('✅ AuthService: Supabase OAuth sign-in initiated for web');
        // For web, we return null because the OAuth flow completes asynchronously
        return null;
      } else {
        // Mobile: use GoogleSignIn
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          debugPrint('❌ AuthService: User canceled Google Sign-In');
          return null;
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final String? idToken = googleAuth.idToken;
        final String? accessToken = googleAuth.accessToken;

        if (idToken == null || accessToken == null) {
          debugPrint('❌ AuthService: Missing required tokens for mobile');
          throw Exception('Missing required tokens for mobile authentication.');
        }

        debugPrint(
          '✅ AuthService: ID token received: ${idToken.substring(0, min(10, idToken.length))}...',
        );

        final response = await _supabaseClient.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );

        debugPrint('✅ AuthService: Supabase sign-in successful');
        await FCMService.registerTokenAfterLogin();

        return response;
      }
    } catch (error) {
      debugPrint('❌ AuthService: Error signing in with Google: $error');
      if (error is PlatformException) {
        debugPrint('❌ AuthService: Platform error code: ${error.code}');
        debugPrint('❌ AuthService: Platform error message: ${error.message}');
        debugPrint('❌ AuthService: Error details: ${error.details}');
      }
      rethrow;
    } finally {
      isSigningIn.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      debugPrint('✅ AuthService: Google Sign-Out successful');

      if (kIsWeb) {
        debugPrint('🔔 AuthService: Handling web sign-out for FCM');
        await Future.delayed(const Duration(milliseconds: 300));
      }
    } catch (e) {
      debugPrint('❌ AuthService: Google Sign-Out error: $e');
    }

    try {
      await _supabaseClient.auth.signOut(scope: SignOutScope.local);
      debugPrint('✅ AuthService: Supabase Sign-Out successful');
    } catch (e) {
      debugPrint('❌ AuthService: Supabase Sign-Out error: $e');
    }
  }

  // Dispose method to clean up resources
  void dispose() {
    _authSubscription?.cancel();
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
