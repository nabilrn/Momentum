// lib/services/auth_service.dart
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:momentum/services/supabase_service.dart';

class AuthService {
  final SupabaseClient _supabaseClient = SupabaseService.client;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<AuthResponse?> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled sign-in
        return null;
      }

      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Sign in to Supabase with Google credentials
      final response = await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      return response;
    } catch (error) {
      debugPrint('Error signing in with Google: $error');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _supabaseClient.auth.signOut();
  }

  bool get isSignedIn => _supabaseClient.auth.currentSession != null;

  User? get currentUser => _supabaseClient.auth.currentUser;

  Stream<AuthState> get authStateChanges => _supabaseClient.auth.onAuthStateChange;
}