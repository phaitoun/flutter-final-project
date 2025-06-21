// lib/screens/todo_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import '../models/task_model.dart';
import '../widgets/custom_button.dart';
import 'create_task_screen.dart';
import 'edit_task_screen.dart';
import 'monthly_calendar_screen.dart';

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime selectedDate = DateTime.now();
  List<DateTime> weekDates = [];

  @override
  void initState() {
    super.initState();
    _generateWeekDates();
  }

  void _generateWeekDates() {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    weekDates = List.generate(7, (index) {
      return startOfWeek.add(Duration(days: index));
    });
  }

  String _formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  String _getDayName(DateTime date) {
    return DateFormat('E').format(date);
  }

  bool _isToday(DateTime date) {
    DateTime now = DateTime.now();
    return date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: GestureDetector(
          onTap: _navigateToCalendar, // Add this tap handler
          child: Column(
            children: [
              Text(
                DateFormat('dd MMM yyyy').format(selectedDate).toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Today',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month, color: Colors.white),
            onPressed: _navigateToCalendar, // Add calendar button
          ),
          Container(
            margin: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              child: Icon(Icons.person, color: AppColors.background, size: 20),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Week Calendar
          Container(
            margin: EdgeInsets.only(top: 10),
            padding: EdgeInsets.all(16),
            child: _buildWeekCalendar(),
          ),
          // My Tasks Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Text(
              'My tasks',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 16),
          // Tasks List
          Expanded(child: _buildTaskList()),
          SizedBox(height: 16),
          // Add Task Button
          CustomButton(
            text: "Add Task",
            onPressed: () => _navigateToCreateTask(),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  void _navigateToCalendar() async {
    final DateTime? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MonthlyCalendarScreen()),
    );

    if (result != null) {
      setState(() {
        selectedDate = result;
      });
    }
  }

  void _navigateToCreateTask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTaskScreen(selectedDate: selectedDate),
      ),
    );
  }

  void _navigateToEditTask(TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditTaskScreen(task: task)),
    );
  }

  Widget _buildWeekCalendar() {
    return Container(
      height: 80,
      child: Center(
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: weekDates.length,
          itemBuilder: (context, index) {
            DateTime date = weekDates[index];
            bool isSelected =
                date.day == selectedDate.day &&
                date.month == selectedDate.month;
            bool isToday = _isToday(date);

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedDate = date;
                });
              },
              child: Container(
                width: 50,
                height: 70,
                margin: EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accent
                      : AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getDayName(date).toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      date.day.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _toggleTaskCompletion(TaskModel task) {
    _firestore.collection('tasks').doc(task.id).update({
      'isCompleted': !task.isCompleted,
    });
  }

  void _deleteTask(String taskId) {
    _firestore.collection('tasks').doc(taskId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task deleted'),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  Widget _buildTaskItem(TaskModel task) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(task.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(Icons.delete, color: Colors.white, size: 30),
        ),
        onDismissed: (direction) {
          _deleteTask(task.id);
        },
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Time
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatTime(task.startTime),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _formatTime(task.endTime),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 16),
              // Task Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    if (task.description.isNotEmpty)
                      Text(
                        task.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary.withOpacity(0.7),
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                  ],
                ),
              ),
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Edit Button
                  GestureDetector(
                    onTap: () => _navigateToEditTask(task),
                    child: Container(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.edit,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  // Checkbox
                  GestureDetector(
                    onTap: () => _toggleTaskCompletion(task),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? AppColors.accent
                            : Colors.transparent,
                        border: Border.all(color: AppColors.accent, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: task.isCompleted
                          ? Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    // Normalize selectedDate to start of day (00:00:00) for proper comparison
    DateTime normalizedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('tasks')
            .where('date', isEqualTo: Timestamp.fromDate(normalizedDate))
            .snapshots(), // Removed orderBy to avoid composite index requirement
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.withOpacity(0.7),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error loading tasks',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 64,
                    color: Colors.white.withOpacity(0.5),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No tasks for this day',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          try {
            List<TaskModel> tasks = snapshot.data!.docs.map((doc) {
              return TaskModel.fromFirestore(doc);
            }).toList();

            // Sort tasks by startTime in Dart instead of Firestore
            tasks.sort((a, b) => a.startTime.compareTo(b.startTime));

            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return _buildTaskItem(tasks[index]);
              },
            );
          } catch (e) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.withOpacity(0.7),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Error parsing tasks',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    e.toString(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
