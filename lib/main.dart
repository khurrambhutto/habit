import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'models/habit.dart';

import 'screens/auth_screen.dart';
import 'screens/habit_details_screen.dart';
import 'services/supabase_service.dart';
import 'widgets/error_display.dart';

// Central color constant for consistent yellow throughout the app
const Color invincibleYellow = Color(0xFFFFD200);

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
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey.shade50,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Colors.black87,
          ),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadHabits() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final habits = await SupabaseService.getHabits();
      
      // Check for daily resets and update any habits that need it
      for (final habit in habits) {
        final wasCompleted = habit.isCompleted;
        habit.checkDailyReset(); // Trigger daily reset check
        
        // If habit status changed, we need to update the database
        if (wasCompleted != habit.isCompleted) {
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
        backgroundColor: Colors.grey.shade50,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        title: Text(
          'Habits',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              icon: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.grey.shade700,
                  size: 20,
                ),
              ),
              onSelected: (value) {
                if (value == 'logout') {
                  _showLogoutConfirmation();
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
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4CAF50),
              ),
            )
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress Summary Section
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 32),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Circular Progress Indicator
                  CircularPercentIndicator(
                    radius: 80.0,
                    lineWidth: 12.0,
                    percent: completionPercentage,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$completedHabitsCount/${_habits.length}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    progressColor: Color(0xFF4CAF50), // Green color
                    backgroundColor: Colors.grey.shade200,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  SizedBox(height: 16),
                  // Motivational text
                  if (completedHabitsCount > 0)
                    Text(
                      "You're on a roll!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                ],
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
          backgroundColor: Color(0xFF4CAF50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(Icons.add, color: Colors.white, size: 28),
          elevation: 6,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHabitCard(Habit habit, int index) {
    return GestureDetector(
      onTap: () async => await _toggleHabitComplete(habit),
      child: Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row with icon, name, and streak indicators
            Row(
              children: [
                // Habit checkmark
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: habit.isCompleted 
                        ? Color(0xFF4CAF50)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    habit.isCompleted ? Icons.check : null,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                
                // Habit name
                Expanded(
                  child: Text(
                    _capitalizeWords(habit.name),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                
                // Streak indicators and details button
                Row(
                  children: [
                    // Streak freeze indicator - always visible
                    Text(
                      '❄️ ${habit.streakFreezes}',
                      style: TextStyle(
                        fontSize: 16,
                        color: habit.streakFreezes > 0 
                            ? Colors.blue.shade600 
                            : Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 16),
                    // Current streak indicator - always visible
                    Text(
                      '🔥 ${habit.currentStreak}',
                      style: TextStyle(
                        fontSize: 26,
                        color: habit.currentStreak > 0 
                            ? Colors.orange.shade600 
                            : Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    // Habit details button
                    IconButton(
                      icon: Icon(
                        Icons.info_outline,
                        color: Colors.grey.shade600,
                        size: 18,
                      ),
                      onPressed: () => _navigateToHabitDetails(habit, index),
                      padding: EdgeInsets.all(4),
                      constraints: BoxConstraints(
                        minWidth: 28,
                        minHeight: 28,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Weekly calendar view
            _buildWeeklyView(habit),
          ],
        ),
      ),
    );
  }



  // Build weekly calendar view for habit
  Widget _buildWeeklyView(Habit habit) {
    final weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    
    return Column(
      children: [
        // Weekday labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: weekdays.map((day) => 
            Expanded(
              child: Text(
                day,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ).toList(),
        ),
        
        SizedBox(height: 8),
        
        // Calendar circles
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            final day = monday.add(Duration(days: index));
            final isToday = _isSameDay(day, today);
            final isCompleted = _isHabitCompletedOnDay(habit, day);
            final isFuture = day.isAfter(today);
            
            return Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFuture 
                      ? Colors.grey.shade200
                      : isCompleted 
                          ? Color(0xFF4CAF50)
                          : Colors.grey.shade200,
                  border: isToday 
                      ? Border.all(color: Color(0xFF4CAF50), width: 2)
                      : null,
                ),
                child: Center(
                  child: isFuture 
                      ? null
                      : Icon(
                          isCompleted ? Icons.check : Icons.close,
                          size: 16,
                          color: isCompleted ? Colors.white : Colors.grey.shade600,
                        ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // Helper to check if habit was completed on specific day
  bool _isHabitCompletedOnDay(Habit habit, DateTime day) {
    if (habit.lastCompletedDate == null) return false;
    
    // For today, check current completion status
    if (_isSameDay(day, DateTime.now())) {
      return habit.isCompleted;
    }
    
    // For other days, we'd need to check historical data
    // For now, just return false for past days (we can improve this later)
    return false;
  }

  // Helper to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
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
                          backgroundColor: Color(0xFF4CAF50),
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

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleLogout();
              },
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
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


