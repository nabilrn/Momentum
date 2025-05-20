import 'package:momentum/core/services/auth_service.dart';
import 'package:momentum/data/datasources/supabase_datasource.dart';
import 'package:momentum/data/repositories/habit_repository.dart';

/// A class that provides repository instances throughout the app
class RepositoryProviders {
  // Private constructor to prevent instantiation
  RepositoryProviders._();

  // Lazily initialize repositories
  static final HabitRepository _habitRepository = HabitRepository(
    dataSource: SupabaseDataSource(),
    authService: AuthService(),
  );

  // Getters for repositories
  static HabitRepository get habitRepository => _habitRepository;
}