// lib/screens/create_task_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';

class CreateTaskScreen extends StatefulWidget {
  final DateTime selectedDate;

  CreateTaskScreen({required this.selectedDate});

  @override
  _CreateTaskScreenState createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = TimeOfDay.now();
  TimeOfDay endTime = TimeOfDay.fromDateTime(
    DateTime.now().add(Duration(hours: 1)),
  );

  @override
  void initState() {
    super.initState();
    selectedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB8860B), // Golden brown background to match UI
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Task',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 18,
              child: Icon(Icons.person, color: Color(0xFFB8860B), size: 20),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Field
                    Text(
                      'Title',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: 'Work on Projects',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Description Field
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Des...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Date Field
                    Text(
                      'Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('E, dd MMM').format(selectedDate),
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              color: Color(0xFFB8860B),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Time Fields
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Start time',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _selectStartTime(context),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  child: Text(
                                    startTime.format(context),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'End time',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _selectEndTime(context),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF5F5F5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                  child: Text(
                                    endTime.format(context),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Spacer(),

                    // Create Task Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _createTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(
                            0xFFCD853F,
                          ), // Darker brown/orange
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Create Task',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFB8860B),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: startTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFB8860B),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFFB8860B),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        endTime = picked;
      });
    }
  }

  void _createTask() {
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a task title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    DateTime startDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      startTime.hour,
      startTime.minute,
    );

    DateTime endDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      endTime.hour,
      endTime.minute,
    );

    _firestore
        .collection('tasks')
        .add({
          'title': titleController.text.trim(),
          'description': descriptionController.text.trim(),
          'startTime': startDateTime,
          'endTime': endDateTime,
          'date': selectedDate,
          'isCompleted': false,
          'createdAt': FieldValue.serverTimestamp(),
        })
        .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task created successfully!'),
              backgroundColor: Color(0xFFB8860B),
            ),
          );
          Navigator.pop(context);
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating task: $error'),
              backgroundColor: Colors.red,
            ),
          );
        });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
