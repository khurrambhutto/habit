import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../services/habit_service.dart';
import '../services/auth_service.dart';
import '../widgets/streak_dashboard.dart';

class HabitTrackerScreen extends StatefulWidget {
  @override
  State<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  final HabitService _habitService = HabitService();
  final AuthService _authService = AuthService();
  final TextEditingController _controller = TextEditingController();

  List<Habit> _habits = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final habits = await _habitService.getAllHabits();
      setState(() {
        _habits = habits;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addHabit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      final newHabit = await _habitService.addHabit(text);
      setState(() {
        _habits.add(newHabit);
        _controller.clear();
      });
    } catch (e) {
      _showErrorSnackBar('Failed to add habit: $e');
    }
  }

  Future<void> _toggleHabit(int index) async {
    try {
      final updatedHabit = await _habitService.toggleHabit(_habits[index]);
      setState(() {
        _habits[index] = updatedHabit;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to update habit: $e');
    }
  }

  Future<void> _deleteHabit(int index) async {
    final habit = _habits[index];
    try {
      await _habitService.deleteHabit(habit.id!);
      setState(() {
        _habits.removeAt(index);
      });
    } catch (e) {
      _showErrorSnackBar('Failed to delete habit: $e');
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      // Navigation will be handled by the parent widget listening to auth state
    } catch (e) {
      _showErrorSnackBar('Failed to sign out: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = _authService.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadHabits),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) {
              if (value == 'signout') {
                _signOut();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Signed in as:',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      userProfile?['email'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadHabits,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                StreakDashboard(habits: _habits),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Enter a new habit',
                          ),
                          onSubmitted: (_) => _addHabit(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        mini: true,
                        onPressed: _addHabit,
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    itemCount: _habits.length,
                    itemBuilder: (context, index) {
                      final habit = _habits[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: Checkbox(
                            value: habit.checkedToday,
                            onChanged: (_) => _toggleHabit(index),
                            activeColor: Colors.green,
                          ),
                          title: Text(
                            habit.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: habit.checkedToday
                                  ? Colors.green
                                  : Colors.black87,
                              decoration: habit.checkedToday
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              const Icon(
                                Icons.local_fire_department,
                                color: Colors.orange,
                                size: 18,
                              ),
                              Text(
                                ' Streak: ${habit.streak}',
                                style: const TextStyle(color: Colors.orange),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _deleteHabit(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
