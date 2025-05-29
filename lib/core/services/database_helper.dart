// lib/core/services/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:momentum/data/models/habit_model.dart';
import 'dart:developer' as developer;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'momentum_habits.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE habits(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        focus_time_minutes INTEGER NOT NULL,
        priority TEXT NOT NULL,
        start_time TEXT,
        user_id TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    developer.log('💾 Habits database created');
  }

  // CRUD operations
  Future<int> insertHabit(HabitModel habit) async {
    final db = await database;
    return await db.insert(
      'habits',
      _toMap(habit),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateHabit(HabitModel habit) async {
    final db = await database;
    return await db.update(
      'habits',
      _toMap(habit),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(String id) async {
    final db = await database;
    return await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<HabitModel>> getHabitsByUserId(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) {
      return _fromMap(maps[i]);
    });
  }

  // Handle batch operations
  Future<void> insertHabits(List<HabitModel> habits) async {
    final db = await database;
    Batch batch = db.batch();
    for (var habit in habits) {
      batch.insert(
        'habits',
        _toMap(habit),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> deleteAllHabitsForUser(String userId) async {
    final db = await database;
    await db.delete(
      'habits',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Convert between SQL format and HabitModel
  Map<String, dynamic> _toMap(HabitModel habit) {
    return {
      'id': habit.id,
      'name': habit.name,
      'focus_time_minutes': habit.focusTimeMinutes,
      'priority': habit.priority,
      'start_time': habit.startTime,
      'user_id': habit.userId,
      'created_at': habit.createdAt.toIso8601String(),
    };
  }

  HabitModel _fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'],
      name: map['name'],
      focusTimeMinutes: map['focus_time_minutes'],
      priority: map['priority'],
      startTime: map['start_time'],
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}