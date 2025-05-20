import 'package:flutter/material.dart';

class HabitModel {
  final String? id;
  final String name;
  final int focusTimeMinutes;
  final String priority;
  final String? startTime;
  final String userId;
  final DateTime createdAt;

  HabitModel({
    this.id,
    required this.name,
    required this.focusTimeMinutes,
    required this.priority,
    this.startTime,
    required this.userId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert from Map (coming from Supabase) to HabitModel
  factory HabitModel.fromMap(Map<String, dynamic> map) {
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

  // Convert from HabitModel to Map (to send to Supabase)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'focus_time_minutes': focusTimeMinutes,
      'priority': priority,
      'start_time': startTime,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
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
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
    return null;
  }
}