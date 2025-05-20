import 'package:flutter/material.dart';

class HabitCompletionsModel {
  final String? id;
  final String habitId;
  final DateTime completionDate;
  final bool isCompleted;
  final DateTime createdAt;

  HabitCompletionsModel({
    this.id,
    required this.habitId,
    required this.completionDate,
    required this.isCompleted,
    required this.createdAt,
  });

  // Convert from Map (coming from the database) to HabitCompletionsModel
  factory HabitCompletionsModel.fromMap(Map<String, dynamic> map) {
    return HabitCompletionsModel(
      id: map['id'],
      habitId: map['habit_id'],
      completionDate: DateTime.parse(map['completion_date']),
      isCompleted: map['is_completed'] as bool,
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  // Convert from HabitCompletionsModel to Map (to save to the database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habit_id': habitId,
      'completion_date': completionDate.toIso8601String(),
      'is_completed': isCompleted,
      'created_at': createdAt.toIso8601String(),
    };
  }
}