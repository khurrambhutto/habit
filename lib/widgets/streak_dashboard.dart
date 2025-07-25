import 'package:flutter/material.dart';
import '../models/habit.dart';

class StreakDashboard extends StatelessWidget {
  final List<Habit> habits;

  const StreakDashboard({super.key, required this.habits});

  @override
  Widget build(BuildContext context) {
    if (habits.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Text(
          'No habits yet. Add one below!',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: habits.map((habit) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        habit.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.orange,
                        size: 20,
                      ),
                      Text(
                        ' ${habit.streak}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
