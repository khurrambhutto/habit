import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'models/habit.dart';
import 'screens/habit_details_screen.dart';
import 'screens/auth_screen.dart';
import 'services/supabase_service.dart';
import 'widgets/error_display.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        scaffoldBackgroundColor: Color(0xFF00AEEF),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const AuthWrapper(),
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
  bool _isLoading = true;
  
  // Calculate completed habits count
  int get completedHabitsCount => _habits.where((habit) => habit.isCompleted).length;
  
  // Calculate completion percentage
  double get completionPercentage => _habits.isEmpty ? 0.0 : completedHabitsCount / _habits.length;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final habits = await SupabaseService.getHabits();
      
      // Check for daily resets and update any habits that need it
      bool needsUpdate = false;
      for (final habit in habits) {
        final wasCompleted = habit.isCompleted;
        habit.checkDailyReset(); // Trigger daily reset check
        
        // If habit status changed, we need to update the database
        if (wasCompleted != habit.isCompleted) {
          needsUpdate = true;
          try {
            await SupabaseService.updateHabit(habit);
          } catch (e) {
            // If update fails, revert the change
            habit.isCompleted = wasCompleted;
          }
        }
      }
      
      setState(() {
        _habits = habits;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ErrorDisplay.showError(context, error.toString());
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Habits',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFFD200),
              ),
            )
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                        // Progress Summary Section - Big Floating Card
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 8),
                padding: EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Color(0xFF00AEEF), // Same as background
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Circular Progress Indicator
                    CircularPercentIndicator(
                      radius: 60.0,
                      lineWidth: 10.0,
                      percent: completionPercentage,
                      center: Text(
                        '$completedHabitsCount/${_habits.length}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFD200),
                        ),
                      ),
                      progressColor: Color(0xFFFFD200),
                      backgroundColor: Colors.white.withOpacity(0.3),
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Completed today',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFFFD200),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _habits.isEmpty 
                        ? 'Add habit'
                        : '${(completionPercentage * 100).round()}% of your daily goals',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFFFD200),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
              
              
              
              // Habits List
            Expanded(
              child: _habits.isEmpty
                  ? Container() // Empty container when no habits
                  : ListView.builder(
                      itemCount: _habits.length,
                      padding: EdgeInsets.only(bottom: 80), // Add bottom padding for FAB
                      itemBuilder: (context, index) {
                        return _buildHabitCard(_habits[index], index);
                      },
                    ),
            ),
          ],
        ),
      ),
              floatingActionButton: FloatingActionButton(
          onPressed: _showAddHabitDialog,
          backgroundColor: Color(0xFFFFD200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.add, color: Colors.white),
          elevation: 4,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHabitCard(Habit habit, int index) {
    return GestureDetector(
      onLongPress: () => _showQuickActions(habit, index),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
            // Checkbox
            Transform.scale(
              scale: 1.2,
              child: Checkbox(
                value: habit.isCompleted,
                onChanged: (value) async {
                  await _toggleHabitComplete(habit);
                },
                activeColor: Color(0xFFFFD200),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(width: 16),
            
            // Habit name (vertically centered, left aligned)
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _capitalizeWords(habit.name),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    decoration: habit.isCompleted ? TextDecoration.lineThrough : null,
                    color: habit.isCompleted ? Colors.grey.shade600 : Colors.black87,
                  ),
                ),
              ),
            ),
            
            // Streak and freeze info side by side
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Streak freeze (left)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${habit.streakFreezes} ❄️',
                      style: TextStyle(
                        color: habit.streakFreezes > 0 ? Colors.blue.shade700 : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (habit.wasStreakFreezeRecentlyUsed)
                      Container(
                        margin: EdgeInsets.only(top: 2),
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Used',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w500,
                            fontSize: 9,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 16),
                // Streak (right)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${habit.currentStreak}',
                      style: TextStyle(
                        color: habit.currentStreak > 0 ? Colors.orange.shade700 : Colors.grey.shade600,
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '🔥',
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
                         // More options button
             IconButton(
               icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
               onPressed: () => _navigateToHabitDetails(habit, _habits.indexOf(habit)),
             ),
          ],
          ),
        ),
      ),
    );
  }

  void _showQuickActions(Habit habit, int index) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 24),
                  
                  // Use Streak Freeze button or message
                  if (habit.streakFreezes > 0)
                    Container(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await _useStreakFreeze(habit);
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.ac_unit, color: Colors.white),
                        label: Text(
                          'Use Streak Freeze (${habit.streakFreezes} available)',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade400,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.ac_unit, color: Colors.grey.shade500),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No streak freezes available',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  SizedBox(height: 16),
                  
                  // Delete button
                  Container(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showDeleteConfirmation(habit);
                      },
                      icon: Icon(Icons.delete_outline, color: Colors.white),
                      label: Text(
                        'Delete Habit',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Cancel button
                  Container(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteHabit(habit);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddHabitDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add New Habit',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Enter habit name',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  onSubmitted: (_) => _addHabit(),
                  autofocus: true,
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          _controller.clear();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _addHabit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFFD200),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Add Habit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addHabit() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      try {
        final newHabit = Habit(name: text);
        final createdHabit = await SupabaseService.createHabit(newHabit);
        
        setState(() {
          _habits.add(createdHabit);
        });
        
        _controller.clear();
        Navigator.pop(context);
      } catch (error) {
              if (mounted) {
        ErrorDisplay.showError(context, error.toString());
      }
      }
    }
  }

  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  void _navigateToHabitDetails(Habit habit, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HabitDetailsScreen(habit: habit, habitIndex: index),
      ),
    ).then((shouldDelete) {
      if (shouldDelete == true) {
        _deleteHabit(habit);
      }
    });
  }

  Future<void> _toggleHabitComplete(Habit habit) async {
    try {
      // Update locally first for immediate UI feedback
      setState(() {
        habit.toggleComplete();
      });
      
      // Then update in database
      await SupabaseService.updateHabit(habit);
    } catch (error) {
      // Revert the change if database update fails
      setState(() {
        habit.toggleComplete(); // Toggle back
      });
      
      if (mounted) {
        ErrorDisplay.showError(context, error.toString());
      }
    }
  }

  Future<void> _useStreakFreeze(Habit habit) async {
    try {
      // Update locally first
      setState(() {
        habit.useStreakFreeze();
      });
      
      // Then update in database
      await SupabaseService.updateHabit(habit);
      
      if (mounted) {
        ErrorDisplay.showSuccess(context, 'Streak freeze used!');
      }
    } catch (error) {
      // Revert the change if database update fails
      setState(() {
        habit.streakFreezes++; // Add it back
        habit.lastStreakFreezeUsed = null; // Reset usage time
      });
      
      if (mounted) {
        ErrorDisplay.showError(context, error.toString());
      }
    }
  }

  Future<void> _deleteHabit(Habit habit) async {
    try {
      await SupabaseService.deleteHabit(habit.id);
      
      setState(() {
        _habits.removeWhere((h) => h.id == habit.id);
      });
      
      if (mounted) {
        ErrorDisplay.showSuccess(context, 'Habit deleted successfully');
      }
    } catch (error) {
      if (mounted) {
        ErrorDisplay.showError(context, error.toString());
      }
    }
  }

  Future<void> _handleLogout() async {
    try {
      await SupabaseService.signOut();
    } catch (error) {
      if (mounted) {
        ErrorDisplay.showError(context, error.toString());
      }
    }
  }


}


