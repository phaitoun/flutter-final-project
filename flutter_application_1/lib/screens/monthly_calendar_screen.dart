// lib/screens/monthly_calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import '../models/task_model.dart';

class MonthlyCalendarScreen extends StatefulWidget {
  @override
  _MonthlyCalendarScreenState createState() => _MonthlyCalendarScreenState();
}

class _MonthlyCalendarScreenState extends State<MonthlyCalendarScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  DateTime currentMonth = DateTime.now();
  DateTime selectedDate = DateTime.now();
  Map<String, Map<String, int>> taskStats =
      {}; // dateKey -> {total: x, completed: y}

  @override
  void initState() {
    super.initState();
    _loadMonthTaskStats();
  }

  void _loadMonthTaskStats() async {
    DateTime firstDayOfMonth = DateTime(
      currentMonth.year,
      currentMonth.month,
      1,
    );
    DateTime lastDayOfMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    );

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('tasks')
          .where(
            'date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfMonth),
          )
          .where(
            'date',
            isLessThanOrEqualTo: Timestamp.fromDate(lastDayOfMonth),
          )
          .get();

      Map<String, Map<String, int>> stats = {};

      for (var doc in snapshot.docs) {
        TaskModel task = TaskModel.fromFirestore(doc);
        String dateKey = DateFormat('yyyy-MM-dd').format(task.date);

        if (stats[dateKey] == null) {
          stats[dateKey] = {'total': 0, 'completed': 0};
        }

        stats[dateKey]!['total'] = stats[dateKey]!['total']! + 1;
        if (task.isCompleted) {
          stats[dateKey]!['completed'] = stats[dateKey]!['completed']! + 1;
        }
      }

      if (mounted) {
        setState(() {
          taskStats = stats;
        });
      }
    } catch (e) {
      print('Error loading task stats: $e');
    }
  }

  void _previousMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1);
    });
    _loadMonthTaskStats();
  }

  void _nextMonth() {
    setState(() {
      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1);
    });
    _loadMonthTaskStats();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });

    // Navigate back to TodoScreen with selected date
    Navigator.pop(context, date);
  }

  List<DateTime> _generateCalendarDays() {
    DateTime firstDayOfMonth = DateTime(
      currentMonth.year,
      currentMonth.month,
      1,
    );
    DateTime lastDayOfMonth = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    );

    int firstWeekday = firstDayOfMonth.weekday;
    DateTime startDate = firstDayOfMonth.subtract(
      Duration(days: firstWeekday - 1),
    );

    List<DateTime> days = [];
    for (int i = 0; i < 42; i++) {
      // 6 weeks * 7 days
      days.add(startDate.add(Duration(days: i)));
    }

    return days;
  }

  bool _isCurrentMonth(DateTime date) {
    return date.month == currentMonth.month && date.year == currentMonth.year;
  }

  bool _isToday(DateTime date) {
    DateTime now = DateTime.now();
    return date.day == now.day &&
        date.month == now.month &&
        date.year == now.year;
  }

  bool _isSelectedDate(DateTime date) {
    return date.day == selectedDate.day &&
        date.month == selectedDate.month &&
        date.year == selectedDate.year;
  }

  Widget _buildTaskIndicator(DateTime date) {
    String dateKey = DateFormat('yyyy-MM-dd').format(date);
    Map<String, int>? stats = taskStats[dateKey];

    if (stats == null || stats['total'] == 0) {
      return SizedBox.shrink();
    }

    int total = stats['total']!;
    int completed = stats['completed']!;

    // Different indicator styles based on task status
    if (completed == total) {
      // All tasks completed - green dot
      return Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
      );
    } else if (completed > 0) {
      // Some tasks completed - orange dot
      return Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
      );
    } else {
      // No tasks completed - red dot
      return Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
      );
    }
  }

  Widget _buildTaskStatusBar(DateTime date) {
    String dateKey = DateFormat('yyyy-MM-dd').format(date);
    Map<String, int>? stats = taskStats[dateKey];

    if (stats == null || stats['total'] == 0) {
      return SizedBox.shrink();
    }

    int total = stats['total']!;
    int completed = stats['completed']!;
    double progress = completed / total;

    return Container(
      width: 20,
      height: 3,
      margin: EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(1.5),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: progress == 1.0
                ? Colors.green
                : progress > 0
                ? Colors.orange
                : Colors.red,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<DateTime> calendarDays = _generateCalendarDays();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          DateFormat('MMM yyyy').format(currentMonth).toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
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
      body: Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Month Navigation
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _previousMonth,
                    icon: Icon(Icons.chevron_left, color: Colors.grey[600]),
                  ),
                  Text(
                    DateFormat('MMMM yyyy').format(currentMonth),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  IconButton(
                    onPressed: _nextMonth,
                    icon: Icon(Icons.chevron_right, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Weekday Headers
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT']
                    .map(
                      (day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            SizedBox(height: 8),

            // Calendar Grid
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: calendarDays.length,
                  itemBuilder: (context, index) {
                    DateTime date = calendarDays[index];
                    bool isCurrentMonth = _isCurrentMonth(date);
                    bool isToday = _isToday(date);
                    bool isSelected = _isSelectedDate(date);

                    return GestureDetector(
                      onTap: () => _onDateSelected(date),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.brown[400]
                              : isToday
                              ? Colors.brown[100]
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isToday && !isSelected
                              ? Border.all(color: Colors.brown[300]!, width: 1)
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              date.day.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: !isCurrentMonth
                                    ? Colors.grey[400]
                                    : isSelected
                                    ? Colors.white
                                    : Colors.grey[800],
                              ),
                            ),
                            SizedBox(height: 4),
                            _buildTaskStatusBar(date),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Legend
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem(Colors.green, 'All Done'),
                  _buildLegendItem(Colors.orange, 'In Progress'),
                  _buildLegendItem(Colors.red, 'Pending'),
                ],
              ),
            ),

            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
        SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
