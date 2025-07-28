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
    final sortedHabits = List<Habit>.from(habits)
      ..sort((a, b) => b.streak.compareTo(a.streak));
    final displayHabits = sortedHabits.take(4).toList();
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double boxHeight = screenHeight * 0.3;
    // Manual sizing for rectangles - adjust these values as needed
    double availableWidth = screenWidth - 32; // Total width minus outer padding
    double availableHeight = boxHeight - 32; // Total height minus outer padding
    double rectWidth =
        (availableWidth - 8) / 2; // Width for each rectangle (minus spacing)
    double rectHeight =
        (availableHeight - 8) / 2; // Height for each rectangle (minus spacing)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: SizedBox(
        height: boxHeight,
        width: double.infinity,
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Top row
                Expanded(
                  child: Row(
                    children: [
                      if (displayHabits.isNotEmpty)
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 4, bottom: 4),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF9F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                // Left side - Count on top, emoji below
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      // Top - Count (biggest)
                                      Expanded(
                                        flex: 7,
                                        child: Center(
                                          child: Text(
                                            '${displayHabits[0].streak}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFE66700),
                                              fontSize: 42,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Bottom - Emoji (medium)
                                      Expanded(
                                        flex: 3,
                                        child: Center(
                                          child: Text(
                                            '🔥',
                                            style: TextStyle(fontSize: 24),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Right side - Habit name centered
                                Expanded(
                                  flex: 3,
                                  child: Center(
                                    child: Text(
                                      displayHabits[0].name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 24,
                                        color: Color(0xFFE66700),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (displayHabits.length > 1)
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 4, bottom: 4),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF9F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                // Left side - Count on top, emoji below
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      // Top - Count (biggest)
                                      Expanded(
                                        flex: 7,
                                        child: Center(
                                          child: Text(
                                            '${displayHabits[1].streak}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFE66700),
                                              fontSize: 42,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Bottom - Emoji (medium)
                                      Expanded(
                                        flex: 3,
                                        child: Center(
                                          child: Text(
                                            '🔥',
                                            style: TextStyle(fontSize: 24),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Right side - Habit name centered
                                Expanded(
                                  flex: 3,
                                  child: Center(
                                    child: Text(
                                      displayHabits[1].name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 24,
                                        color: Color(0xFFE66700),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Bottom row
                Expanded(
                  child: Row(
                    children: [
                      if (displayHabits.length > 2)
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 4, top: 4),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF9F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                // Left side - Count on top, emoji below
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      // Top - Count (biggest)
                                      Expanded(
                                        flex: 7,
                                        child: Center(
                                          child: Text(
                                            '${displayHabits[2].streak}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFE66700),
                                              fontSize: 42,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Bottom - Emoji (medium)
                                      Expanded(
                                        flex: 3,
                                        child: Center(
                                          child: Text(
                                            '🔥',
                                            style: TextStyle(fontSize: 24),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Right side - Habit name centered
                                Expanded(
                                  flex: 3,
                                  child: Center(
                                    child: Text(
                                      displayHabits[2].name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 24,
                                        color: Color(0xFFE66700),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (displayHabits.length > 3)
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 4, top: 4),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAF9F5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                // Left side - Count on top, emoji below
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    children: [
                                      // Top - Count (biggest)
                                      Expanded(
                                        flex: 7,
                                        child: Center(
                                          child: Text(
                                            '${displayHabits[3].streak}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFE66700),
                                              fontSize: 42,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Bottom - Emoji (medium)
                                      Expanded(
                                        flex: 3,
                                        child: Center(
                                          child: Text(
                                            '🔥',
                                            style: TextStyle(fontSize: 24),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Right side - Habit name centered
                                Expanded(
                                  flex: 3,
                                  child: Center(
                                    child: Text(
                                      displayHabits[3].name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 24,
                                        color: Color(0xFFE66700),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
