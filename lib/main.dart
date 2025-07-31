import 'package:flutter/material.dart';
import 'models/habit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const HabitHome(),
    );
  }
}

class HabitHome extends StatefulWidget {
  const HabitHome({super.key});

  @override
  State<HabitHome> createState() => _HabitHomeState();
}

class _HabitHomeState extends State<HabitHome> {
  final TextEditingController _controller = TextEditingController();
  List<Habit> _habits = [];
  
  // Calculate completed habits count
  int get completedHabitsCount => _habits.where((habit) => habit.isCompleted).length;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Card
            if (_habits.isNotEmpty) ...[
              Card(
                color: Colors.indigo.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatItem('Completed', '$completedHabitsCount/${_habits.length}', Icons.check_circle),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
            
            // Input Section
            TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Enter a habit',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addHabit,
                ),
              ),
              onSubmitted: (_) => _addHabit(),
            ),
            SizedBox(height: 12),

            ElevatedButton(
              onPressed: _addHabit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
              ),
              child: Text('ADD HABIT'),
            ),
            SizedBox(height: 16),
            
            // Habits List
            Expanded(
              child: _habits.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_task, size: 64, color: Colors.grey.shade400),
                          SizedBox(height: 16),
                          Text(
                            'No habits yet!',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add your first habit to get started',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _habits.length,
                      itemBuilder: (context, index) {
                        return _buildHabitCard(_habits[index], index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.indigo, size: 24),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildHabitCard(Habit habit, int index) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: habit.isCompleted,
          onChanged: (value) {
            setState(() {
              habit.toggleComplete();
            });
          },
          activeColor: Colors.indigo,
        ),
        title: Text(
          habit.name,
          style: TextStyle(
            decoration: habit.isCompleted ? TextDecoration.lineThrough : null,
            color: habit.isCompleted ? Colors.grey.shade600 : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (habit.currentStreak > 0)
              Text(
                '🔥 Current Streak: ${habit.currentStreak} days',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (habit.bestStreak > 0)
              Text(
                '🏆 Best Streak: ${habit.bestStreak} days',
                style: TextStyle(
                  color: Colors.amber.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteHabit(index),
        ),
      ),
    );
  }

  void _addHabit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _habits.add(Habit(name: text));
        _controller.clear();
      });
    }
  }

  void _deleteHabit(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${_habits[index].name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _habits.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
