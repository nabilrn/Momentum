import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
class HabitModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final int focusTimeMinutes;

  @HiveField(5)
  final String? startTime;

  @HiveField(6)
  final String priority;

  @HiveField(7)
  final bool isFavorite;

  HabitModel({
    required this.id,
    required this.userId,
    required this.name,
    DateTime? createdAt,
    required this.focusTimeMinutes,
    this.startTime,
    required this.priority,
    this.isFavorite = false,
  }) : createdAt = createdAt ?? DateTime.now();

  HabitModel copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? createdAt,
    int? focusTimeMinutes,
    String? startTime,
    String? priority,
    bool? isFavorite,
  }) {
    return HabitModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      focusTimeMinutes: focusTimeMinutes ?? this.focusTimeMinutes,
      startTime: startTime ?? this.startTime,
      priority: priority ?? this.priority,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Convert from Map (coming from Supabase) to HabitModel
  factory HabitModel.fromMap(Map<String, dynamic> map) {
    return HabitModel(
      id: map['id'],
      name: map['name'] ?? '',
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
      focusTimeMinutes: map['focus_time_minutes'] ?? 25,
      startTime: map['start_time'],
      priority: map['priority'] ?? 'medium',
      isFavorite: map['is_favorite'] ?? false,
    );
  }

  // Convert from HabitModel to Map (to send to Supabase)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'focus_time_minutes': focusTimeMinutes,
      'start_time': startTime,
      'priority': priority,
      'is_favorite': isFavorite,
    };
  }

  // Method to format TimeOfDay to string for database storage
  static String? formatTimeOfDay(TimeOfDay? timeOfDay) {
    if (timeOfDay == null) return null;

    final hour = timeOfDay.hour.toString().padLeft(2, '0');
    final minute = timeOfDay.minute.toString().padLeft(2, '0');
    return '$hour:$minute:00';
  }

  // Method to parse string time from database to TimeOfDay
  static TimeOfDay? parseTimeOfDay(String? timeString) {
    if (timeString == null) return null;

    final parts = timeString.split(':');
    if (parts.length >= 2) {
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    return null;
  }
}
