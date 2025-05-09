// lib/core/services/supabase_service.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: 'https://eluysqtmjvyfidonotqq.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVsdXlzcXRtanZ5Zmlkb25vdHFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExNTk4MjEsImV4cCI6MjA1NjczNTgyMX0.eP666ZPZfnMxVyK96ii7DLveJ4DzEuvuM7YWiDtmjEI',
        // The authFlowType parameter is not needed in the current API version
        debug: kDebugMode,
      );
      debugPrint('Supabase initialized successfully');
    } catch (error) {
      debugPrint('Error initializing Supabase: $error');
      rethrow;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;
}