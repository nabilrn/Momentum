import 'package:flutter/material.dart';
import 'habit_item.dart';

class HabitList extends StatelessWidget {
  final List<Map<String, dynamic>> habits;
  final AnimationController controller;

  const HabitList({
    super.key,
    required this.habits,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return ListView.builder(
            itemCount: habits.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final habit = habits[index];

              // Stagger the animations
              final itemAnimation = Tween(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: controller,
                  curve: Interval(
                    index * 0.1, // Start delay
                    0.6 + index * 0.1, // End time
                    curve: Curves.easeOut,
                  ),
                ),
              );

              return FadeTransition(
                opacity: itemAnimation,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: HabitItem(habit: habit),
                ),
              );
            },
          );
        },
      ),
    );
  }
}