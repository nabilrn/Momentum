import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class SupabaseService {
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: 'https://eluysqtmjvyfidonotqq.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVsdXlzcXRtanZ5Zmlkb25vdHFxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDExNTk4MjEsImV4cCI6MjA1NjczNTgyMX0.eP666ZPZfnMxVyK96ii7DLveJ4DzEuvuM7YWiDtmjEI',
        debug: kDebugMode,
      );

      // Verify connection with a lightweight query
      try {
        await client
            .from('habit')
            .select('id')
            .limit(1);
        developer.log('Supabase initialized and connectivity test passed',
            name: 'SupabaseService');
      } catch (error) {
        developer.log('Supabase connectivity test failed',
            error: error.toString(),
            name: 'SupabaseService');
      }
    } catch (error) {
      developer.log('Error initializing Supabase',
          error: error.toString(),
          name: 'SupabaseService');
      rethrow;
    }
  }

  // Adding helpful logging to diagnose issues
  static String get currentTableName => 'habit'; // Make sure this matches exactly your table name

  static SupabaseClient get client => Supabase.instance.client;

  // Utility method to check table existence
  static Future<bool> tableExists(String tableName) async {
    try {
      final response = await client
          .rpc('check_table_exists', params: {'table_name': tableName});

      return response as bool;
    } catch (e) {
      developer.log('Exception checking table existence', error: e);
      return false;
    }
  }
}